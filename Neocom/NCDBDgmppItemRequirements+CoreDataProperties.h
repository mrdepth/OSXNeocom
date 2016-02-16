//
//  NCDBDgmppItemRequirements+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCDBDgmppItemRequirements.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCDBDgmppItemRequirements (CoreDataProperties)

@property (nonatomic) float calibration;
@property (nonatomic) float cpu;
@property (nonatomic) float powerGrid;
@property (nullable, nonatomic, retain) NCDBDgmppItem *item;

@end

NS_ASSUME_NONNULL_END
