//
//  NCShipFitController.m
//  Neocom
//
//  Created by Artem Shimanski on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCShipFitController.h"
#import "NCShipFit.h"
#import "NCDatabase.h"

@implementation NCShipModule

- (NSImage*) slotImage {
	switch (self.slot) {
		case dgmpp::Module::SLOT_HI:
			return [NSImage imageNamed:@"slotHigh"];
		case dgmpp::Module::SLOT_MED:
			return [NSImage imageNamed:@"slotMed"];
		case dgmpp::Module::SLOT_LOW:
			return [NSImage imageNamed:@"slotLow"];
		case dgmpp::Module::SLOT_RIG:
			return [NSImage imageNamed:@"slotRig"];
		case dgmpp::Module::SLOT_SUBSYSTEM:
			return [NSImage imageNamed:@"slotSubsystem"];
		case dgmpp::Module::SLOT_MODE:
			return [NSImage imageNamed:@"slotRig"];
  default:
			return nil;
			break;
	}
}

- (NSImage*) typeImage {
	if (self.module) {
		NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
		NCDBInvType* type = [context invTypeWithTypeID:self.module->getTypeID()];
		return type.icon.image.image ?: [context defaultTypeIcon].image.image;
	}
	else
		return nil;
}

- (NSString*) title {
	if (self.module) {
		NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
		NCDBInvType* type = [context invTypeWithTypeID:self.module->getTypeID()];
		return type.typeName ?: NSLocalizedString(@"Unknown Type", nil);
	}
	else {
		switch (self.slot) {
			case dgmpp::Module::SLOT_HI:
				return NSLocalizedString(@"Hi Slot", nil);
			case dgmpp::Module::SLOT_MED:
				return NSLocalizedString(@"Med Slot", nil);
			case dgmpp::Module::SLOT_LOW:
				return NSLocalizedString(@"Low Slot", nil);
			case dgmpp::Module::SLOT_RIG:
				return NSLocalizedString(@"Rig Slot", nil);
			case dgmpp::Module::SLOT_SUBSYSTEM:
				return NSLocalizedString(@"Subsystem Slot", nil);
			case dgmpp::Module::SLOT_MODE:
				return NSLocalizedString(@"Mode", nil);
			default:
				return nil;
				break;
		}
	}
}

- (NSImage*) ammoImage {
	return nil;
}

- (NSString*) ammoName {
	return nil;
}

@end

@implementation NCShipFitController

- (void) setContent:(id)content {
	[self willChangeValueForKey:@"modules"];
	[super setContent:content];
	[self didChangeValueForKey:@"modules"];
}

- (NSArray*) modules {
	NCShipFit* fit = self.content;
	NSMutableArray* array = [NSMutableArray new];
	if (fit.pilot) {
		auto ship = fit.pilot->getShip();
		if (ship) {
			dgmpp::Module::Slot slots[] = {dgmpp::Module::SLOT_MODE, dgmpp::Module::SLOT_HI, dgmpp::Module::SLOT_MED, dgmpp::Module::SLOT_LOW, dgmpp::Module::SLOT_RIG, dgmpp::Module::SLOT_SUBSYSTEM};
			for (auto slot: slots) {
				dgmpp::ModulesList modules;
				ship->getModules(slot, std::inserter(modules, modules.begin()));
				int n = ship->getNumberOfSlots(slot);
				for (auto module: modules) {
					n--;
					NCShipModule* m = [NCShipModule new];
					m.slot = slot;
					m.module = module;
					[array addObject:m];
				}
				for (; n > 0; n--) {
					NCShipModule* m = [NCShipModule new];
					m.slot = slot;
					[array addObject:m];
				}
			}
		}
	}
	return array;
}

@end