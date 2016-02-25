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
@class NCShipDronesController;
@interface NCShipFittingViewController : NSViewController
@property (strong) IBOutlet NCDgmItemsTreeController *dgmItems;
@property (strong) IBOutlet NCShipModulesController *modules;
@property (strong) IBOutlet NCShipDronesController *drones;
@property (weak) IBOutlet NSTableView *modulesTableView;
@property (weak) IBOutlet NSTableView *dronesTableView;
@property (strong) IBOutlet NSArrayController *characters;

@property (strong) NCShipFit* fit;
@property (strong) IBOutlet NCShipFitController *fitController;

- (IBAction) didSelectItem:(NSArray*) selectedObjects;
@end
