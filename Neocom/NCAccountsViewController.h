//
//  NCAccountsViewController.h
//  Neocom
//
//  Created by Артем Шиманский on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NCAccountsViewController : NSViewController
@property (strong) IBOutlet NSArrayController *accounts;
@property (weak) IBOutlet NSTableView *tableView;
- (IBAction)onAdd:(id)sender;
- (IBAction)onRemove:(id)sender;

@end
