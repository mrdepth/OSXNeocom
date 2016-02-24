//
//  NCDgmItemsTreeController.m
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCDgmItemsTreeController.h"
#import "NCDatabase.h"
#import "NCShipFit.h"
#import "NSOutlineView+Neocom.h"

@implementation NCDgmItemNode
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

- (id) initWithNode:(NCDgmItemNode*) node predicate:(NSPredicate*) predicate {
	if (self = [super init]) {
		self.node = node;
		self.predicate = predicate;
	}
	return self;
}


- (NSArray*) items {
	if (!_items) {
		NSMutableArray* items;
		if (self.group.subGroups.count > 0) {
			items = [NSMutableArray new];
			for (NCDBDgmppItemGroup* subGroup in self.group.subGroups)
				[items addObject:[[NCDgmItemNode alloc] initWithGroup:subGroup]];
		}
		else if (self.group.items.count > 0) {
			items = [NSMutableArray new];
			for (NCDBDgmppItem* item in self.group.items)
				[items addObject:[[NCDgmItemNode alloc] initWithItem:item]];
		}
		else if (self.node && self.predicate) {
			items = [NSMutableArray new];
			for (NCDgmItemNode* node in self.node.items) {
				if (node.item && [self.predicate evaluateWithObject:node])
					[items addObject:node];
				else {
					NCDgmItemNode* filteredNode = [[NCDgmItemNode alloc] initWithNode:node predicate:self.predicate];
					if (filteredNode.items.count > 0)
						[items addObject:filteredNode];
				}
			}
		}
		[items sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
		_items = items;
	}
	return _items;
}

- (NSString*) title {
	if (self.group)
		return self.group.groupName;
	else if (self.item)
		return self.item.type.typeName;
	else if (self.node)
		return self.node.title;
	else
		return nil;
}

- (NSImage*) image {
	if (self.group)
		return self.group.icon.image.image ?: [self.group.managedObjectContext defaultGroupIcon].image.image;
	else if (self.item)
		return self.item.type.icon.image.image ?: [self.item.type.managedObjectContext defaultTypeIcon].image.image;
	else if (self.node)
		return self.node.image;
	else
		return nil;
}

- (BOOL) isLeaf {
	return self.item != nil;
}

@end

@interface NCDgmItemRootNode : NCDgmItemNode {
	NSMutableArray* _rootItems;
}
@property (strong) NCShipFit* fit;

- (id) initWithFit:(NCShipFit*) fit;

@end

@implementation NCDgmItemRootNode

- (id) initWithFit:(NCShipFit*) fit {
	if (self = [super init]) {
		self.fit = fit;
	}
	return self;
}

- (NSMutableArray*) items {
	if (!_rootItems) {
		NSMutableArray* items = [NSMutableArray new];
		NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
		
		NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"DgmppItemGroup"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"groupName" ascending:YES]];
		
		NCDBInvType* type = [context invTypeWithTypeID:self.fit.typeID];
		NSMutableArray* categories = [@[[context categoryWithSlot:NCDBDgmppItemSlotHi size:0 race:nil],
								[context categoryWithSlot:NCDBDgmppItemSlotMed size:0 race:nil],
								[context categoryWithSlot:NCDBDgmppItemSlotLow size:0 race:nil],
								[context categoryWithSlot:NCDBDgmppItemSlotRig size:self.fit.pilot->getShip()->getRigSize() race:nil],
										] mutableCopy];
		if (self.fit.pilot->getShip()->getNumberOfSlots(dgmpp::Module::SLOT_SUBSYSTEM) > 0)
			[categories addObject:[context categoryWithSlot:NCDBDgmppItemSlotSubsystem size:0 race:type.race]];
		
		request.predicate = [NSPredicate predicateWithFormat:@"category IN %@ AND parentGroup == NULL", categories];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"category.category" ascending:YES]];
		NSArray* results = [context executeFetchRequest:request error:nil];
		
		for (NCDBDgmppItemGroup* group in results)
			[items addObject:[[NCDgmItemNode alloc] initWithGroup:group]];
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

@interface NCDgmItemsTreeController()
@property (strong) NCDgmItemRootNode* dgmItemRootNode;
@end


@implementation NCDgmItemsTreeController

- (void) awakeFromNib {
	//self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
}

- (void) setFit:(NCShipFit *)fit {
	_fit = fit;
	self.dgmItemRootNode = [[NCDgmItemRootNode alloc] initWithFit:fit];
	self.content = self.dgmItemRootNode.items;
}

- (void) setFetchPredicate:(NSPredicate *)fetchPredicate {
	[super setFetchPredicate:fetchPredicate];
	if (fetchPredicate) {
		NCDgmItemNode* node = [[NCDgmItemNode alloc] initWithNode:self.dgmItemRootNode predicate:fetchPredicate];
		self.content = node.items;
		[self.outlineView expandAll];
	}
	else
		self.content = self.dgmItemRootNode.items;
}

@end
