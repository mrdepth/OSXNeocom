//
//  NCProgressTextField.m
//  Neocom
//
//  Created by Артем Шиманский on 23.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCProgressTextField.h"
#import "NCShipFitController.h"

@implementation NCProgressTextField

- (void) setValue:(id)value forKey:(nonnull NSString *)keyPath {
	NSLog(@"%@ %@", keyPath, [value class]);
	if ([keyPath isEqualToString:@"value"]) {
		NSLog(@"%@", value);
	}
	[super setValue:value forKey:keyPath];
}

- (void) setObjectValue:(id)objectValue {
	if ([objectValue isKindOfClass:[NCShipStatsResource class]]) {
		NCShipStatsResource* resource = objectValue;
		[self setStringValue:resource.string];
		self.progress = resource.fraction;
		return;
	}
	else if ([objectValue isKindOfClass:[NSNumber class]])
		self.progress = [objectValue floatValue];
	[super setObjectValue:objectValue];
}


- (void) drawRect:(NSRect)rect {
	CGContextRef context = [NSGraphicsContext currentContext].CGContext;
	
	const CGFloat *components = CGColorGetComponents([self.backgroundColor CGColor]);
	CGContextSetRGBFillColor(context, components[0] * 0.4, components[1] * 0.4, components[2] * 0.4, 1);
	CGContextFillRect(context, rect);
	
	float scale;
	if (self.progress > 1.0) {
		CGContextSetFillColorWithColor(context, [[NSColor redColor] CGColor]);
		scale = 1;
	}
	else {
		CGContextSetFillColorWithColor(context, [self.backgroundColor CGColor]);
		scale = self.progress;
	}
	CGContextFillRect(context, CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * scale, rect.size.height));
	
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
	CGContextStrokeRectWithWidth(context, rect, 1);
	
	//CGContextSetFillColorWithColor(context, [self.textColor CGColor]);
	//[self.text drawInRect:rect withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
	[super drawRect:rect];
}


@end
