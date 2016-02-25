//
//  NCLoadoutsViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCLoadoutsViewController.h"
#import "NCStorage.h"
#import "NCDatabase.h"
#import "NCLoadout.h"
#import "NCLoadoutData.h"
#import "NCTypePickerViewController.h"
#import "NSOutlineView+Neocom.h"
#import "NCShipFittingViewController.h"
#import "NCShipFit.h"

@interface NCLoadoutsNode : NSObject
@property (readonly) NSString* title;
@property (readonly) NSImage* image;
@property (strong) NSArray* children;
@property (strong) NCDBInvGroup* group;
@property (strong) NCDBInvType* type;
@property (strong) NCLoadout* loadout;

@end

@implementation NCLoadoutsNode

- (NSString*) title {
	if (self.group)
		return self.group.groupName;
	else if (self.type)
		return self.type.typeName;
	else if (self.loadout)
		return self.loadout.name;
	else
		return nil;
}

- (NSImage*) image {
	if (self.group)
		return self.group.icon.image.image ?: [[self.group managedObjectContext] defaultGroupIcon].image.image;
	else if (self.type)
		return self.type.icon.image.image ?: [[self.type managedObjectContext] defaultTypeIcon].image.image;
	else
		return [NSImage imageNamed:@"fitting"];
}


@end

@interface NCLoadoutsViewController ()<NCTypePickerViewControllerDelegate, NSOutlineViewDelegate>
- (void) reload;

@end

@implementation NCLoadoutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self reload];
    // Do view setup here.
}

- (void) prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"NCTypePickerViewController"]) {
		NCTypePickerViewController* controller = segue.destinationController;
		controller.category = [[[NCDatabase sharedDatabase] managedObjectContext] categoryWithSlot:NCDBDgmppItemSlotShip size:0 race:nil];
		controller.delegate = self;
	}
	else if ([segue.identifier isEqualToString:@"NCShipFittingViewController"]) {
		NCLoadoutsNode* node = [self.loadouts.selectedObjects lastObject];

		NCShipFittingViewController* controller = segue.destinationController;
		controller.fit = [[NCShipFit alloc] initWithLoadout:node.loadout];
	}
}

- (IBAction)onRemove:(id)sender {
	NSManagedObjectContext* context = [[NCStorage sharedStorage] managedObjectContext];
	
	__weak __block void (^weakRemove)(NCLoadoutsNode*);
	void (^remove)(NCLoadoutsNode*) = ^(NCLoadoutsNode* node) {
		if (node.loadout)
			[context deleteObject:node.loadout];
		for (NCLoadoutsNode* item in node.children)
			weakRemove(item);
	};
	weakRemove = remove;
	
	for (NCLoadoutsNode* node in [self.loadouts selectedObjects]) {
		remove(node);
	}
	if ([context hasChanges]) {
		[context save:nil];
		[self reload];
	}
}

- (IBAction)didSelectFit:(NSArray*) selectedObjects {
	if (selectedObjects.count > 0) {
		NCLoadoutsNode* node = [selectedObjects lastObject];
		if (node.loadout) {
			for (NSWindow* window in [NSApp windows]) {
				if ([window.windowController.contentViewController isKindOfClass:[NCShipFittingViewController class]]) {
					NCShipFittingViewController* shipFittingViewController = (NCShipFittingViewController*) window.windowController.contentViewController;
					if ([shipFittingViewController.fit.loadoutID isEqualTo:node.loadout.objectID]) {
						[window makeKeyAndOrderFront:self];
						return;
					}
				}
			}
			[self performSegueWithIdentifier:@"NCShipFittingViewController" sender:node.loadout];
//			NCShipFittingViewController* controller = [self.storyboard instantiateControllerWithIdentifier:@"NCShipFittingViewController"];
//			controller.fit = [[NCShipFit alloc] initWithLoadout:node.loadout];
			/*NSSplitViewController* splitViewController = (NSSplitViewController*) self.parentViewController;
			if (splitViewController.splitViewItems.count > 1)
				[splitViewController removeSplitViewItem:[splitViewController.splitViewItems lastObject]];
			NSSplitViewItem* item = [NSSplitViewItem splitViewItemWithViewController:controller];
			[splitViewController addSplitViewItem:item];*/
		}
	}
}


#pragma mark - NCTypePickerViewControllerDelegate

- (void) typePickerController:(NCTypePickerViewController*)controller didSelectItem:(NCDBDgmppItem*) item {
	[controller dismissController:self];
	
	NSManagedObjectContext* context = [[NCStorage sharedStorage] managedObjectContext];
	NCLoadout* loadout = [[NCLoadout alloc] initWithEntity:[NSEntityDescription entityForName:@"Loadout" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
	loadout.typeID = item.type.typeID;
	loadout.name = item.type.typeName;
	loadout.data = [[NCLoadoutData alloc] initWithEntity:[NSEntityDescription entityForName:@"LoadoutData" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
	[context save:nil];
	[self reload];
	//fit = [[NCShipFit alloc] initWithLoadout:loadout];
}

#pragma mark - Private

- (void) reload {
	NSManagedObjectContext* databaseManagedObjectContext = [[NCDatabase sharedDatabase] managedObjectContext];
	NSManagedObjectContext* storageManagedObjectContext = [[NCStorage sharedStorage] managedObjectContext];
	NSMutableDictionary* groups = [NSMutableDictionary new];

	for (NCLoadout* loadout in [storageManagedObjectContext loadouts]) {
		NCDBInvType* type = [databaseManagedObjectContext invTypeWithTypeID:loadout.typeID];
		if (!type)
			continue;

		NSMutableDictionary* group = groups[@(type.group.groupID)];
		if (!group) {
			groups[@(type.group.groupID)] = group = [NSMutableDictionary new];
		}
		NSMutableArray* types = group[@(type.typeID)];
		if (!types)
			group[@(type.typeID)] = types = [NSMutableArray new];
		[types addObject:loadout];
	}
	
	NSMutableArray* content = [NSMutableArray new];
	[groups enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDictionary*  _Nonnull group, BOOL * _Nonnull stop) {
		NCDBInvGroup* invGroup = [databaseManagedObjectContext invGroupWithGroupID:[key intValue]];
		NCLoadoutsNode* groupNode = [NCLoadoutsNode new];
		[content addObject:groupNode];
		
		groupNode.group = invGroup;
		NSMutableArray* children = [NSMutableArray new];
		groupNode.children = children;
		[group enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray*  _Nonnull types, BOOL * _Nonnull stop) {
			NCDBInvType* invType = [databaseManagedObjectContext invTypeWithTypeID:[key intValue]];
			NCLoadoutsNode* typeNode = [NCLoadoutsNode new];
			[children addObject:typeNode];

			typeNode.type = invType;
			NSMutableArray* children = [NSMutableArray new];
			typeNode.children = children;
			
			for (NCLoadout* loadout in types) {
				NCLoadoutsNode* loadoutNode = [NCLoadoutsNode new];
				[children addObject:loadoutNode];
				loadoutNode.loadout = loadout;
			}
			[children sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
		}];
		[children sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
	}];
	[content sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
	self.loadouts.content = content;
	[self.outlineView expandAll];
}

@end
