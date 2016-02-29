//
//  NSNumberFormatter+Neocom.h
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatter (Neocom)

+ (NSString *)neocomLocalizedStringFromInteger:(NSInteger)value;
+ (NSString *)neocomLocalizedStringFromNumber:(NSNumber*)value;

@end
