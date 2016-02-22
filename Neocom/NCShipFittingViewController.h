//
//  NCShipFittingViewController.h
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCShipFit;
@class NCDgmItemsTreeController;
@interface NCShipFittingViewController : NSViewController
@property (strong) IBOutlet NCDgmItemsTreeController *dgmItems;
@property (strong) NCShipFit* fit;
@end
