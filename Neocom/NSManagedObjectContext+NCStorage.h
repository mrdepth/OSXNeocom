//
//  NSManagedObjectContext+NCStorage.h
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <CoreData/CoreData.h>

@class NCAccount;
@class NCFitCharacter;
@class NCSetting;
@class NCAPIKey;
@class NCShoppingList;
@interface NSManagedObjectContext (NCStorage)

//NCImplantSet
- (NSArray*) implantSets;

//NCDamagePattern
- (NSArray*) damagePatterns;

//NCLoadout
- (NSArray*) loadouts;
//- (NSArray*) shipLoadouts;
//- (NSArray*) posLoadouts;

//NCAccount
- (NSArray*) allAccounts;
- (NCAccount*) accountWithUUID:(NSString*) uuid;

//NCFitCharacter
- (NSArray*) fitCharacters;
- (NCFitCharacter*) fitCharacterWithSkillsLevel:(NSInteger) skillsLevel;

//NCSetting
- (NCSetting*) settingWithKey:(NSString*) key;

//NCAPIKey
- (NCAPIKey*) apiKeyWithKeyID:(int32_t) keyID;
- (NSArray*) allAPIKeys;
@end
