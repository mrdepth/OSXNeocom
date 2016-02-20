//
//  NSColor+Neocom.h
//  Neocom
//
//  Created by Artem Shimanski on 20.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Neocom)

+ (instancetype) colorWithNumber:(NSNumber*) number;
+ (instancetype) colorWithUInteger:(NSUInteger) rgba;
- (NSNumber*) numberValue;

+ (instancetype) colorWithSecurity:(float) security;
+ (instancetype) colorWithPlayerSecurityStatus:(float) securityStatus;

+ (instancetype) urlColor;

+ (instancetype) colorWithString:(NSString*) string;


@end
