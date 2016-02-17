//
//  NCRoundRectImageView.m
//  Neocom
//
//  Created by Артем Шиманский on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCRoundRectImageView.h"

@implementation NCRoundRectImageView

- (void) awakeFromNib {
	self.wantsLayer = YES;
	self.layer.masksToBounds = YES;
	self.layer.cornerRadius = 10;
	self.layer.borderColor = [[NSColor darkGrayColor] CGColor];
	self.layer.borderWidth = 1.0;
}

@end
