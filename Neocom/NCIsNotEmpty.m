//
//  NCIsNotEmpty.m
//  Neocom
//
//  Created by Артем Шиманский on 29.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCIsNotEmpty.h"
#import <AppKit/AppKit.h>

@implementation NCIsNotEmpty

+ (void) initialize {
	[self setValueTransformer:[NCIsNotEmpty new] forName:@"NCIsNotEmpty"];
}

- (id) transformedValue:(id)value {
	return [value respondsToSelector:@selector(count)] ? @(value && [value count] > 0) : @(NO);
}

@end
