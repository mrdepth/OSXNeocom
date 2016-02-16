//
//  NCDBInvControlTowerResource+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCDBInvControlTowerResource.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCDBInvControlTowerResource (CoreDataProperties)

@property (nonatomic) int32_t factionID;
@property (nonatomic) float minSecurityLevel;
@property (nonatomic) int32_t quantity;
@property (nonatomic) int32_t wormholeClassID;
@property (nullable, nonatomic, retain) NCDBInvControlTower *controlTower;
@property (nullable, nonatomic, retain) NCDBInvControlTowerResourcePurpose *purpose;
@property (nullable, nonatomic, retain) NCDBInvType *resourceType;

@end

NS_ASSUME_NONNULL_END
