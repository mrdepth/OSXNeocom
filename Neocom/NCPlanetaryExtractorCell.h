//
//  NCPlanetaryExtractorCell.h
//  Neocom
//
//  Created by Artem Shimanski on 21.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NCBarChartView.h"

@interface NCPlanetaryExtractorCell : NSTableCellView
@property (weak) IBOutlet NCBarChartView *barChartView;
@property (weak) IBOutlet NSLayoutConstraint *markerAuxiliaryViewConstraint;
@property (weak) IBOutlet NSView *markerAuxiliaryView;

@end
