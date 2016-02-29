//
//  NCSkillData.h
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCDatabase.h"

#define NCSkillTimeConstantAttributeID 275

@class NCCharacterAttributes;
@class EVECharacterSheetSkill;
@interface NCSkillData : NSObject<NSCopying>//<NSCoding>
//@property (nonatomic, strong, readonly) NCDBInvType* type;
@property (nonatomic, assign, readonly) int32_t typeID;
@property (nonatomic, strong) EVECharacterSheetSkill* characterSkill;
@property (nonatomic, assign, readonly) int32_t skillPoints;
@property (nonatomic, assign) int32_t currentLevel;
@property (nonatomic, assign) int32_t targetLevel;
@property (nonatomic, readonly) int32_t trainedLevel;
@property (nonatomic, assign, readonly) int32_t targetSkillPoints;
@property (nonatomic, readonly, getter = isActive) BOOL active;
@property (nonatomic, strong) NCCharacterAttributes* characterAttributes;
@property (nonatomic, readonly) NSTimeInterval trainingTimeToLevelUp;
@property (nonatomic, readonly) NSTimeInterval trainingTimeToFinish;
@property (nonatomic, readonly) int32_t skillPointsToFinish;
@property (nonatomic, readonly) int32_t skillPointsToLevelUp;
@property (nonatomic, readonly) NSImage* levelImage;
@property (nonatomic, readonly) float progress;

- (id) initWithInvType:(NCDBInvType*) type;
- (NSTimeInterval) trainingTimeToLevelUpWithCharacterAttributes:(NCCharacterAttributes*) attributes;
- (NSTimeInterval) trainingTimeToFinishWithCharacterAttributes:(NCCharacterAttributes*) attributes;

- (float) skillPointsAtLevel:(int32_t) level;

@end
