//
//  NCLoadout+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCLoadout.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCLoadout (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *tag;
@property (nonatomic) int32_t typeID;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NCLoadoutData *data;

@end

NS_ASSUME_NONNULL_END
