//
//  NCTypePickerViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCTypePickerViewController.h"
#import "NCDatabase.h"
#import "NSOutlineView+Neocom.h"

@interface NCTypeNode : NSObject
@property (readonly) NSString* title;
@property (readonly) NSSet* items;
@property (readonly) NSImage* image;
@property (readonly, getter=isLeaf) BOOL leaf;
@property (strong) NCDBDgmppItemGroup* group;
@property (strong) NCDBDgmppItem* item;
@property (nonatomic, strong) NSPredicate* predicate;
@property (nonatomic, strong) NCTypeNode* typeNode;

- (id) initWithGroup:(NCDBDgmppItemGroup*) group;
- (id) initWithItem:(NCDBDgmppItem*) item;
- (id) initWithTypeNode:(NCTypeNode*) typeNode predicate:(NSPredicate*) predicate;

@end

@implementation NCTypeNode
@synthesize items = _items;

- (id) initWithGroup:(NCDBDgmppItemGroup*) group {
	if (self = [super init]) {
		self.group = group;
	}
	return self;
}

- (id) initWithItem:(NCDBDgmppItem*) item {
	if (self = [super init]) {
		self.item = item;
	}
	return self;
}

- (id) initWithTypeNode:(NCTypeNode*) typeNode predicate:(NSPredicate*) predicate {
	if (self = [super init]) {
		self.typeNode = typeNode;
		self.predicate = predicate;
	}
	return self;
}


- (NSSet*) items {
	if (!_items) {
		if (self.group.subGroups.count > 0) {
			NSMutableSet* items = [NSMutableSet new];
			for (NCDBDgmppItemGroup* subGroup in self.group.subGroups)
				[items addObject:[[NCTypeNode alloc] initWithGroup:subGroup]];
			_items = items;
		}
		else if (self.group.items.count > 0) {
			NSMutableSet* items = [NSMutableSet new];
			for (NCDBDgmppItem* item in self.group.items)
				[items addObject:[[NCTypeNode alloc] initWithItem:item]];
			_items = items;
		}
		else if (self.typeNode && self.predicate) {
			NSMutableSet* items = [NSMutableSet new];
			for (NCTypeNode* node in self.typeNode.items) {
				if (node.item && [self.predicate evaluateWithObject:node])
					[items addObject:node];
				else {
					NCTypeNode* filteredNode = [[NCTypeNode alloc] initWithTypeNode:node predicate:self.predicate];
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
	if (self.group)
		return self.group.groupName;
	else if (self.item)
		return self.item.type.typeName;
	else if (self.typeNode)
		return self.typeNode.title;
	else
		return nil;
}

- (NSImage*) image {
	if (self.group)
		return self.group.icon.image.image ?: [self.group.managedObjectContext defaultGroupIcon].image.image;
	else if (self.item)
		return self.item.type.icon.image.image ?: [self.item.type.managedObjectContext defaultTypeIcon].image.image;
	else if (self.typeNode)
		return self.typeNode.image;
	else
		return nil;
}

- (BOOL) isLeaf {
	return self.item != nil;
}

@end

@interface NCTypeRootNode : NCTypeNode {
	NSSet* _rootItems;
}
@property (strong) NCDBDgmppItemCategory* category;

- (id) initWithCategory:(NCDBDgmppItemCategory*) category;
@end

@implementation NCTypeRootNode

- (id) initWithCategory:(NCDBDgmppItemCategory *)category {
	if (self = [super init]) {
		self.category = category;
	}
	return self;
}

- (NSSet*) items {
	if (!_rootItems) {
		NSMutableSet* items = [NSMutableSet new];
		NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];

		NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"DgmppItemGroup"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"groupName" ascending:YES]];
		request.predicate = [NSPredicate predicateWithFormat:@"category == %@ AND parentGroup == NULL", self.category];
		NSSet* results = [NSSet setWithArray:[context executeFetchRequest:request error:nil]];
		while (results.count == 1) {
			NCDBDgmppItemGroup* group = [results anyObject];
			if (group.subGroups.count > 0)
				results = group.subGroups;
		}
		
		for (NCDBDgmppItemGroup* group in results)
			[items addObject:[[NCTypeNode alloc] initWithGroup:group]];
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



@interface NCTypePickerViewController ()
@property (nonatomic, strong) NCTypeRootNode* types;
@end

@implementation NCTypePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.types = [[NCTypeRootNode alloc] initWithCategory:self.category];
	self.typesTree.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
}
- (void) viewDidAppear {
	[super viewDidAppear];
	self.typesTree.content = self.types.items;
}

- (void) setSearchPredicate:(NSPredicate *)searchPredicate {
	_searchPredicate = searchPredicate;
	if (searchPredicate) {
		NCTypeNode* node = [[NCTypeNode alloc] initWithTypeNode:self.types predicate:searchPredicate];
		self.typesTree.content = [node items];
		[self.outlineView reloadData];
		[self.outlineView expandAll];
	}
	else
		self.typesTree.content = self.types.items;
}

- (IBAction)didSelect:(NSArray*)selectedObjects {
	if (selectedObjects.count > 0) {
		NCTypeNode* node = [selectedObjects lastObject];
		if (node.item) {
			[self.delegate typePickerController:self didSelectItem:node.item];
		}
	}
}


@end
