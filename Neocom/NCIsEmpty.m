//
//  NCIsEmpty.m
//  Neocom
//
//  Created by Артем Шиманский on 29.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCIsEmpty.h"
#import <AppKit/AppKit.h>

@implementation NCIsEmpty

+ (void) initialize {
	[self setValueTransformer:[NCIsEmpty new] forName:@"NCIsEmpty"];
}

- (id) transformedValue:(id)value {
	return [value respondsToSelector:@selector(count)] ? @(!value || [value count] == 0) : @(YES);
}

@end
