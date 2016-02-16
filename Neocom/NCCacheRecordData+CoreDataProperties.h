//
//  NCCacheRecordData+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCCacheRecordData.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCCacheRecordData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) NCCacheRecord *record;

@end

NS_ASSUME_NONNULL_END
