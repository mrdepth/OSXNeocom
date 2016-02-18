//
//  NCTimeLeftValueTransformer.m
//  Neocom
//
//  Created by Артем Шиманский on 18.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCTimeLeftValueTransformer.h"
#import "NSString+Neocom.h"

@implementation NCTimeLeftValueTransformer

+ (void) initialize {
	[self setValueTransformer:[NCTimeLeftValueTransformer new] forName:@"NCTimeLeftValueTransformer"];
}

- (id) transformedValue:(id)value {
	return [NSString stringWithTimeLeft:[value doubleValue]];
}

@end
