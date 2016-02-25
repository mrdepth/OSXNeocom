//
//  NCAccount.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NCAPIKey, NCMailBox, NCSkillPlan, NCFitCharacter;
@class EVECharacterInfo, EVECharacterSheet, EVESkillQueue, EVEAccountBalance, EVEAccountStatus;

NS_ASSUME_NONNULL_BEGIN

@interface NCAccount : NSManagedObject
@property (readonly) EVECharacterInfo* characterInfo;
@property (readonly) EVECharacterSheet* characterSheet;
@property (readonly) EVESkillQueue* skillQueue;
@property (readonly) EVEAccountBalance* accountBalance;
@property (readonly) EVEAccountStatus* accountStatus;
@property (readonly, getter = isCorporate) BOOL corporate;

@property (readonly) NSImage* characterSmallImage;
@property (readonly) NSImage* characterLargeImage;
@property (readonly) NSImage* corporationSmallImage;
@property (readonly) NSImage* corporationLargeImage;
@property (readonly) NSImage* allianceSmallImage;
@property (readonly) NSImage* allianceLargeImage;

@property (readonly) NSAttributedString* skillQueueInfo;
@property (readonly) NSString* skillsInfo;
@property (readonly) NSString* accountBalanceInfo;
@property (readonly) NSAttributedString* paidUntil;

@property (readonly) NCFitCharacter* fitCharacter;


+ (instancetype) currentAccount;
+ (void) setCurrentAccount:(NCAccount*) account;

- (IBAction) reload;

@end

NS_ASSUME_NONNULL_END

#import "NCAccount+CoreDataProperties.h"
