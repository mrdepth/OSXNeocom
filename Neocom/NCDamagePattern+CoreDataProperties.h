//
//  NCDamagePattern+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCDamagePattern.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCDamagePattern (CoreDataProperties)

@property (nonatomic) float em;
@property (nonatomic) float explosive;
@property (nonatomic) float kinetic;
@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic) float thermal;

@end

NS_ASSUME_NONNULL_END
