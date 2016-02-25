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
#import "NSString+Neocom.h"

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

- (NSImage*) stateImage {
	if (self.module && (self.slot == dgmpp::Module::SLOT_HI || self.slot == dgmpp::Module::SLOT_MED || self.slot == dgmpp::Module::SLOT_LOW)) {
		switch (self.module->getState()) {
			case dgmpp::Module::STATE_ACTIVE:
				return [NSImage imageNamed:@"active"];
				break;
			case dgmpp::Module::STATE_ONLINE:
				return [NSImage imageNamed:@"online"];
				break;
			case dgmpp::Module::STATE_OVERLOADED:
				return [NSImage imageNamed:@"overheated"];
				break;
			default:
				return [NSImage imageNamed:@"offline"];
				break;
		}
	}
	else
		return nil;
}

- (NSImage*) typeImage {
	if (self.module) {
		return self.item.type.icon.image.image ?: [[[NCDatabase sharedDatabase] managedObjectContext] defaultTypeIcon].image.image;
	}
	else
		return nil;
}

- (NSString*) title {
	if (self.module) {
		return self.item.type.typeName ?: NSLocalizedString(@"Unknown Type", nil);
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
	if (self.module) {
		auto charge = self.module->getCharge();
		if (charge) {
			NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
			NCDBInvType* type = [context invTypeWithTypeID:charge->getTypeID()];
			return type.icon.image.image ?: [context defaultTypeIcon].image.image;
		}
	}
	return nil;
}

- (NSString*) ammoName {
	if (self.module) {
		auto charge = self.module->getCharge();
		if (charge) {
			NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
			NCDBInvType* type = [context invTypeWithTypeID:charge->getTypeID()];
			return type.typeName ?: NSLocalizedString(@"Unknown Type", nil);
		}
	}
	return nil;
}

@end

@implementation NCShipDrone
@synthesize drones = _drones;

- (NSImage*) typeImage {
	if (self.item) {
		return self.item.type.icon.image.image ?: [[[NCDatabase sharedDatabase] managedObjectContext] defaultTypeIcon].image.image;
	}
	else
		return nil;
}

- (NSString*) title {
	if (self.item) {
		return self.item.type.typeName ?: NSLocalizedString(@"Unknown Type", nil);
	}
	else {
		return NSLocalizedString(@"Drone", nil);
	}
}

- (NSInteger) count {
	return self.drones.size();
}


@end

@implementation NCShipStatsResource;

- (id) initWithTotal:(float) total used:(float) used unit:(NSString*) unit {
	if (self = [super init]) {
		self.total = total;
		self.used = used;
		self.free = self.total - self.used;
		self.unit = unit;
	}
	return self;
}

- (id) initWithFree:(float) free used:(float) used unit:(NSString*) unit {
	if (self = [super init]) {
		self.free = free;
		self.used = used;
		self.total = self.free + self.used;
		self.unit = unit;
	}
	return self;
}


- (float) fraction {
	return self.total > 0 ? self.used / self.total : 0;
}

- (NSString*) string {
	return [NSString stringWithTotalResources:self.total usedResources:self.used unit:self.unit];
}

@end

@implementation NCShipStatsDamageLayer;
@end
@implementation NCShipStatsResistances;
@end
@implementation NCShipStatsHP;
@end
@implementation NCShipStatsCapacitor;
@end
@implementation NCShipStatsTank;
@end

@implementation NCShipStats;

- (NCShipStatsResource*) turrets {
	if (!_turrets) {
		_turrets = [[NCShipStatsResource alloc] initWithFree:self.pilot->getShip()->getFreeHardpoints(dgmpp::Module::HARDPOINT_TURRET)
														used:self.pilot->getShip()->getUsedHardpoints(dgmpp::Module::HARDPOINT_TURRET)
														unit:nil];
	}
	return _turrets;
}

- (NCShipStatsResource*) launchers {
	if (!_launchers) {
		_launchers = [[NCShipStatsResource alloc] initWithFree:self.pilot->getShip()->getFreeHardpoints(dgmpp::Module::HARDPOINT_LAUNCHER)
														  used:self.pilot->getShip()->getUsedHardpoints(dgmpp::Module::HARDPOINT_LAUNCHER)
														  unit:nil];
	}
	return _launchers;
}

- (NCShipStatsResource*) calibration {
	if (!_calibration) {
		_calibration = [[NCShipStatsResource alloc] initWithTotal:self.pilot->getShip()->getTotalCalibration()
															 used:self.pilot->getShip()->getCalibrationUsed()
															 unit:nil];
	}
	return _calibration;
}

- (NCShipStatsResource*) drones {
	if (!_drones) {
		_drones = [[NCShipStatsResource alloc] initWithTotal:self.pilot->getShip()->getMaxActiveDrones()
															 used:self.pilot->getShip()->getActiveDrones()
															 unit:nil];
	}
	return _drones;
}

- (NCShipStatsResource*) cpu {
	if (!_cpu) {
		_cpu = [[NCShipStatsResource alloc] initWithTotal:self.pilot->getShip()->getTotalCpu()
														used:self.pilot->getShip()->getCpuUsed()
														unit:NSLocalizedString(@"tf", nil)];
	}
	return _cpu;
}

- (NCShipStatsResource*) powerGrid {
	if (!_powerGrid) {
		_powerGrid = [[NCShipStatsResource alloc] initWithTotal:self.pilot->getShip()->getTotalPowerGrid()
														used:self.pilot->getShip()->getPowerGridUsed()
														unit:NSLocalizedString(@"MW", nil)];
	}
	return _powerGrid;
}

- (NCShipStatsResource*) droneBay {
	if (!_droneBay) {
		_droneBay = [[NCShipStatsResource alloc] initWithTotal:self.pilot->getShip()->getTotalDroneBay()
														   used:self.pilot->getShip()->getDroneBayUsed()
														   unit:NSLocalizedString(@"m3", nil)];
	}
	return _droneBay;
}

- (NCShipStatsResource*) droneBandwidth {
	if (!_droneBandwidth) {
		_droneBandwidth = [[NCShipStatsResource alloc] initWithTotal:self.pilot->getShip()->getTotalDroneBandwidth()
														  used:self.pilot->getShip()->getDroneBandwidthUsed()
														  unit:NSLocalizedString(@"Mbit/s", nil)];
	}
	return _droneBandwidth;
}

- (NCShipStatsResistances*) resistances {
	if (!_resistances) {
		auto resistance = self.pilot->getShip()->getResistances();
		_resistances = [NCShipStatsResistances new];
		
		_resistances.shield = [NCShipStatsDamageLayer new];
		_resistances.shield.em = resistance.shield.em;
		_resistances.shield.thermal = resistance.shield.thermal;
		_resistances.shield.kinetic = resistance.shield.kinetic;
		_resistances.shield.explosive = resistance.shield.explosive;

		_resistances.armor = [NCShipStatsDamageLayer new];
		_resistances.armor.em = resistance.armor.em;
		_resistances.armor.thermal = resistance.armor.thermal;
		_resistances.armor.kinetic = resistance.armor.kinetic;
		_resistances.armor.explosive = resistance.armor.explosive;

		_resistances.hull = [NCShipStatsDamageLayer new];
		_resistances.hull.em = resistance.hull.em;
		_resistances.hull.thermal = resistance.hull.thermal;
		_resistances.hull.kinetic = resistance.hull.kinetic;
		_resistances.hull.explosive = resistance.hull.explosive;
	}
	return _resistances;
}

- (NCShipStatsDamageLayer*) damagePattern {
	if (!_damagePattern) {
		auto damagePattern = self.pilot->getShip()->getDamagePattern();
		_damagePattern = [NCShipStatsDamageLayer new];
		_damagePattern.em = damagePattern.emAmount;
		_damagePattern.thermal = damagePattern.thermalAmount;
		_damagePattern.kinetic = damagePattern.kineticAmount;
		_damagePattern.explosive = damagePattern.explosiveAmount;
	}
	return _damagePattern;
}

- (NCShipStatsHP*) hp {
	if (!_hp) {
		auto hp = self.pilot->getShip()->getHitPoints();
		_hp = [NCShipStatsHP new];
		_hp.shield = hp.shield;
		_hp.armor = hp.armor;
		_hp.hull = hp.hull;
		_hp.total = hp.shield + hp.armor + hp.hull;
	}
	return _hp;
}

- (NCShipStatsHP*) ehp {
	if (!_ehp) {
		auto ehp = self.pilot->getShip()->getEffectiveHitPoints();
		_ehp = [NCShipStatsHP new];
		_ehp.shield = ehp.shield;
		_ehp.armor = ehp.armor;
		_ehp.hull = ehp.hull;
		_ehp.total = ehp.shield + ehp.armor + ehp.hull;
	}
	return _ehp;
}

- (NCShipStatsCapacitor*) capacitor {
	if (!_capacitor) {
		_capacitor = [NCShipStatsCapacitor new];
		auto ship = self.pilot->getShip();
		
		float capCapacity = ship->getCapCapacity();
		bool capStable = ship->isCapStable();
		float capState = capStable ? ship->getCapStableLevel() * 100.0 : ship->getCapLastsTime();
		float capacitorRechargeTime = ship->getAttribute(dgmpp::RECHARGE_RATE_ATTRIBUTE_ID)->getValue() / 1000.0;
		float delta = ship->getCapRecharge() - ship->getCapUsed();
		_capacitor.capacity = capCapacity;
		_capacitor.state = capStable ? [NSString stringWithFormat:NSLocalizedString(@"Stable: %.1f%%", nil), capState] : [NSString stringWithFormat:NSLocalizedString(@"Lasts: %@", nil), [NSString stringWithTimeLeft:capState]];
		_capacitor.rechargeTime = capacitorRechargeTime;
		_capacitor.delta = delta >= 0 ? [NSString stringWithFormat:@"+%@",[NSString shortStringWithFloat:delta unit:nil]] : [NSString shortStringWithFloat:delta unit:nil];
	}
	return _capacitor;
}

- (NCShipStatsTank*) reinforcedTank {
	if (!_reinforcedTank) {
		auto tank = self.pilot->getShip()->getTank();
		_reinforcedTank = [NCShipStatsTank new];
		_reinforcedTank.shieldRecharge = tank.passiveShield;
		_reinforcedTank.shieldBoost = tank.shieldRepair;
		_reinforcedTank.armorRepair = tank.armorRepair;
		_reinforcedTank.hullRepair = tank.hullRepair;
	}
	return _reinforcedTank;
}

- (NCShipStatsTank*) sustainedTank {
	if (!_sustainedTank) {
		auto tank = self.pilot->getShip()->getSustainableTank();
		_sustainedTank = [NCShipStatsTank new];
		_sustainedTank.shieldRecharge = tank.passiveShield;
		_sustainedTank.shieldBoost = tank.shieldRepair;
		_sustainedTank.armorRepair = tank.armorRepair;
		_sustainedTank.hullRepair = tank.hullRepair;
	}
	return _sustainedTank;
}

- (NCShipStatsTank*) effectiveReinforcedTank {
	if (!_effectiveReinforcedTank) {
		auto tank = self.pilot->getShip()->getEffectiveTank();
		_effectiveReinforcedTank = [NCShipStatsTank new];
		_effectiveReinforcedTank.shieldRecharge = tank.passiveShield;
		_effectiveReinforcedTank.shieldBoost = tank.shieldRepair;
		_effectiveReinforcedTank.armorRepair = tank.armorRepair;
		_effectiveReinforcedTank.hullRepair = tank.hullRepair;
	}
	return _effectiveReinforcedTank;
}

- (NCShipStatsTank*) effectiveSustainedTank {
	if (!_effectiveSustainedTank) {
		auto tank = self.pilot->getShip()->getEffectiveSustainableTank();
		_effectiveSustainedTank = [NCShipStatsTank new];
		_effectiveSustainedTank.shieldRecharge = tank.passiveShield;
		_effectiveSustainedTank.shieldBoost = tank.shieldRepair;
		_effectiveSustainedTank.armorRepair = tank.armorRepair;
		_effectiveSustainedTank.hullRepair = tank.hullRepair;
	}
	return _effectiveSustainedTank;
}

- (NSNumber*) weaponDPS {
	if (!_weaponDPS) {
		float dps = self.pilot->getShip()->getWeaponDps();
		_weaponDPS = @(dps);
	}
	return _weaponDPS;
}

- (NSNumber*) droneDPS {
	if (!_droneDPS) {
		float dps = self.pilot->getShip()->getDroneDps();
		_droneDPS = @(dps);
	}
	return _droneDPS;
}

- (NSNumber*) totalDPS {
	if (!_totalDPS) {
		float dps = self.pilot->getShip()->getWeaponDps() + self.pilot->getShip()->getDroneDps();
		_totalDPS = @(dps);
	}
	return _totalDPS;
}

- (NSNumber*) volleyDamage {
	if (!_volleyDamage) {
		float damage = self.pilot->getShip()->getWeaponVolley() + self.pilot->getShip()->getDroneVolley();
		_volleyDamage = @(damage);
	}
	return _volleyDamage;
}

- (NSNumber*) targets {
	if (!_targets)
		_targets = @(self.pilot->getShip()->getMaxTargets());
	return _targets;
}

- (NSNumber*) targetRange {
	if (!_targetRange)
		_targetRange = @(trunc(self.pilot->getShip()->getMaxTargetRange() / 1000));
	return _targetRange;
}

- (NSNumber*) scanResolution {
	if (!_scanResolution)
		_scanResolution = @(trunc(self.pilot->getShip()->getScanResolution()));
	return _scanResolution;
}

- (NSNumber*) sensorStrength {
	if (!_sensorStrength)
		_sensorStrength = @(trunc(self.pilot->getShip()->getScanStrength()));
	return _sensorStrength;
}

- (NSImage*) sensorImage {
	if (!_sensorImage) {
		switch(self.pilot->getShip()->getScanType()) {
			case dgmpp::Ship::SCAN_TYPE_GRAVIMETRIC:
				_sensorImage = [NSImage imageNamed:@"gravimetric"];
				break;
			case dgmpp::Ship::SCAN_TYPE_LADAR:
				_sensorImage = [NSImage imageNamed:@"ladar"];
				break;
			case dgmpp::Ship::SCAN_TYPE_MAGNETOMETRIC:
				_sensorImage = [NSImage imageNamed:@"magnetometric"];
				break;
			case dgmpp::Ship::SCAN_TYPE_RADAR:
				_sensorImage = [NSImage imageNamed:@"radar"];
				break;
			default:
				_sensorImage = [NSImage imageNamed:@"multispectral"];
				break;
		}
	}
	return _sensorImage;
}

- (NSNumber*) droneRange {
	if (!_droneRange)
		_droneRange = @(trunc(self.pilot->getDroneControlRange() / 1000));
	return _droneRange;
}

- (NSString*) mass {
	if (!_mass)
		_mass = [NSString shortStringWithFloat:self.pilot->getShip()->getMass() unit:nil];
	return _mass;
}

- (NSNumber*) speed {
	if (!_speed)
		_speed = @(trunc(self.pilot->getShip()->getVelocity()));
	return _speed;
}

- (NSNumber*) allignTime {
	if (!_allignTime)
		_allignTime = @(trunc(self.pilot->getShip()->getAlignTime()));
	return _allignTime;
}

- (NSNumber*) signature {
	if (!_signature)
		_signature = @(trunc(self.pilot->getShip()->getSignatureRadius()));
	return _signature;
}

- (NSNumber*) cargo {
	if (!_cargo)
		_cargo = @(trunc(self.pilot->getShip()->getCapacity()));
	return _cargo;
}

- (NSNumber*) oreHold {
	if (!_oreHold)
		_oreHold = @(trunc(self.pilot->getShip()->getOreHoldCapacity()));
	return _oreHold;
}

- (NSNumber*) warpSpeed {
	if (!_warpSpeed)
		_warpSpeed = @(trunc(self.pilot->getShip()->getWarpSpeed()));
	return _warpSpeed;
}

@end

@implementation NCShipFitController
//@synthesize stats = _stats;

/*+ (BOOL) automaticallyNotifiesObserversForKey:(NSString*) key {
	if ([key isEqualToString:@"stats"])
		return YES;
	else
		return [super automaticallyNotifiesObserversForKey:key];
}*/

- (void) setContent:(id)content {
	[self willChangeValueForKey:@"modules"];
	[super setContent:content];
	[self didChangeValueForKey:@"modules"];
	
	NCShipFit* fit = self.content;
	if (fit.pilot) {
		NCShipStats* stats = [NCShipStats new];
		stats.pilot = fit.pilot;
		self.stats = stats;
	}
	else
		self.stats = nil;

}

- (void) dealloc {
}

- (NSArray*) modules {
	NCShipFit* fit = self.content;
	NSMutableArray* array = [NSMutableArray new];
	if (fit.pilot) {
		auto ship = fit.pilot->getShip();
		if (ship) {
			dgmpp::Module::Slot slots[] = {dgmpp::Module::SLOT_MODE, dgmpp::Module::SLOT_HI, dgmpp::Module::SLOT_MED, dgmpp::Module::SLOT_LOW, dgmpp::Module::SLOT_RIG, dgmpp::Module::SLOT_SUBSYSTEM};
			NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
			for (auto slot: slots) {
				dgmpp::ModulesList modules;
				ship->getModules(slot, std::inserter(modules, modules.begin()));
				int n = ship->getNumberOfSlots(slot);
				for (auto module: modules) {
					n--;
					NCShipModule* m = [NCShipModule new];
					m.slot = slot;
					m.module = module;
					m.item = [context invTypeWithTypeID:module->getTypeID()].dgmppItem;
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

- (NSArray*) drones {
	NCShipFit* fit = self.content;
	NSMutableDictionary* dic = [NSMutableDictionary new];
	if (fit.pilot) {
		auto ship = fit.pilot->getShip();
		if (ship) {
			NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
			
			for (const auto& drone: ship->getDrones()) {
				int32_t typeID = drone->getTypeID();
				NCShipDrone* obj = dic[@(typeID)];
				if (!obj) {
					obj = [NCShipDrone new];
					obj.item = [context invTypeWithTypeID:typeID].dgmppItem;
					dic[@(typeID)] = obj;
				}
				obj.drones.push_back(drone);
			}
		}
	}
	return [[dic allValues] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
}

- (void) objectDidBeginEditing:(id)editor {
	[self willChangeValueForKey:@"modules"];
	[self willChangeValueForKey:@"drones"];
}

- (void) objectDidEndEditing:(id)editor {
	NCShipFit* fit = self.content;
	if (fit.pilot) {
		NCShipStats* stats = [NCShipStats new];
		stats.pilot = fit.pilot;
		self.stats = stats;
	}
	else
		self.stats = nil;
	[self didChangeValueForKey:@"drones"];
	[self didChangeValueForKey:@"modules"];
}


@end