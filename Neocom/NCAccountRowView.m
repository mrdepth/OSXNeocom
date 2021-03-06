//
//  NCAccountRowView.m
//  Neocom
//
//  Created by Артем Шиманский on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCAccountRowView.h"

void DrawSeparatorInRect(NSRect rect);

@interface NCAccountRowView () {
	BOOL mouseInside;
	NSTrackingArea *trackingArea;
}

@property BOOL mouseInside;
@end

@implementation NCAccountRowView

@dynamic mouseInside;

- (void) awakeFromNib {
	
}

- (void)setMouseInside:(BOOL)value {
	if (mouseInside != value) {
		mouseInside = value;
		[self setNeedsDisplay:YES];
	}
}

- (BOOL)mouseInside {
	return mouseInside;
}

- (void)ensureTrackingArea {
	if (trackingArea == nil) {
		trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
	}
}

- (void)updateTrackingAreas {
	[super updateTrackingAreas];
	[self ensureTrackingArea];
	if (![[self trackingAreas] containsObject:trackingArea]) {
		[self addTrackingArea:trackingArea];
	}
}

- (void)mouseEntered:(NSEvent *)theEvent {
	self.mouseInside = YES;
}

- (void)mouseExited:(NSEvent *)theEvent {
	self.mouseInside = NO;
}

static NSGradient *gradientWithTargetColor(NSColor *targetColor) {
	NSArray *colors = [NSArray arrayWithObjects:[targetColor colorWithAlphaComponent:0], targetColor, targetColor, [targetColor colorWithAlphaComponent:0], nil];
	const CGFloat locations[4] = { 0.0, 0.35, 0.65, 1.0 };
	return [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace sRGBColorSpace]];
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect {
	// Custom background drawing. We don't call super at all.
	[self.backgroundColor set];
	// Fill with the background color first
	NSRectFill(self.bounds);
	
	// Draw a white/alpha gradient
	if (self.mouseInside) {
		NSGradient *gradient = gradientWithTargetColor([NSColor whiteColor]);
		[gradient drawInRect:self.bounds angle:0];
	}
}

- (NSRect)separatorRect {
	NSRect separatorRect = self.bounds;
	separatorRect.origin.y = NSMaxY(separatorRect) - 1;
	separatorRect.size.height = 1;
	return separatorRect;
}

// Only called if the table is set with a horizontal grid
- (void)drawSeparatorInRect:(NSRect)dirtyRect {
	// Use a common shared method of drawing the separator
	DrawSeparatorInRect([self separatorRect]);
}

// Only called if the 'selected' property is yes.
- (void)drawSelectionInRect:(NSRect)dirtyRect {
	// Check the selectionHighlightStyle, in case it was set to None
	if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
		// We want a hard-crisp stroke, and stroking 1 pixel will border half on one side and half on another, so we offset by the 0.5 to handle this
		NSRect selectionRect = NSInsetRect(self.bounds, 5.5, 5.5);
		[[NSColor colorWithCalibratedWhite:.72 alpha:1.0] setStroke];
		[[NSColor colorWithCalibratedWhite:.82 alpha:1.0] setFill];
		NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:10 yRadius:10];
		[selectionPath fill];
		[selectionPath stroke];
	}
}

// interiorBackgroundStyle is normaly "dark" when the selection is drawn (self.selected == YES) and we are in a key window (self.emphasized == YES). However, we always draw a light selection, so we override this method to always return a light color.
- (NSBackgroundStyle)interiorBackgroundStyle {
	return NSBackgroundStyleLight;
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	// We need to invalidate more things when live-resizing since we fill with a gradient and stroke
	if ([self inLiveResize]) {
		// Redraw everything if we are using a gradient
		if (self.selected || self.mouseInside) {
			[self setNeedsDisplay:YES];
		} else {
			// Redraw our horizontal grid line, which is a gradient
			[self setNeedsDisplayInRect:[self separatorRect]];
		}
	}
}

@end

void DrawSeparatorInRect(NSRect rect) {
	// Cache the gradient for performance
	static NSGradient *gradient = nil;
	if (gradient == nil) {
		gradient = gradientWithTargetColor([NSColor colorWithSRGBRed:.80 green:.80 blue:.80 alpha:1]);
	}
	[gradient drawInRect:rect angle:0];
	
}