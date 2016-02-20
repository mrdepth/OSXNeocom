//
//  NSColor+Neocom.m
//  Neocom
//
//  Created by Artem Shimanski on 20.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NSColor+Neocom.h"

@implementation NSColor (Neocom)

+ (instancetype) colorWithNumber:(NSNumber*) number {
	if (!number)
		return nil;
	NSUInteger rgba = [number unsignedIntegerValue];
	return [self colorWithUInteger:rgba];
}

+ (instancetype) colorWithUInteger:(NSUInteger) rgba {
	float components[4];
	for (int i = 3; i >= 0; i--) {
		components[i] = (rgba & 0xff) / 255.0;
		rgba >>= 8;
	}
	return [NSColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
}

- (NSNumber*) numberValue {
	CGColorRef colorRef = [self CGColor];
	size_t componentsCount = CGColorGetNumberOfComponents(colorRef);
	NSUInteger rgba = 0;
	
	if (componentsCount == 4) {
		const CGFloat *components = CGColorGetComponents(colorRef);
		rgba = 0;
		for (int i = 0; i < 4; i++) {
			rgba <<= 8;
			rgba += (int) (components[i] * 255);
		}
		return [NSNumber numberWithUnsignedInteger:rgba];
	}
	else
		return nil;
}

+ (instancetype) colorWithSecurity:(float) security {
	if (security >= 1.0f)
		return [NSColor colorWithUInteger:0x2FEFEFFF];
	else if (security >= 0.9f)
		return [NSColor colorWithUInteger:0x48F0C0FF];
	else if (security >= 0.8f)
		return [NSColor colorWithUInteger:0x00EF47FF];
	else if (security >= 0.7f)
		return [NSColor colorWithUInteger:0x00F000FF];
	else if (security >= 0.6f)
		return [NSColor colorWithUInteger:0x8FEF2FFF];
	else if (security >= 0.5f)
		return [NSColor colorWithUInteger:0xEFEF00FF];
	else if (security >= 0.4f)
		return [NSColor colorWithUInteger:0xD77700FF];
	else if (security >= 0.3f)
		return [NSColor colorWithUInteger:0xF06000FF];
	else if (security >= 0.2f)
		return [NSColor colorWithUInteger:0xF04800FF];
	else if (security >= 0.1f)
		return [NSColor colorWithUInteger:0xD73000FF];
	else
		return [NSColor colorWithUInteger:0xF00000FF];
}

+ (instancetype) colorWithPlayerSecurityStatus:(float) securityStatus {
	if (securityStatus > -2.0f)
		return [self colorWithSecurity:0.5 + (securityStatus + 2.0f) / 14.0f];
	else
		return [self colorWithSecurity:(securityStatus + 5.0f - FLT_EPSILON) / 6.0f];
}

+ (instancetype) urlColor {
	return [NSColor colorWithUInteger:0xffa500ff];
}

+ (instancetype) colorWithString:(NSString*) string {
	unsigned int rgba;
	if ([[NSScanner scannerWithString:string] scanHexInt:&rgba]) {
		return [self colorWithUInteger:rgba];
	}
	else {
		static NSDictionary* map = nil;
		if (!map) {
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{
				NSMutableDictionary* dic = [NSMutableDictionary new];
				dic[@"black"] = [NSColor blackColor];
				dic[@"darkgray"] = [NSColor darkGrayColor];
				dic[@"lightgray"] = [NSColor lightGrayColor];
				dic[@"white"] = [NSColor whiteColor];
				dic[@"gray"] = [NSColor grayColor];
				dic[@"red"] = [NSColor redColor];
				dic[@"green"] = [NSColor greenColor];
				dic[@"blue"] = [NSColor blueColor];
				dic[@"cyan"] = [NSColor cyanColor];
				dic[@"yellow"] = [NSColor yellowColor];
				dic[@"magenta"] = [NSColor magentaColor];
				dic[@"orange"] = [NSColor orangeColor];
				dic[@"purple"] = [NSColor purpleColor];
				dic[@"brown"] = [NSColor brownColor];
				map = dic;
			});
		}
		NSString* key = [string lowercaseString];
		return map[key] ?: [NSColor whiteColor];
	}
}


@end

