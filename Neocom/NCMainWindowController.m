//
//  NCMainWindowController.m
//  Neocom
//
//  Created by Артем Шиманский on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCMainWindowController.h"
#import "global.h"

@interface NCToolBarItem : NSToolbarItem

@end

@implementation NCToolBarItem

- (void) validate {
}

@end

@interface NCMainWindowController ()

@end

@implementation NCMainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];

	NSObjectController* account = self.account;
	[[NSNotificationCenter defaultCenter] addObserverForName:NCDidChangeAccountNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
		[account addObject:note.object];
	}];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)onAction:(id)sender {
}
@end
