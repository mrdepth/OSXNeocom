//
//  NSOutlineView+Neocom.m
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NSOutlineView+Neocom.h"

@implementation NSOutlineView (Neocom)

- (void) expandAll {
	NSInteger n = [self numberOfRows];
	NSMutableArray* items = [NSMutableArray new];
	for (NSInteger row = 0; row < n; row++)
		[items addObject:[self itemAtRow:row]];
	for (id item in items)
		[self expandItem:item expandChildren:YES];
}

@end
