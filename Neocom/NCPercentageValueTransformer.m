//
//  NCPercentageValueTransformer.m
//  Neocom
//
//  Created by Артем Шиманский on 18.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCPercentageValueTransformer.h"

@implementation NCPercentageValueTransformer

+ (void) initialize {
	[self setValueTransformer:[NCPercentageValueTransformer new] forName:@"NCPercentageValueTransformer"];
}

- (id) transformedValue:(id)value {
	return [NSString stringWithFormat:@"%.0f%%", [value floatValue] * 100];
}

@end
