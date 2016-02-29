//
//  NSManagedObjectContext+NCCache.h
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <CoreData/CoreData.h>

@class NCCacheRecord;
@interface NSManagedObjectContext (NCCache)

- (NCCacheRecord*) cacheRecordWithRecordID:(NSString*) recordID;

@end
