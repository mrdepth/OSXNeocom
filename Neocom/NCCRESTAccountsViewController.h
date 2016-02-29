//
//  NCCRESTAccountsViewController.h
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCCRESTAccountsViewController, CRToken;
@protocol NCCRESTAccountsViewControllerDelegate <NSObject>

- (void) crestAccountsViewController:(NCCRESTAccountsViewController*)controller didSelectAccountWithToken:(CRToken*) token;

@end

@interface NCCRESTAccountsViewController : NSViewController
@property (strong) IBOutlet NSArrayController *accounts;
@property (weak) id<NCCRESTAccountsViewControllerDelegate> delegate;

- (IBAction)onAddAccount:(id)sender;
- (IBAction)onRemove:(id)sender;
- (IBAction)onSelect:(id)sender;

@end
