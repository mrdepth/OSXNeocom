//
//  NCPlanetariesViewController.h
//  Neocom
//
//  Created by Artem Shimanski on 20.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NCPlanetariesViewController : NSViewController
@property (strong) IBOutlet NSTreeController *colonies;
@property (weak) IBOutlet NSOutlineView *outlineView;

@end
