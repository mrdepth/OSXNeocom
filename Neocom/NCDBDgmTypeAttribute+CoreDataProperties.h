//
//  NCDBDgmTypeAttribute+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCDBDgmTypeAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCDBDgmTypeAttribute (CoreDataProperties)

@property (nonatomic) float value;
@property (nullable, nonatomic, retain) NCDBDgmAttributeType *attributeType;
@property (nullable, nonatomic, retain) NCDBInvType *type;

@end

NS_ASSUME_NONNULL_END
