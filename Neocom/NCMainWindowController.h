//
//  NCMainWindowController.h
//  Neocom
//
//  Created by Артем Шиманский on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NCMainWindowController : NSWindowController
@property (strong) IBOutlet NSObjectController *account;
@property (weak) IBOutlet NSToolbarItem *item;
- (IBAction)onAction:(id)sender;

@end