//
//  NCDgmItemsTreeController.h
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCDBInvType;
@interface NCDgmItemsTreeController : NSTreeController
@property (strong) NCDBInvType* type;
@end
