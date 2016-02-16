//
//  NCShoppingList+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCShoppingList.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCShoppingList (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<NCShoppingGroup *> *shoppingGroups;

@end

@interface NCShoppingList (CoreDataGeneratedAccessors)

- (void)addShoppingGroupsObject:(NCShoppingGroup *)value;
- (void)removeShoppingGroupsObject:(NCShoppingGroup *)value;
- (void)addShoppingGroups:(NSSet<NCShoppingGroup *> *)values;
- (void)removeShoppingGroups:(NSSet<NCShoppingGroup *> *)values;

@end

NS_ASSUME_NONNULL_END
