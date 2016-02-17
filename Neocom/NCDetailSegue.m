//
//  NCDetailSegue.m
//  Neocom
//
//  Created by Артем Шиманский on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCDetailSegue.h"

@implementation NCDetailSegue

- (void) perform {
	NSSplitViewController* splitViewController = (NSSplitViewController*) [self.sourceController contentViewController];
	NSSplitViewItem* item = [NSSplitViewItem splitViewItemWithViewController:self.destinationController];
	[splitViewController removeSplitViewItem:[splitViewController.splitViewItems lastObject]];
	[splitViewController addSplitViewItem:item];
}

@end
