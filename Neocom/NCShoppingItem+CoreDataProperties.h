//
//  NCShoppingItem+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCShoppingItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCShoppingItem (CoreDataProperties)

@property (nonatomic) BOOL finished;
@property (nonatomic) int32_t quantity;
@property (nonatomic) int32_t typeID;
@property (nullable, nonatomic, retain) NCShoppingGroup *shoppingGroup;

@end

NS_ASSUME_NONNULL_END
