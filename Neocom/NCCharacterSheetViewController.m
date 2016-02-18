//
//  NCCharacterSheetViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCCharacterSheetViewController.h"
#import "global.h"
#import "NCAccount.h"

@interface NCCharacterSheetViewController ()
- (void) didChangeAccount:(NSNotification*) note;

@end

@implementation NCCharacterSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAccount:) name:NCDidChangeAccountNotification object:nil];
	self.account.content = [NCAccount currentAccount];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private

- (void) didChangeAccount:(NSNotification*) note {
	NCAccount* account = note.object;
	self.account.content = account && !account.corporate ? account : nil;
}

@end
