//
//  NCMarketViewController.m
//  Neocom
//
//  Created by Artem Shimanski on 18.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCMarketViewController.h"
#import "NCDatabase.h"
#import "NCMarketOrdersViewController.h"
#import "NSOutlineView+Neocom.h"

@interface NCMarketNode : NSObject
@property (readonly) NSString* title;
@property (readonly) NSSet* items;
@property (readonly) NSImage* image;
@property (readonly, getter=isLeaf) BOOL leaf;
@property (strong) NCDBInvMarketGroup* marketGroup;
@property (strong) NCDBInvType* type;
@property (nonatomic, strong) NSPredicate* predicate;
@property (nonatomic, strong) NCMarketNode* marketNode;

- (id) initWithMarketGroup:(NCDBInvMarketGroup*) marketGroup;
- (id) initWithType:(NCDBInvType*) type;
- (id) initWithMarketNode:(NCMarketNode*) marketNode predicate:(NSPredicate*) predicate;

@end

@implementation NCMarketNode
@synthesize items = _items;

- (id) init {
	if (self = [super init]) {
		
	}
	return self;
}

- (id) initWithMarketGroup:(NCDBInvMarketGroup*) marketGroup {
	if (self = [super init]) {
		self.marketGroup = marketGroup;
	}
	return self;
}

- (id) initWithType:(NCDBInvType*) type {
	if (self = [super init]) {
		self.type = type;
	}
	return self;
}

- (id) initWithMarketNode:(NCMarketNode*) marketNode predicate:(NSPredicate*) predicate {
	if (self = [super init]) {
		self.marketNode = marketNode;
		self.predicate = predicate;
	}
	return self;
}


- (NSSet*) items {
	if (!_items) {
		if (self.marketGroup.subGroups.count > 0) {
			NSMutableSet* items = [NSMutableSet new];
			for (NCDBInvMarketGroup* subGroup in self.marketGroup.subGroups)
				[items addObject:[[NCMarketNode alloc] initWithMarketGroup:subGroup]];
			_items = items;
		}
		else if (self.marketGroup.types.count > 0) {
			NSMutableSet* items = [NSMutableSet new];
			for (NCDBInvType* type in self.marketGroup.types)
				[items addObject:[[NCMarketNode alloc] initWithType:type]];
			_items = items;
		}
		else if (self.marketNode && self.predicate) {
			NSMutableSet* items = [NSMutableSet new];
			for (NCMarketNode* node in self.marketNode.items) {
				if (node.type && [self.predicate evaluateWithObject:node])
					[items addObject:node];
				else {
					NCMarketNode* filteredNode = [[NCMarketNode alloc] initWithMarketNode:node predicate:self.predicate];
					if (filteredNode.items.count > 0)
						[items addObject:filteredNode];
				}
			}
			_items = items;
		}
	}
	return _items;
}

- (NSString*) title {
	if (self.marketGroup)
		return self.marketGroup.marketGroupName;
	else if (self.type)
		return self.type.typeName;
	else if (self.marketNode)
		return self.marketNode.title;
	else
		return nil;
}

- (NSImage*) image {
	if (self.marketGroup)
		return self.marketGroup.icon.image.image ?: [self.marketGroup.managedObjectContext defaultGroupIcon].image.image;
	else if (self.type)
		return self.type.icon.image.image ?: [self.type.managedObjectContext defaultTypeIcon].image.image;
	else if (self.marketNode)
		return self.marketNode.image;
	else
		return nil;
}

- (BOOL) isLeaf {
	return self.type != nil;
}

@end

@interface NCMarketRootNode : NCMarketNode {
	NSSet* _rootItems;
}

@end

@implementation NCMarketRootNode

- (NSSet*) items {
	if (!_rootItems) {
		NSMutableSet* items = [NSMutableSet new];
		NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
		NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"InvMarketGroup"];
		request.predicate = [NSPredicate predicateWithFormat:@"parentGroup == NULL"];
		
		for (NCDBInvMarketGroup* marketGroup in [context executeFetchRequest:request error:nil])
			[items addObject:[[NCMarketNode alloc] initWithMarketGroup:marketGroup]];
		_rootItems = items;
	}
	return _rootItems;
}

- (NSString*) title {
	return nil;
}

- (NSImage*) image {
	return nil;
}


@end


@interface NCMarketViewController ()
@property (nonatomic, strong) NCMarketRootNode* market;
@end

@implementation NCMarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.market = [NCMarketRootNode new];
	self.marketTree.content = self.market.items;
	self.marketTree.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
	[self.marketTree addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:nil];
	
//	NSSplitViewController* splitViewControlller = (NSSplitViewController*) [self parentViewController];
//	NSViewController* marketContainerViewController = [[splitViewControlller.splitViewItems lastObject] viewController];
//	NCMarketOrdersViewController* buyOrdersViewController = [[marketContainerViewController childViewControllers][0] childViewControllers][0];
}

- (void) dealloc {
	[self.marketTree removeObserver:self forKeyPath:@"selection"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if (object == self.marketTree && [keyPath isEqualToString:@"selection"]) {
		NCMarketNode* selection = [[self.marketTree selectedObjects] lastObject];
		if (selection.type)
			self.selectedType = selection.type;
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void) setSearchPredicate:(NSPredicate *)searchPredicate {
	_searchPredicate = searchPredicate;
	if (searchPredicate) {
		NCMarketNode* node = [[NCMarketNode alloc] initWithMarketNode:self.market predicate:searchPredicate];
		self.marketTree.content = [node items];
		[self.outlineView reloadData];
		[self.outlineView expandAll];
//		for (id item in [self.marketTree.arrangedObjects childNodes])
//			[self.outlineView expandItem:item expandChildren:YES];
	}
	else
		self.marketTree.content = self.market.items;
}

@end
