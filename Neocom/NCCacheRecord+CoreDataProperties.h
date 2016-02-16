//
//  NCCacheRecord+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCCacheRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCCacheRecord (CoreDataProperties)

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSDate* expireDate;
@property (nullable, nonatomic, retain) NSString *recordID;
@property (nullable, nonatomic, retain) NCCacheRecordData *data;

@end

NS_ASSUME_NONNULL_END
