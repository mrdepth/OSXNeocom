//
//  NCBarChartView.h
//  Neocom
//
//  Created by Артем Шиманский on 18.01.16.
//  Copyright © 2016 Artem Shimanski. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NCBarChartSegment : NSObject
@property (nonatomic, assign) double x;
@property (nonatomic, assign) double w;
@property (nonatomic, assign) double h0;
@property (nonatomic, assign) double h1;
@property (nonatomic, strong) NSColor* color0;
@property (nonatomic, strong) NSColor* color1;
@end

@interface NCBarChartView : NSView
@property (nonatomic, assign) CGFloat markerPosition;

- (void) addSegment:(NCBarChartSegment*) segment;
- (void) addSegments:(NSArray*) segments;
- (void) clear;
@end
