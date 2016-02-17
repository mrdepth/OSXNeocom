//
//  NCDBImageValueTransformer.m
//  Neocom
//
//  Created by Артем Шиманский on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCDBImageValueTransformer.h"
#import <AppKit/AppKit.h>

@implementation NCDBImageValueTransformer

+ (void) initialize {
	[self setValueTransformer:[NCDBImageValueTransformer new] forName:@"NCDBImageValueTransformer"];
}

- (id) transformedValue:(NSImage*)value {
	for (NSImageRep* imageRep in [value representations])
		if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
			return [(NSBitmapImageRep*) imageRep representationUsingType:NSPNGFileType properties:@{}];
		}
	return nil;
}

- (id) reverseTransformedValue:(id)value {
	NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:value];
	
	NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
	[image addRepresentation:imageRep];
	return image;
}

@end
