//
//  NCPlanetariesViewController.m
//  Neocom
//
//  Created by Artem Shimanski on 20.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCPlanetariesViewController.h"
#import "global.h"
#import "NCStorage.h"
#import <EVEAPI/EVEAPI.h>
#import "NCCache.h"
#import "NCAccount.h"
#import "NCAPIKey.h"
#import "NCDatabase.h"
#import "NCFittingEngine.h"
#import "NCBarChartView.h"
#import "NSString+Neocom.h"
#import "NCPlanetaryExtractorCell.h"
#import "NCPlanetaryStorageCell.h"
#import "NSNumberFormatter+Neocom.h"

@interface NCPlanetaryNode: NSObject
@property (readonly) NSArray* children;
@property (readonly) NSAttributedString* title;
@property (readonly) NSImage* image;
@end

@implementation NCPlanetaryNode

@end


@interface NCPlanetaryFactoryResource : NSObject
@property (nonatomic, strong) NCDBInvType* type;
@property (nonatomic, assign) BOOL depleted;
@property (nonatomic, assign) float ratio;
@property (nonatomic, strong) NSString* shortage;
@end

@implementation NCPlanetaryFactoryResource
@end



@class NCPlanetaryColony;
@interface NCPlanetaryFacility : NCPlanetaryNode
@property (nonatomic, weak) NCPlanetaryColony* colony;
@property (nonatomic, strong) EVEPlanetaryPinsItem* pin;
@property (nonatomic, strong) NSString* pinName;

@property (nonatomic, assign) std::shared_ptr<const dgmpp::Facility> facility;
@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;
@property (nonatomic, assign) int32_t order;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) int32_t tier;
@property (nonatomic, assign) int32_t typeID;

@property (nonatomic, readonly) float totalProgress;
@end

@interface NCPlanetaryExtractorFacility : NCPlanetaryFacility
@property (nonatomic, strong) NSArray* bars;
@property (nonatomic, assign) std::shared_ptr<const dgmpp::ProductionState> currentState;
@property (nonatomic, assign) std::shared_ptr<const dgmpp::ProductionState> nextWasteState;
@property (nonatomic, assign) uint32_t allTimeYield;
@property (nonatomic, assign) uint32_t allTimeWaste;
@property (nonatomic, assign) uint32_t maxProduct;

@property (nonatomic, strong) NCDBInvType* productType;
@property (nonatomic, readonly) NSTimeInterval cycleTime;
@property (nonatomic, readonly) NSTimeInterval currentCycleTime;
@property (nonatomic, readonly) NSTimeInterval depletionTime;
@property (nonatomic, readonly) uint32_t sum;
@property (nonatomic, readonly) uint32_t yield;
@property (readonly) BOOL expired;
@property (readonly) NSString* depletion;
@property (readonly) NSString* wasteTitle;
@property (readonly) NSString* wasteTime;
@property (readonly) NSString* waste;
@end

@interface NCPlanetaryStorageFacility : NCPlanetaryFacility
@property (nonatomic, assign) std::shared_ptr<const dgmpp::State> currentState;
@property (nonatomic, strong) NSArray* bars;
@property (readonly) NSString* depletion;
@property (readonly) BOOL expired;
@end

@interface NCPlanetaryFactoryFacility : NCPlanetaryFacility {
	std::map<dgmpp::TypeID, uint32_t> _ratio;
	std::map<dgmpp::TypeID, double> _shortageTime;
	std::list<std::shared_ptr<dgmpp::IndustryFacility>> _factories;
}

@property (nonatomic, assign) double productionTime;
@property (nonatomic, assign) double idleTime;
@property (nonatomic, assign) double extrapolatedProductionTime;
@property (nonatomic, assign) double extrapolatedIdleTime;
@property (nonatomic, assign) std::map<dgmpp::TypeID, uint32_t>& ratio;
@property (nonatomic, assign) std::list<std::shared_ptr<dgmpp::IndustryFacility>>& factories;
@property (nonatomic, assign) std::shared_ptr<const dgmpp::ProductionState> lastState;
@property (nonatomic, strong) NCDBInvType* productType;
@property (nonatomic, strong) NSDictionary* resources;

@property (readonly) float efficiency;
@property (readonly) float extrapolatedEfficiency;

@end


@interface NCPlanetaryData : NSObject<NSCoding>
@property (strong) NSArray* colonies;
- (void) load;
@end

@interface NCPlanetaryColony : NCPlanetaryNode<NSCoding>
@property (strong) EVEPlanetaryColoniesItem* colony;
@property (strong) EVEPlanetaryPins* pins;
@property (strong) EVEPlanetaryRoutes* routes;
@property (strong) NSArray* facilities;
@property (assign) BOOL warning;
@property (assign) BOOL halted;
@property (readonly) NSTimeInterval serverTimestamp;

- (void) loadWithEngine:(NCFittingEngine*) engine;
@end

@implementation NCPlanetaryData

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.colonies = [aDecoder decodeObjectForKey:@"colonies"];
		[self load];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.colonies forKey:@"colonies"];
}

- (void) load {
	NCFittingEngine* engine = [NCFittingEngine new];
	for (NCPlanetaryColony* colony in self.colonies) {
		[colony loadWithEngine:engine];
	}
}

@end

@implementation NCPlanetaryColony

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.colony = [aDecoder decodeObjectForKey:@"colony"];
		self.pins = [aDecoder decodeObjectForKey:@"pins"];
		self.routes = [aDecoder decodeObjectForKey:@"routes"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.colony forKey:@"colony"];
	[aCoder encodeObject:self.pins forKey:@"pins"];
	[aCoder encodeObject:self.routes forKey:@"routes"];
}

- (void) loadWithEngine:(NCFittingEngine*) engine {
	auto planet = engine.engine->setPlanet(self.colony.planetTypeID);
	
	for (EVEPlanetaryPinsItem* pin in self.pins.pins) {
		try {
			auto facility = planet->findFacility(pin.pinID);
			if (!facility) {
				facility = planet->addFacility(pin.typeID, pin.pinID);
				switch (facility->getGroupID()) {
					case dgmpp::ExtractorControlUnit::GROUP_ID: {
						auto ecu = std::dynamic_pointer_cast<dgmpp::ExtractorControlUnit>(facility);
						ecu->setLaunchTime([pin.lastLaunchTime timeIntervalSinceReferenceDate]);
						ecu->setInstallTime([pin.installTime timeIntervalSinceReferenceDate]);
						ecu->setExpiryTime([pin.expiryTime timeIntervalSinceReferenceDate]);
						ecu->setCycleTime(pin.cycleTime * 60);
						ecu->setQuantityPerCycle(pin.quantityPerCycle);
						break;
					}
					case dgmpp::IndustryFacility::GROUP_ID: {
						auto factory = std::dynamic_pointer_cast<dgmpp::IndustryFacility>(facility);
						factory->setLaunchTime([pin.lastLaunchTime timeIntervalSinceReferenceDate]);
						factory->setSchematic(pin.schematicID);
						break;
					}
					default:
						break;
				}
			}
			
			if (pin.contentQuantity > 0 && pin.contentTypeID)
				facility->addCommodity(pin.contentTypeID, pin.contentQuantity);
		} catch (...) {}
	}
	for (EVEPlanetaryRoutesItem* route in self.routes.routes) {
		auto source = planet->findFacility(route.sourcePinID);
		auto destination = planet->findFacility(route.destinationPinID);
		if (source && destination)
			planet->addRoute(source, destination, dgmpp::Commodity(engine.engine, route.contentTypeID, route.quantity), route.routeID);
	}
	planet->setLastUpdate([self.colony.lastUpdate timeIntervalSinceReferenceDate]);
	planet->simulate();
	
	
	NSTimeInterval serverTime = [[self.pins.eveapi serverTimeWithLocalTime:[NSDate date]] timeIntervalSinceReferenceDate];
	
	NSMutableArray* facilities = [NSMutableArray new];
	NSMutableDictionary* factories = [NSMutableDictionary new];
	NSMutableArray* chartRows = [NSMutableArray new];
	
	NSColor* green = [NSColor colorWithRed:0 green:0.6 blue:0 alpha:1];
	NSColor* red = [NSColor colorWithRed:0.8 green:0 blue:0 alpha:1];

	for (const auto& facility: planet->getFacilities()) {
		size_t numberOfStates = facility->numberOfStates();
		
		EVEPlanetaryPinsItem* pin =  [[self.pins.pins filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pinID == %qi", facility->getIdentifier()]] lastObject];
		
		switch (facility->getGroupID()) {
			case dgmpp::ExtractorControlUnit::GROUP_ID: {
				NSMutableArray* segments = [NSMutableArray new];
				NCPlanetaryExtractorFacility* row = [NCPlanetaryExtractorFacility new];
				row.pinName = [NSString stringWithCString:facility->getFacilityName().c_str() encoding:NSUTF8StringEncoding];
				row.facility = facility;
				auto ecu = std::dynamic_pointer_cast<dgmpp::ExtractorControlUnit>(facility);
				
				double startTime = ecu->getInstallTime();
				double cycleTime = ecu->getCycleTime();
				
				if (numberOfStates > 0) {
					uint32_t allTimeYield = 0;
					uint32_t allTimeWaste = 0;
					
					auto firstState = ecu->getStates().front();
					startTime = firstState->getTimestamp();
					double maxH = 0;
					for(double time = ecu->getInstallTime(); time < firstState->getTimestamp(); time += cycleTime) {
						double yield = ecu->getYieldAtTime(time);
						maxH = std::max(yield, maxH);
						allTimeYield += yield;
					}
					
					std::shared_ptr<const dgmpp::ProductionState> lastState;
					std::shared_ptr<const dgmpp::ProductionState> firstWasteState;
					for (const auto& state: ecu->getStates()) {
						auto ecuState = std::dynamic_pointer_cast<const dgmpp::ProductionState>(state);
						auto ecuCycle = ecuState->getCurrentCycle();
						
						if (!row.currentState && serverTime < ecuState->getTimestamp())
							row.currentState = lastState;
						
						if (ecuCycle) {
							auto yield = ecuCycle->getYield().getQuantity();
							auto waste = ecuCycle->getWaste().getQuantity();
							auto launchTime = ecuState->getTimestamp();
							
							NCBarChartSegment* segment = [NCBarChartSegment new];
							segment.color0 = green;
							segment.color1 = red;
							segment.x = launchTime;
							segment.w = cycleTime;
							segment.h0 = yield;
							segment.h1 = waste;
							maxH = std::max(segment.h0 + segment.h1, maxH);
							[segments addObject:segment];
							
							allTimeYield += yield;
							allTimeWaste += waste;
							
							if (waste > 0 && !firstWasteState && launchTime > serverTime)
								firstWasteState = ecuState;
							
						}
						lastState = ecuState;
					}
					
					if (maxH > 0) {
						for (NCBarChartSegment* segment in segments) {
							segment.h0 /= maxH;
							segment.h1 /= maxH;
						}
					}
					
					row.nextWasteState = firstWasteState;
					row.allTimeYield = allTimeYield;
					row.allTimeWaste = allTimeWaste;
					row.startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:startTime];
					if (lastState)
						row.endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:lastState->getTimestamp()];
					else
						row.endDate = row.startDate;
					
					row.bars = segments;
					row.maxProduct = maxH;
					[chartRows addObject:row];
				}
				row.pin = pin;
				row.order = 0;
				row.active = segments.count > 0;
				row.typeID = ecu->getOutput().getTypeID();
				[facilities addObject:row];
				break;
			}
			case dgmpp::IndustryFacility::GROUP_ID: {
				auto factory = std::dynamic_pointer_cast<dgmpp::IndustryFacility>(facility);
				if (factory->routed()) {
					auto schematic = factory->getSchematic();
					NCPlanetaryFactoryFacility* row = factories[@(schematic->getSchematicID())];
					if (!row) {
						row = [NCPlanetaryFactoryFacility new];
						row.pinName = [NSString stringWithCString:facility->getFacilityName().c_str() encoding:NSUTF8StringEncoding];
						row.order = 2;
						row.active = NO;
						row.tier = factory->getOutput().getTier();
						row.typeID = factory->getOutput().getTypeID();
						row.pin = pin;
						factories[@(schematic->getSchematicID())] = row;
						[facilities addObject:row];
					}
					row.factories.push_back(factory);
					
					std::shared_ptr<const dgmpp::ProductionState> lastProductionState;
					std::shared_ptr<const dgmpp::ProductionState> firstProductionState;
					std::shared_ptr<const dgmpp::ProductionState> lastState;
					std::shared_ptr<const dgmpp::ProductionState> currentState;
					double extrapolatedEfficiency = -1;
					
					for (const auto& state: factory->getStates()) {
						auto factoryState = std::dynamic_pointer_cast<const dgmpp::ProductionState>(state);
						auto factoryCycle = factoryState->getCurrentCycle();
						
						if (!currentState && serverTime < factoryState->getTimestamp())
							currentState = lastState;
						
						if (factoryCycle && factoryCycle->getLaunchTime() == factoryState->getTimestamp()) {
							if (!firstProductionState)
								firstProductionState = factoryState;
							lastState = nullptr;
							extrapolatedEfficiency = -1;
						}
						else if (!factoryCycle) {
							if (!lastState)
								lastState = factoryState;
							extrapolatedEfficiency = factoryState->getEfficiency();
						}
					}
					if (!currentState)
						currentState = lastState;
					
					double duration = firstProductionState && currentState ? currentState->getTimestamp() - firstProductionState->getTimestamp() : 0;
					double extrapolatedDuration = firstProductionState && lastState ? lastState->getTimestamp() - firstProductionState->getTimestamp() : 0;
					if (duration < 0)
						duration = 0;
					
					double productionTime = currentState ? currentState->getEfficiency() * duration : 0;
					row.productionTime += productionTime;
					row.idleTime += duration - productionTime;
					
					double extrapolatedProductionTime = lastState ? lastState->getEfficiency() * extrapolatedDuration : 0;
					row.extrapolatedProductionTime += extrapolatedProductionTime;
					row.extrapolatedIdleTime += extrapolatedDuration - extrapolatedProductionTime;
					if (extrapolatedProductionTime > 0)
						row.active = YES;
					
					for (const auto& input: factory->getInputs()) {
						auto incomming = input->getSource()->getIncomming(input->getCommodity());
						row.ratio[incomming.getTypeID()] += incomming.getQuantity();
					}
					if (lastState) {
						if (!row.lastState)
							row.lastState = lastState;
						else if (row.lastState->getTimestamp() < lastState->getTimestamp())
							row.lastState = lastState;
					}
				}
				break;
			}
			case dgmpp::StorageFacility::GROUP_ID:
			case dgmpp::CommandCenter::GROUP_ID:
			case dgmpp::Spaceport::GROUP_ID: {
				NSMutableArray* segments = [NSMutableArray new];
				NCPlanetaryStorageFacility* row = [NCPlanetaryStorageFacility new];
				row.pinName = [NSString stringWithCString:facility->getFacilityName().c_str() encoding:NSUTF8StringEncoding];
				row.facility = facility;
				auto storage = std::dynamic_pointer_cast<dgmpp::StorageFacility>(facility);
				
				std::shared_ptr<const dgmpp::State> firstState;
				std::shared_ptr<const dgmpp::State> lastState;
				double capacity = storage->getCapacity();
				if (capacity > 0) {
					NCBarChartSegment* prevSegment;
					double timestamp = 0;
					for (const auto& state: storage->getStates()) {
						timestamp = state->getTimestamp();
						
						if (!row.currentState && serverTime < timestamp)
							row.currentState = lastState;
						
						NCBarChartSegment* segment = [NCBarChartSegment new];
						segment.color0 = green;
						segment.color1 = red;
						segment.x = timestamp;
						segment.h0 = state->getVolume() / capacity;
						[segments addObject:segment];
						
						prevSegment.w = timestamp - prevSegment.x;
						if (!firstState)
							firstState = state;
						
						lastState = state;
						prevSegment = segment;
					}
					prevSegment.w = std::numeric_limits<double>::infinity();
					
					if (!row.currentState)
						row.currentState = lastState;
				}
				
				
				row.startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:firstState ? firstState->getTimestamp() : serverTime];
				if (lastState)
					row.endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:lastState->getTimestamp() > serverTime ? lastState->getTimestamp() : serverTime];
				else
					row.endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:serverTime];
				
				/*NSTimeInterval duration = [row.endDate timeIntervalSinceDate:row.startDate];
				 NSTimeInterval startTime = [row.startDate timeIntervalSinceReferenceDate];
				 if (duration > 0) {
				 for (NCBarChartSegment* segment in segments) {
				 segment.x = (segment.x - startTime) / duration;
				 segment.w /= duration;
				 }
				 }*/
				row.order = 1;
				row.active = segments.count > 1 || (segments.count > 0 && storage->getVolume() > 0);
				row.pin = pin;
				row.bars = segments;
				[facilities addObject:row];
				[chartRows addObject:row];
				
				break;
			}
			default:
				break;
		}
	}
	[facilities sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES],
									   [NSSortDescriptor sortDescriptorWithKey:@"active" ascending:NO],
									   [NSSortDescriptor sortDescriptorWithKey:@"tier" ascending:NO],
									   [NSSortDescriptor sortDescriptorWithKey:@"typeID" ascending:YES]]];
	
	NSDate* globalStart = [chartRows valueForKeyPath:@"@min.startDate"];
	NSDate* globalEnd = [chartRows valueForKeyPath:@"@max.endDate"];
	NSTimeInterval duration = [globalEnd timeIntervalSinceDate:globalStart];
	NSTimeInterval startTime = [globalStart timeIntervalSinceReferenceDate];
	if (duration > 0) {
		for (id row in [chartRows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"active==YES"]]) {
			[row setStartDate:globalStart];
			[row setEndDate:globalEnd];
			NSArray* segments = [row bars];
			for (NCBarChartSegment* segment in segments) {
				segment.x = (segment.x - startTime) / duration;
				if (std::isinf(segment.w))
					segment.w = 1.0 - segment.x;
				else
					segment.w /= duration;
			}
		}
	}
	
	BOOL halted = YES;
	for (NCPlanetaryFacility* row in facilities) {
		if ([row isKindOfClass:[NCPlanetaryExtractorFacility class]]) {
			NCPlanetaryExtractorFacility* extractorRow = (NCPlanetaryExtractorFacility*) row;
			auto ecu = std::dynamic_pointer_cast<const dgmpp::ExtractorControlUnit>(extractorRow.facility);
			if (ecu) {
				if (extractorRow.nextWasteState || ecu->getExpiryTime() - serverTime < 3600 * 24)
					self.warning = YES;
				if (ecu->getExpiryTime() > serverTime)
					halted = NO;
			}
		}
		else if ([row isKindOfClass:[NCPlanetaryFactoryFacility class]]) {
			NCPlanetaryFactoryFacility* factoryRow = (NCPlanetaryFactoryFacility*) row;
			if (factoryRow.lastState) {
				if (factoryRow.lastState->getTimestamp() - serverTime < 3600 * 24)
					self.warning = YES;
				if (factoryRow.lastState->getTimestamp() > serverTime)
					halted = NO;
			}
		}
	}
	[facilities filterUsingPredicate:[NSPredicate predicateWithFormat:@"active==YES"]];
	if (halted) {
		self.warning = YES;
		self.halted = halted;
	}
	[facilities setValue:self forKey:@"colony"];
	self.facilities = facilities;
}

- (NSArray*) children {
	return self.facilities;
}

- (NSAttributedString*) title {
	if (self.halted)
		return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"%@ (colony production has halted)", nil), self.colony.planetName] attributes:nil];
	else if (self.warning)
		return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"%@ (warning)", nil), self.colony.planetName] attributes:nil];
	else
		return [[NSAttributedString alloc] initWithString:self.colony.planetName attributes:nil];
}

- (NSImage*) image {
	return nil;
}

- (NSTimeInterval) serverTimestamp {
	NSDate* serverTime = [self.pins.eveapi serverTimeWithLocalTime:[NSDate date]];
	return [serverTime timeIntervalSinceReferenceDate];
}

@end

@implementation NCPlanetaryFacility

- (NSAttributedString*) title {
	if (self.pin.typeName){
		NSMutableAttributedString* s = [[NSMutableAttributedString alloc] initWithString:self.pin.typeName attributes:nil];
		[s appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:nil]];
		//[s appendAttributedString:[[NSAttributedString alloc] initWithString:self.pinName attributes:@{(__bridge NSString*)kCTFontTraitsAttribute:@{(__bridge NSString*)kCTFontSymbolicTrait:@(kCTFontBoldTrait)}}]];
		[s appendAttributedString:[[NSAttributedString alloc] initWithString:self.pinName attributes:@{NSFontAttributeName:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]]}]];
		return s;
	}
	else
		return self.pinName ? [[NSAttributedString alloc] initWithString:self.pinName attributes:nil] : nil;
}

- (float) totalProgress {
	NSTimeInterval duration = [self.endDate timeIntervalSinceDate:self.startDate];
	NSTimeInterval time = self.colony.serverTimestamp - [self.startDate timeIntervalSinceReferenceDate];
	return time <= 0 || duration <= 0 ? 0 : time / duration;
}

@end


@implementation NCPlanetaryExtractorFacility

- (NCDBInvType*) productType {
	if (!_productType) {
		auto ecu = std::dynamic_pointer_cast<const dgmpp::ExtractorControlUnit>(self.facility);
		auto contentTypeID = ecu->getOutput().getTypeID();
		_productType = [[[NCDatabase sharedDatabase] managedObjectContext] invTypeWithTypeID:contentTypeID];
	}
	return _productType;
}

- (NSTimeInterval) cycleTime {
	auto ecu = std::dynamic_pointer_cast<const dgmpp::ExtractorControlUnit>(self.facility);
	return ecu->getCycleTime();
}

- (NSTimeInterval) currentCycleTime {
	if (self.currentState && self.currentState->getCurrentCycle()) {
		auto ecu = std::dynamic_pointer_cast<const dgmpp::ExtractorControlUnit>(self.facility);
		
		auto cycle = self.currentState->getCurrentCycle();
		int32_t cycleTime = cycle->getCycleTime();
		int32_t start = cycle->getLaunchTime();
		int32_t currentTime = self.colony.serverTimestamp;
		int32_t c = std::max(std::min(static_cast<int32_t>(currentTime), start + cycleTime), start) - start;
		return c;
	}
	else
		return 0;
}

- (NSTimeInterval) depletionTime {
	if (self.currentState && self.currentState->getCurrentCycle()) {
		auto ecu = std::dynamic_pointer_cast<const dgmpp::ExtractorControlUnit>(self.facility);
		return ecu->getExpiryTime() - self.colony.serverTimestamp;
	}
	else
		return 0;
}

- (BOOL) expired {
	return self.depletionTime <= 0;
}

- (NSString*) wasteTitle {
	if (self.nextWasteState || self.allTimeWaste > 0) {
		NSTimeInterval after = self.nextWasteState ? self.nextWasteState->getTimestamp() - self.colony.serverTimestamp : 0;
		if (after > 0)
			return NSLocalizedString(@"Waste in", nil);
		else
			return NSLocalizedString(@"Waste", nil);
	}
	return nil;
}

- (NSString*) wasteTime {
	if (self.nextWasteState || self.allTimeWaste > 0) {
		NSTimeInterval after = self.nextWasteState ? self.nextWasteState->getTimestamp() - self.colony.serverTimestamp : 0;
		if (after > 0)
			return [NSString stringWithTimeLeft:after];
	}
	return nil;
}

- (NSString*) waste {
	if (self.nextWasteState || self.allTimeWaste > 0) {
		return [NSString stringWithFormat:NSLocalizedString(@"(%.0f%%)", nil),
				static_cast<double>(self.allTimeWaste) / (self.allTimeWaste + self.allTimeYield) * 100];
	}
	return nil;
}

- (NSString*) depletion {
	NSTimeInterval depletionTime = self.depletionTime;
	if (depletionTime > 0)
		return [NSString stringWithTimeLeft:depletionTime];
	else
		return NSLocalizedString(@"Depleted", nil);
}

- (uint32_t) sum {
	return self.allTimeYield + self.allTimeWaste;
}

- (uint32_t) yield {
	auto ecu = std::dynamic_pointer_cast<const dgmpp::ExtractorControlUnit>(self.facility);
	NSTimeInterval duration = ecu->getExpiryTime() - ecu->getInstallTime();
	return self.sum / (duration / 3600);
}


@end

@implementation NCPlanetaryStorageFacility

- (NSString*) depletion {
	NSTimeInterval remainsTime = [self.endDate timeIntervalSinceReferenceDate] - self.colony.serverTimestamp;
	if (remainsTime > 0)
		return [NSString stringWithTimeLeft:remainsTime];
	else
		return NSLocalizedString(@"Finished", nil);
}

- (BOOL) expired {
	return self.colony.serverTimestamp > [self.endDate timeIntervalSinceReferenceDate];
}


@end


@implementation NCPlanetaryFactoryFacility

- (float) efficiency {
	return self.productionTime + self.idleTime > 0 ? self.productionTime / (self.productionTime + self.idleTime) : 0;
}

- (float) extrapolatedEfficiency {
	return self.extrapolatedProductionTime + self.extrapolatedIdleTime > 0 ? self.extrapolatedProductionTime / (self.extrapolatedProductionTime + self.extrapolatedIdleTime) : 0;
}

- (NCDBInvType*) productType {
	if (!_productType)
		_productType = [[[NCDatabase sharedDatabase] managedObjectContext] invTypeWithTypeID:self.factories.front()->getOutput().getTypeID()];
	return _productType;
}

- (NSDictionary*) resources {
	if (!_resources) {
		NSMutableArray* requiredResources = [NSMutableArray new];
		NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
		
		NSTimeInterval serverTimestamp = self.colony.serverTimestamp;
		
		double p = 0;
		for (const auto& i: self.ratio) {
			if (i.second > 0)
				p = std::max(p, 1.0 / i.second);
		}
		
		if (self.lastState) {
			auto factory = self.factories.front();
			for (const auto& i: factory->getSchematic()->getInputs()) {
				bool depleted = true;
				for (const auto& j: self.lastState->getCommodities()) {
					if (i.getTypeID() == j.getTypeID()) {
						if (i.getQuantity() == j.getQuantity())
							depleted = false;
						break;
					}
				}
				
				NCDBInvType* type = [context invTypeWithTypeID:i.getTypeID()];
				if (type) {
					NCPlanetaryFactoryResource* resource = [NCPlanetaryFactoryResource new];
					resource.type = type;
					resource.depleted = depleted;
					resource.ratio = std::round(self.ratio[i.getTypeID()] * p * 10) / 10;
					[requiredResources addObject:resource];
					
					if (depleted) {
						double shortage = self.lastState->getTimestamp() - serverTimestamp;
						if (shortage <= 0)
							resource.shortage = NSLocalizedString(@"depleted", nil);
						else
							resource.shortage = [NSString stringWithFormat:NSLocalizedString(@"shortage in %@", nil), [NSString stringWithTimeLeft:shortage]];
					}
				}
			}
		}
		[requiredResources sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"type.typeName" ascending:YES]]];
		NSMutableDictionary* resources = [NSMutableDictionary new];
		for (id value in requiredResources)
			resources[[NSString stringWithFormat:@"%ld", (long)resources.count]] = value;
		_resources = resources;
	}
	return _resources;
}

- (NSImage*) image {
	NCDBInvType* type = [[[NCDatabase sharedDatabase] managedObjectContext] invTypeWithTypeID:self.pin.typeID];
	return type.icon.image.image ?: [[[NCDatabase sharedDatabase] managedObjectContext] defaultTypeIcon].image.image;

}

- (NSAttributedString*) title {
	NSAttributedString* title = [super title];
	if (self.factories.size() > 1) {
		NSMutableAttributedString* s = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ldx ", self.factories.size()] attributes:nil];
		[s appendAttributedString:title];
		return s;
	}
	else
		return title;
}


@end


@interface NCPlanetariesViewController ()<NSOutlineViewDelegate>
@property (nonatomic, strong) NCAccount* account;
@property (nonatomic, strong) NCCacheRecord* coloniesCacheRecord;
- (void) didChangeAccount:(NSNotification*) note;

@end

@implementation NCPlanetariesViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAccount:) name:NCDidChangeAccountNotification object:nil];
	self.account = [NCAccount currentAccount];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSView*) outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	if ([[item representedObject] isKindOfClass:[NCPlanetaryFactoryFacility class]]) {
		return [outlineView makeViewWithIdentifier:@"FactoryCell" owner:nil];
	}
	else if ([[item representedObject] isKindOfClass:[NCPlanetaryExtractorFacility class]]) {
		NCPlanetaryExtractorFacility* extractor = [item representedObject];
		NCPlanetaryExtractorCell* cell = [outlineView makeViewWithIdentifier:@"ExtractorCell" owner:nil];
		[cell.barChartView clear];
		[cell.barChartView addSegments:extractor.bars];
		cell.barChartView.markerPosition = extractor.totalProgress;
		
		[cell.markerAuxiliaryView.superview removeConstraint:cell.markerAuxiliaryViewConstraint];
		id constraint = [NSLayoutConstraint constraintWithItem:cell.markerAuxiliaryView
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:cell.markerAuxiliaryView.superview
													 attribute:NSLayoutAttributeWidth
													multiplier:extractor.totalProgress
													  constant:0];
		[cell.markerAuxiliaryView.superview addConstraint:constraint];
		cell.markerAuxiliaryViewConstraint = constraint;
		return cell;
	}
	else if ([[item representedObject] isKindOfClass:[NCPlanetaryStorageFacility class]]) {
		NCPlanetaryStorageFacility* storage = [item representedObject];
		NCPlanetaryStorageCell* cell = [outlineView makeViewWithIdentifier:@"StorageCell" owner:nil];
		[cell.barChartView clear];
		[cell.barChartView addSegments:storage.bars];
		cell.barChartView.markerPosition = storage.totalProgress;

		
		for (NSView* view in [cell.resourcesStackView views])
			[cell.resourcesStackView removeView:view];
		for (NSView* view in [cell.quantitiesStackView views])
			[cell.quantitiesStackView removeView:view];
		for (NSView* view in [cell.unitsStackView views])
			[cell.unitsStackView removeView:view];
		
		auto storageFacility = std::dynamic_pointer_cast<const dgmpp::StorageFacility>(storage.facility);
		
		if (storage.currentState) {

			double capacity = storageFacility->getCapacity();
			if (capacity > 0) {
				double volume = 0;
				
				std::list<const dgmpp::Commodity> commodities;
				
				if (storage.currentState) {
					volume = storage.currentState->getVolume();
					std::copy(storage.currentState->getCommodities().begin(), storage.currentState->getCommodities().end(), std::inserter(commodities, commodities.begin()));
				}
				else {
					volume = storageFacility->getVolume();
					commodities = storageFacility->getCommodities();
				}
				
				NSMutableArray* components = [NSMutableArray new];
				
				NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
				for (const auto& commodity: commodities) {
					NCDBInvType* type = [context invTypeWithTypeID:commodity.getTypeID()];
					if (type.typeName)
						[components addObject:@{@"typeName":type.typeName, @"quantity":@(commodity.getQuantity())}];
				}
				[components sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"typeName" ascending:YES]]];

				for (NSDictionary* component in components) {
					NSTextField* title = [[NSTextField alloc] initWithFrame:CGRectZero];
					title.editable = NO;
					title.selectable = NO;
					title.textColor = [NSColor blackColor];
					title.bordered = NO;
					[title setStringValue:component[@"typeName"]];
					[title sizeToFit];
					[cell.resourcesStackView addView:title inGravity:NSStackViewGravityBottom];

					NSTextField* value = [[NSTextField alloc] initWithFrame:CGRectZero];
					value.editable = NO;
					value.selectable = NO;
					value.textColor = [NSColor blackColor];
					value.bordered = NO;
					[value setStringValue:[NSNumberFormatter neocomLocalizedStringFromInteger:[component[@"quantity"] integerValue]]];
					[value sizeToFit];
					[cell.quantitiesStackView addView:value inGravity:NSStackViewGravityBottom];

					NSTextField* unit = [[NSTextField alloc] initWithFrame:CGRectZero];
					unit.editable = NO;
					unit.selectable = NO;
					unit.textColor = [NSColor blackColor];
					unit.bordered = NO;
					[unit setStringValue:NSLocalizedString(@"units", nil)];
					[unit sizeToFit];
					[cell.unitsStackView addView:unit inGravity:NSStackViewGravityBottom];
				}
			}
		}
		
		[cell.markerAuxiliaryView.superview removeConstraint:cell.markerAuxiliaryViewConstraint];
		id constraint = [NSLayoutConstraint constraintWithItem:cell.markerAuxiliaryView
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:cell.markerAuxiliaryView.superview
													 attribute:NSLayoutAttributeWidth
													multiplier:storage.totalProgress
													  constant:0];
		[cell.markerAuxiliaryView.superview addConstraint:constraint];
		cell.markerAuxiliaryViewConstraint = constraint;
		return cell;
	}

	return [outlineView makeViewWithIdentifier:@"Cell" owner:nil];
}

- (CGFloat) outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
	if ([[item representedObject] isKindOfClass:[NCPlanetaryFactoryFacility class]])
		return 74;
	else if ([[item representedObject] isKindOfClass:[NCPlanetaryExtractorFacility class]])
		return 106;
	else if ([[item representedObject] isKindOfClass:[NCPlanetaryStorageFacility class]])
		return 106;
	else
		return 17;
}

#pragma mark - Private

- (void) reload {
	NCCacheRecord* cacheRecord = self.coloniesCacheRecord;
	self.colonies.content = [(NCPlanetaryData*) cacheRecord.data.data colonies];
	for (id item in [self.colonies.arrangedObjects childNodes])
		[self.outlineView expandItem:item expandChildren:YES];

	if (self.account && !self.account.corporate && ([cacheRecord isExpired] || !cacheRecord.data.data)) {
		EVEOnlineAPI* api = [EVEOnlineAPI apiWithAPIKey:[EVEAPIKey apiKeyWithKeyID:self.account.apiKey.keyID vCode:self.account.apiKey.vCode characterID:self.account.characterID corporate:self.account.corporate] cachePolicy:NSURLRequestUseProtocolCachePolicy];
		
		[api planetaryColoniesWithCompletionBlock:^(EVEPlanetaryColonies *result, NSError *error) {
			if (result) {
				NSMutableArray* array = [NSMutableArray new];
				dispatch_group_t finishDispatchGroup = dispatch_group_create();
				
				for (EVEPlanetaryColoniesItem* item in result.colonies) {
					NCPlanetaryColony* colony = [NCPlanetaryColony new];
					colony.colony = item;
					
					dispatch_group_enter(finishDispatchGroup);
					[api planetaryPinsWithPlanetID:item.planetID completionBlock:^(EVEPlanetaryPins *pins, NSError *error) {
						if (pins) {
							NSMutableDictionary* facilities = [NSMutableDictionary new];
							for (EVEPlanetaryPinsItem* pin in pins.pins) {
								facilities[@(pin.pinID)] = pin;
							}
							colony.facilities = [facilities allValues];
							colony.pins = pins;
							[array addObject:colony];
							dispatch_group_leave(finishDispatchGroup);
						}
					} progressBlock:nil];
					
					dispatch_group_enter(finishDispatchGroup);
					[api planetaryRoutesWithPlanetID:item.planetID
									 completionBlock:^(EVEPlanetaryRoutes *routes, NSError *error) {
										 colony.routes = routes;
										 dispatch_group_leave(finishDispatchGroup);
									 } progressBlock:nil];
					
				}
				
				dispatch_group_notify(finishDispatchGroup, dispatch_get_main_queue(), ^{
					[array sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"colony.planetName" ascending:YES]]];
					NCPlanetaryData* data = [NCPlanetaryData new];
					data.colonies = array;
					[data load];
					cacheRecord.date = [NSDate date];
					cacheRecord.expireDate = [result.eveapi localTimeWithServerTime:result.eveapi.cachedUntil];
					cacheRecord.data.data = data;
					if ([cacheRecord.managedObjectContext hasChanges])
						[cacheRecord.managedObjectContext save:nil];
					self.colonies.content = array;
					if ([cacheRecord.managedObjectContext hasChanges])
						[cacheRecord.managedObjectContext save:nil];
					for (id item in [self.colonies.arrangedObjects childNodes])
						[self.outlineView expandItem:item expandChildren:YES];
					
				});
			}
		} progressBlock:nil];
	}
}

- (void) didChangeAccount:(NSNotification*) note {
	NCAccount* account = note.object;
	self.account = account && !account.corporate ? account : nil;
}

- (void) setAccount:(NCAccount *)account {
	_account = account;
	self.coloniesCacheRecord = nil;
	[self reload];
}

- (NCCacheRecord*) coloniesCacheRecord {
	if (!_coloniesCacheRecord) {
		_coloniesCacheRecord = self.account ? [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.%@", NSStringFromClass(self.class), self.account.uuid]] : nil;
	}
	return _coloniesCacheRecord;
}


@end
