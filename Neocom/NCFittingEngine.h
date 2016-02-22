//
//  NCFittingEngine.h
//  Neocom
//
//  Created by Artem Shimanski on 18.09.15.
//  Copyright © 2015 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dgmpp/dgmpp.h>

#define NCShipCategoryID 6
#define NCChargeCategoryID 8
#define NCModuleCategoryID 7
#define NCSubsystemCategoryID 32
#define NCDroneCategoryID 18


@class NCDBInvType;
@class NCShipFit;
@class NCPOSFit;
@class NCLoadoutDataShip;
@interface NCFittingEngine : NSObject
@property (nonatomic, assign, readonly) std::shared_ptr<dgmpp::Engine> engine;
@property (nonatomic, strong) NSMutableDictionary* userInfo;

- (void)performBlockAndWait:(void (^)())block;
- (void)performBlock:(void (^)())block;
- (void)loadShipFit:(NCShipFit*) fit;
- (void)loadPOSFit:(NCPOSFit*) fit;
- (NCLoadoutDataShip*) loadoutDataShipWithFit:(NCShipFit*) fit;

@end

@interface NCFittingEngineItemPointer : NSObject
@property (nonatomic, assign, readonly) std::shared_ptr<dgmpp::Item> item;

+ (instancetype) pointerWithItem:(std::shared_ptr<dgmpp::Item>) item;
- (id) initWithItem:(std::shared_ptr<dgmpp::Item>) item;
@end