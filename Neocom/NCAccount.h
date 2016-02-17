//
//  NCAccount.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NCAPIKey, NCMailBox, NCSkillPlan;
@class EVECharacterInfo;

NS_ASSUME_NONNULL_BEGIN

@interface NCAccount : NSManagedObject
@property (readonly) EVECharacterInfo* characterInfo;
@property (readonly, getter = isCorporate) BOOL corporate;
@property (readonly) NSAttributedString* skillQueueInfo;

// Insert code here to declare functionality of your managed object subclass
- (void) reload;

@end

NS_ASSUME_NONNULL_END

#import "NCAccount+CoreDataProperties.h"
