//
//  NSNumberFormatter+Neocom.m
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NSNumberFormatter+Neocom.h"

static NSNumberFormatter* sharedIntegerNumberFormatter;
static NSNumberFormatter* sharedFloatNumberFormatter;

@implementation NSNumberFormatter (Neocom)

+ (NSString *)neocomLocalizedStringFromInteger:(NSInteger)value {
	@synchronized(self) {
		if (!sharedIntegerNumberFormatter) {
			sharedIntegerNumberFormatter = [[NSNumberFormatter alloc] init];
			[sharedIntegerNumberFormatter setPositiveFormat:@"#,##0"];
			[sharedIntegerNumberFormatter setGroupingSeparator:@" "];
		}
		return [sharedIntegerNumberFormatter stringFromNumber:@(value)];
	}
}

+ (NSString *)neocomLocalizedStringFromNumber:(NSNumber*)value {
	@synchronized(self) {
		if (fabs([value floatValue]) < 10.0) {
			if (!sharedFloatNumberFormatter) {
				sharedFloatNumberFormatter = [[NSNumberFormatter alloc] init];
				[sharedFloatNumberFormatter setPositiveFormat:@"#,##0.##"];
				[sharedFloatNumberFormatter setGroupingSeparator:@" "];
				[sharedFloatNumberFormatter setDecimalSeparator:@"."];
			}
			return [sharedFloatNumberFormatter stringFromNumber:value];
		}
		else {
			if (!sharedIntegerNumberFormatter) {
				sharedIntegerNumberFormatter = [[NSNumberFormatter alloc] init];
				[sharedIntegerNumberFormatter setPositiveFormat:@"#,##0"];
				[sharedIntegerNumberFormatter setGroupingSeparator:@" "];
			}
			return [sharedIntegerNumberFormatter stringFromNumber:value];
		}
	}
}

@end
