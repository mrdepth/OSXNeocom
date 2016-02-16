//
//  NCCachePrice+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCCachePrice.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCCachePrice (CoreDataProperties)

@property (nonatomic) double price;
@property (nonatomic) int32_t typeID;

@end

NS_ASSUME_NONNULL_END
