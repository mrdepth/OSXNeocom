//
//  NCNumberFormatterValueTransformer.m
//  Neocom
//
//  Created by Артем Шиманский on 19.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCNumberFormatterValueTransformer.h"
#import "NSNumberFormatter+Neocom.h"

@implementation NCNumberFormatterValueTransformer

+ (void) initialize {
	[self setValueTransformer:[NCNumberFormatterValueTransformer new] forName:@"NCNumberFormatterValueTransformer"];
}

- (id) transformedValue:(id)value {
	return [NSNumberFormatter neocomLocalizedStringFromNumber:value];
}

@end
