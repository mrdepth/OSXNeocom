//
//  NCImplantSet+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCImplantSet.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCImplantSet (CoreDataProperties)

@property (nullable, nonatomic, retain) id data;
@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
