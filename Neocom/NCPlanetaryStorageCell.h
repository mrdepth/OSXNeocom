//
//  NCPlanetaryStorageCell.h
//  Neocom
//
//  Created by Artem Shimanski on 21.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NCBarChartView.h"

@interface NCPlanetaryStorageCell : NSTableCellView
@property (weak) IBOutlet NCBarChartView *barChartView;
@property (weak) IBOutlet NSLayoutConstraint *markerAuxiliaryViewConstraint;
@property (weak) IBOutlet NSView *markerAuxiliaryView;
@property (weak) IBOutlet NSStackView *resourcesStackView;
@property (weak) IBOutlet NSStackView *quantitiesStackView;
@property (weak) IBOutlet NSStackView *unitsStackView;

@end
