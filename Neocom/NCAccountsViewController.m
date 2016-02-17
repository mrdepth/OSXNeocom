//
//  NCAccountsViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCAccountsViewController.h"
#import "NCStorage.h"
#import "NCAccount.h"
#import "global.h"

@interface NCAccountsViewController ()<NSTableViewDelegate, NSTableViewDataSource>
//@property (nonatomic, strong) NSMutableDictionary* heights;
@end

@implementation NCAccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.accounts.managedObjectContext = [[NCStorage sharedStorage] managedObjectContext];
	self.accounts.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]];
	[self.accounts addObserver:self forKeyPath:@"selectionIndex" options:NSKeyValueObservingOptionNew context:nil];
//	self.heights = [NSMutableDictionary new];
}

- (void) dealloc {
	[self.accounts removeObserver:self forKeyPath:@"selectionIndex"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if (object == self.accounts && [keyPath isEqualToString:@"selectionIndex"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NCDidChangeAccountNotification object:[self.accounts.selectedObjects lastObject]];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

/*- (void) tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
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
}*/


- (IBAction)onAdd:(id)sender {
	NSWindowController* controller = [self.storyboard instantiateControllerWithIdentifier:@"NCAddAccounts"];
	NSWindow* window = [controller window];
	[self.view.window beginSheet:window completionHandler:^(NSModalResponse returnCode) {
	}];
	[NSApp runModalForWindow:window];
	[self.view.window endSheet:window];
}

- (IBAction)onRemove:(id)sender {
	NSManagedObjectContext* context = [[NCStorage sharedStorage] managedObjectContext];
	for (NCAccount* account in [self.accounts selectedObjects]) {
		[context deleteObject:account];
	}
	if ([context hasChanges])
		[context save:nil];
}

- (NSManagedObjectContext*) managedObjectContext {
	return [[NCStorage sharedStorage] managedObjectContext];
}

- (void) tableView:(NSTableView *)tableView didClickTableColumn:(nonnull NSTableColumn *)tableColumn {
	
}

@end
