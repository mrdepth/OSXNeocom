//
//  NCDBDgmppItemDamage+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCDBDgmppItemDamage.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCDBDgmppItemDamage (CoreDataProperties)

@property (nonatomic) float emAmount;
@property (nonatomic) float explosiveAmount;
@property (nonatomic) float kineticAmount;
@property (nonatomic) float thermalAmount;
@property (nullable, nonatomic, retain) NCDBDgmppItem *item;

@end

NS_ASSUME_NONNULL_END
