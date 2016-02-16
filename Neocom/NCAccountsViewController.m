//
//  NCAccountsViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCAccountsViewController.h"

@interface NCRowView : NSTableRowView

@end

@implementation NCRowView

- (void) awakeFromNib {
	self.translatesAutoresizingMaskIntoConstraints = YES;
}

@end

@interface NCCell : NSTableCellView
@end

@implementation NCCell

@end

@interface NCAccountsViewController ()<NSTableViewDelegate, NSTableViewDataSource>
@property (nonatomic, strong) NSMutableDictionary* heights;
@end

@implementation NCAccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.heights = [NSMutableDictionary new];
	for (int i = 0; i < 30; i++)
		[self.accounts addObject:@{@"title":@"test"}];
}

- (void) tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
	NSView* v = [rowView viewAtColumn:0];
	NSSize s = [v fittingSize];
	self.heights[@(row)] = @(s.height);
	[tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
}

- (CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	NSNumber* h = self.heights[@(row)];
	if (!h)
		return 17;
	else
		return [h floatValue];
}


- (IBAction)onAdd:(id)sender {
	NSWindowController* controller = [self.storyboard instantiateControllerWithIdentifier:@"NCAddAccounts"];
	NSWindow* window = [controller window];
	[self.view.window beginSheet:window completionHandler:^(NSModalResponse returnCode) {
	}];
	[NSApp runModalForWindow:window];
	[self.view.window endSheet:window];
}
@end
