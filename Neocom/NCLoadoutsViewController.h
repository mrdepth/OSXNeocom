//
//  NCLoadoutsViewController.h
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NCLoadoutsViewController : NSViewController
@property (strong) IBOutlet NSTreeController *loadouts;
@property (weak) IBOutlet NSOutlineView *outlineView;

- (IBAction)onRemove:(id)sender;

@end
