//
//  NCShipFitController.h
//  Neocom
//
//  Created by Artem Shimanski on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Dgmpp/Dgmpp.h>

@class NCDBDgmppItem;
@interface NCShipModule: NSObject

@property (readonly) NSImage* slotImage;
@property (readonly) NSImage* stateImage;
@property (readonly) NSImage* typeImage;
@property (readonly) NSString* title;
@property (readonly) NSImage* ammoImage;
@property (readonly) NSString* ammoName;
@property (assign) dgmpp::Module::Slot slot;
@property (assign) std::shared_ptr<dgmpp::Module> module;
@property (strong) NCDBDgmppItem* item;
@end

@interface NCShipDrone: NSObject {
	std::list<std::shared_ptr<dgmpp::Drone>> _drones;
}

@property (readonly) NSImage* typeImage;
@property (readonly) NSString* title;
@property (readonly) std::list<std::shared_ptr<dgmpp::Drone>>& drones;
@property (strong) NCDBDgmppItem* item;
@property (readonly) NSInteger count;
@end


@interface NCShipStatsResource: NSObject
@property (assign) float total;
@property (assign) float used;
@property (assign) float free;
@property (readonly) float fraction;
@property (strong) NSString* unit;
@property (readonly) NSString* string;
- (id) initWithTotal:(float) total used:(float) used unit:(NSString*) unit;
- (id) initWithFree:(float) free used:(float) used unit:(NSString*) unit;
@end

@interface NCShipStatsDamageLayer: NSObject
@property (assign) float em;
@property (assign) float thermal;
@property (assign) float kinetic;
@property (assign) float explosive;
@end

@interface NCShipStatsResistances: NSObject
@property (strong) NCShipStatsDamageLayer* shield;
@property (strong) NCShipStatsDamageLayer* armor;
@property (strong) NCShipStatsDamageLayer* hull;
@end

@interface NCShipStatsHP: NSObject
@property (assign) float shield;
@property (assign) float armor;
@property (assign) float hull;
@property (assign) float total;
@end

@interface NCShipStatsCapacitor: NSObject
@property (strong) NSString* state;
@property (assign) float rechargeTime;
@property (strong) NSString* delta;
@property (assign) float capacity;
@end

@interface NCShipStatsTank: NSObject
@property (assign) float shieldRecharge;
@property (assign) float shieldBoost;
@property (assign) float armorRepair;
@property (assign) float hullRepair;
@end

@interface NCShipStats: NSObject
@property (assign) std::shared_ptr<dgmpp::Character> pilot;
@property (nonatomic, strong) NCShipStatsResource* turrets;
@property (nonatomic, strong) NCShipStatsResource* launchers;
@property (nonatomic, strong) NCShipStatsResource* calibration;
@property (nonatomic, strong) NCShipStatsResource* drones;
@property (nonatomic, strong) NCShipStatsResource* cpu;
@property (nonatomic, strong) NCShipStatsResource* powerGrid;
@property (nonatomic, strong) NCShipStatsResource* droneBay;
@property (nonatomic, strong) NCShipStatsResource* droneBandwidth;

@property (nonatomic, strong) NCShipStatsResistances* resistances;
@property (nonatomic, strong) NCShipStatsDamageLayer* damagePattern;
@property (nonatomic, strong) NCShipStatsHP* hp;
@property (nonatomic, strong) NCShipStatsHP* ehp;

@property (nonatomic, strong) NCShipStatsCapacitor* capacitor;
@property (nonatomic, strong) NCShipStatsTank* reinforcedTank;
@property (nonatomic, strong) NCShipStatsTank* sustainedTank;
@property (nonatomic, strong) NCShipStatsTank* effectiveReinforcedTank;
@property (nonatomic, strong) NCShipStatsTank* effectiveSustainedTank;

@property (nonatomic, strong) NSNumber* weaponDPS;
@property (nonatomic, strong) NSNumber* droneDPS;
@property (nonatomic, strong) NSNumber* totalDPS;
@property (nonatomic, strong) NSNumber* volleyDamage;

@property (nonatomic, strong) NSNumber* targets;
@property (nonatomic, strong) NSNumber* targetRange;
@property (nonatomic, strong) NSNumber* scanResolution;
@property (nonatomic, strong) NSNumber* sensorStrength;
@property (nonatomic, strong) NSImage* sensorImage;
@property (nonatomic, strong) NSNumber* droneRange;
@property (nonatomic, strong) NSString* mass;
@property (nonatomic, strong) NSNumber* speed;
@property (nonatomic, strong) NSNumber* allignTime;
@property (nonatomic, strong) NSNumber* signature;
@property (nonatomic, strong) NSNumber* cargo;
@property (nonatomic, strong) NSNumber* oreHold;
@property (nonatomic, strong) NSNumber* warpSpeed;

@end

@interface NCShipFitController : NSObjectController
@property (readonly) NSArray* modules;
@property (readonly) NSArray* drones;
@property (strong) NCShipStats* stats;
@end
