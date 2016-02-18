//
//  NCMainWindowController.m
//  Neocom
//
//  Created by Артем Шиманский on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCMainWindowController.h"
#import "global.h"
#import "NCAccount.h"

@interface NCToolBarItem : NSToolbarItem

@end

@implementation NCToolBarItem

- (void) validate {
}

@end

@interface NCMainWindowController ()
- (void) didChangeAccount:(NSNotification*) note;
- (void) onClose:(NSNotification*) note;

@end

@implementation NCMainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAccount:) name:NCDidChangeAccountNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClose:) name:NSWindowWillCloseNotification object:self.window];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void) didChangeAccount:(NSNotification*) note {
	self.account.content = note.object;
}

- (void) onClose:(NSNotification*) note {
	[NSApp terminate:nil];
}

@end
