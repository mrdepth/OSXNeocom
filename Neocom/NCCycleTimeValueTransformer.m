//
//  NCCycleTimeValueTransformer.m
//  Neocom
//
//  Created by Artem Shimanski on 21.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCCycleTimeValueTransformer.h"

@implementation NCCycleTimeValueTransformer

+ (void) initialize {
	[self setValueTransformer:[NCCycleTimeValueTransformer new] forName:@"NCCycleTimeValueTransformer"];
}

- (id) transformedValue:(id)value {
	int32_t c = [value intValue];
	return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", c / 3600, (c % 3600) / 60, c % 60];
}




@end
