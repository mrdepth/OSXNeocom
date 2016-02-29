//
//  NCTrainingQueue.h
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCSkillData.h"

@class NCAccount;
@class EVECharacterSheet;
@class EVESkillQueue;
@interface NCTrainingQueue : NSObject<NSCopying>
@property (nonatomic, copy, readonly) NSArray* skills;
@property (nonatomic, readonly) NSTimeInterval trainingTime;
@property (nonatomic, strong) EVECharacterSheet* characterSheet;
@property (nonatomic, strong) NCCharacterAttributes* characterAttributes;
@property (nonatomic, strong, readonly) NSManagedObjectContext* databaseManagedObjectContext;

- (id) initWithCharacterSheet:(EVECharacterSheet*) characterSheet;
- (id) initWithCharacterSheet:(EVECharacterSheet*) characterSheet xmlData:(NSData*) data skillPlanName:(NSString**) skillPlanName;

- (void) addRequiredSkillsForType:(NCDBInvType*) type;
- (void) addSkill:(NCDBInvType*) skill withLevel:(int32_t) level;
- (void) addMastery:(NCDBCertMastery*) mastery;
- (NSIndexSet*) removeSkill:(NCSkillData*) skill;
- (NSString*) xmlRepresentationWithSkillPlanName:(NSString*) skillPlanName;
- (NSTimeInterval) trainingTimeWithCharacterAttributes:(NCCharacterAttributes*) characterAttributes;
- (void) moveSkillAdIndex:(NSInteger) from toIndex:(NSInteger) to;

@end
