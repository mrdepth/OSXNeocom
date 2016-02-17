//
//  NCAddAPIKeyViewController.h
//  Neocom
//
//  Created by Artem Shimanski on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NCAddAPIKeyViewController : NSViewController
@property (weak) IBOutlet NSTextField *keyIDTextField;
@property (weak) IBOutlet NSTextField *vCodeTextField;
@property (weak) IBOutlet NSTextField *errorTextField;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong, nonatomic) NSArray* accounts;

- (IBAction)onAdd:(id)sender;
- (IBAction)onLink:(id)sender;

@end
