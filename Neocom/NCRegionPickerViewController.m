//
//  NCRegionPickerViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 19.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCRegionPickerViewController.h"
#import "NCDatabase.h"

@interface NCRegionPickerViewController ()

@end

@implementation NCRegionPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.regions.managedObjectContext = [[NCDatabase sharedDatabase] managedObjectContext];
	self.regions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:YES]];
    // Do view setup here.
}

- (IBAction)didSelectRow:(id)sender {
	if (self.regions.selectedObjects.count > 0) {
		self.region.content = [self.regions.selectedObjects lastObject];
		[self dismissController:sender];
	}
}
@end
