//
//  NCCacheRecord.m
//  Neocom
//
//  Created by Artem Shimanski on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCCacheRecord.h"
#import "NCCacheRecordData.h"

@implementation NCCacheRecord

- (BOOL) isExpired {
	return self.expireDate ? [self.expireDate compare:[NSDate date]] == NSOrderedAscending : NO;
}

@end
