//
//  NCShoppingGroup+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCShoppingGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCShoppingGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *iconFile;
@property (nullable, nonatomic, retain) NSString *identifier;
@property (nonatomic) BOOL immutable;
@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic) int32_t quantity;
@property (nullable, nonatomic, retain) NSSet<NCShoppingItem *> *shoppingItems;
@property (nullable, nonatomic, retain) NCShoppingList *shoppingList;

@end

@interface NCShoppingGroup (CoreDataGeneratedAccessors)

- (void)addShoppingItemsObject:(NCShoppingItem *)value;
- (void)removeShoppingItemsObject:(NCShoppingItem *)value;
- (void)addShoppingItems:(NSSet<NCShoppingItem *> *)values;
- (void)removeShoppingItems:(NSSet<NCShoppingItem *> *)values;

@end

NS_ASSUME_NONNULL_END
