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
@class NCShipModulesController;
@class NCShipFitController;
@interface NCShipFittingViewController : NSViewController
@property (strong) IBOutlet NCDgmItemsTreeController *dgmItems;
@property (strong) IBOutlet NCShipModulesController *modules;

@property (strong) NCShipFit* fit;
@property (strong) IBOutlet NCShipFitController *fitController;

- (IBAction) didSelectItem:(NSArray*) selectedObjects;
@end
