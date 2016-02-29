//
//  NCCRESTLoadoutsViewController.h
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CRToken;
@interface NCCRESTLoadoutsViewController : NSViewController
@property (nonatomic, strong) CRToken* token;
@property (strong) IBOutlet NSTreeController *loadouts;
@property (weak) IBOutlet NSOutlineView *outlineView;

- (IBAction)didSelectFit:(NSArray*) selectedObjects;
- (IBAction)onRemove:(id)sender;

@end
