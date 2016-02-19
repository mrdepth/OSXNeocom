//
//  NCMarketContainerViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 19.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCMarketContainerViewController.h"
#import "NCDatabase.h"
#import "NCRegionPickerViewController.h"
#import "NCMarketOrdersViewController.h"

@interface NCMarketContainerViewController ()

@end

@implementation NCMarketContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	NCMarketOrdersViewController* buyOrdersViewController = [self.childViewControllers[0] childViewControllers][0];
	[buyOrdersViewController.region bind:NSContentBinding toObject:self.region withKeyPath:@"content" options:nil];
}

- (void) prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"NCRegionPickerViewController"]) {
		NCRegionPickerViewController* controller = segue.destinationController;
		controller.region = self.region;
	}
}

@end
