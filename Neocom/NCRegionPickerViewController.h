//
//  NCRegionPickerViewController.h
//  Neocom
//
//  Created by Артем Шиманский on 19.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NCRegionPickerViewController : NSViewController
@property (strong) IBOutlet NSArrayController *regions;
@property (strong) NSObjectController* region;
- (IBAction)didSelectRow:(id)sender;

@end
