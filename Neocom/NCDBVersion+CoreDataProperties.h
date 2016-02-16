//
//  NCDBVersion+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCDBVersion.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCDBVersion (CoreDataProperties)

@property (nonatomic) int32_t build;
@property (nullable, nonatomic, retain) NSString *expansion;
@property (nullable, nonatomic, retain) NSString *version;

@end

NS_ASSUME_NONNULL_END
