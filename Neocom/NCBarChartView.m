//
//  NCBarChartView.m
//  Neocom
//
//  Created by Артем Шиманский on 18.01.16.
//  Copyright © 2016 Artem Shimanski. All rights reserved.
//

#import "NCBarChartView.h"

@implementation NCBarChartSegment;
@end

@interface NCBarChartView()
@property (nonatomic, strong) NSMutableArray* segments;

@end

@implementation NCBarChartView

- (id) init {
	if (self = [super init]) {
		self.segments = [NSMutableArray new];
	}
	return self;
}

- (void) awakeFromNib {
	self.segments = [NSMutableArray new];
//	self.wantsLayer = YES;
//	self.layer.borderColor = [[NSColor lightGrayColor] CGColor];
//	self.layer.borderWidth = 1.0;
}

- (void) addSegment:(NCBarChartSegment*) segment {
	[self.segments addObject:segment];
	self.needsDisplay = YES;
}

- (void) addSegments:(NSArray*) segments {
	[self.segments addObjectsFromArray:segments];
	self.needsDisplay = YES;
}


- (void) clear {
	[self.segments removeAllObjects];
	self.needsDisplay = YES;
}

- (void) drawRect:(CGRect)rect {
	CGContextRef context = [NSGraphicsContext currentContext].CGContext;
	CGContextSetFillColorWithColor(context, [[NSColor colorWithWhite:0.9 alpha:1] CGColor]);
	CGContextAddRect(context, rect);
	CGContextFillPath(context);
//	CGContextStrokePath(context);
	
	NSUInteger n = self.segments.count;
	for (NSUInteger i = 0; i < n; i++) {
		NCBarChartSegment* segment = _segments[i];
		CGFloat x = segment.x * rect.size.width;
		CGFloat w = segment.w * rect.size.width;
		
		CGFloat h0 = segment.h0 * w;
		CGFloat h1 = segment.h1 * w;
		
		while (i < n - 1 && w < 4) {
			NCBarChartSegment* segment = _segments[++i];
			CGFloat ww = segment.w *rect.size.width;
			w += ww;
			h0 += segment.h0 * ww;
			h1 += segment.h1 * ww;
		}
		
		h0 = (h0 / w) * rect.size.height;
		h1 = (h1 / w) * rect.size.height;

		CGFloat dx = 0;
		if (w >= 4) {
			w -= 2;
			dx = 1;
		}

		if (h0 > 0) {
			CGContextSetFillColorWithColor(context, segment.color0.CGColor);
			CGContextFillRect(context, CGRectMake(x + dx, 0 , w, h0));
		}
		if (h1 > 0) {
			CGContextSetFillColorWithColor(context, segment.color1.CGColor);
			CGContextFillRect(context, CGRectMake(x + dx, h0, w, h1));
		}
	}
	
	CGContextSetStrokeColorWithColor(context, [[NSColor darkGrayColor] CGColor]);
	CGFloat x = rect.size.width * self.markerPosition;
	CGContextMoveToPoint(context, x, 0);
	CGContextAddLineToPoint(context, x, rect.size.height);
	CGContextStrokePath(context);
	//CGContextFillRect(context, CGRectMake(rect.size.width * self.markerPosition, 0, 1, rect.size.height));
}

@end
