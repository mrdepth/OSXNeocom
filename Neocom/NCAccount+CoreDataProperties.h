//
//  NCAccount+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCAccount (CoreDataProperties)

@property (nonatomic) int32_t characterID;
@property (nonatomic) int32_t order;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NCAPIKey *apiKey;
@property (nullable, nonatomic, retain) NCMailBox *mailBox;
@property (nullable, nonatomic, retain) NSSet<NCSkillPlan *> *skillPlans;

@end

@interface NCAccount (CoreDataGeneratedAccessors)

- (void)addSkillPlansObject:(NCSkillPlan *)value;
- (void)removeSkillPlansObject:(NCSkillPlan *)value;
- (void)addSkillPlans:(NSSet<NCSkillPlan *> *)values;
- (void)removeSkillPlans:(NSSet<NCSkillPlan *> *)values;

@end

NS_ASSUME_NONNULL_END
