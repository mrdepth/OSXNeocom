//
//  NCSkillPlan+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCSkillPlan.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCSkillPlan (CoreDataProperties)

@property (nonatomic) BOOL active;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) id skills;
@property (nullable, nonatomic, retain) NCAccount *account;

@end

NS_ASSUME_NONNULL_END
