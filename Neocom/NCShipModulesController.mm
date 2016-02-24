//
//  NCShipModulesController.m
//  Neocom
//
//  Created by Artem Shimanski on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCShipModulesController.h"
#import "NCShipFitController.h"
#import "NCDatabase.h"

@interface NCShipModulesController()
@property (readonly) NSObjectController* contentController;
- (void) putOffline;
- (void) putOnline;
- (void) activate;
- (void) enableOverheating;
- (void) setAmmo:(NSMenuItem*) sender;
- (void) unloadAmmo;
@end

@implementation NCShipModulesController

- (BOOL) canRemove {
	BOOL b = [super canRemove];
	return b;
}

- (void) remove:(id)sender {
	if ([[self selectedObjects] count] > 0) {
		NSObjectController* controller = self.contentController;
		[controller objectDidBeginEditing:self];
		for (NCShipModule* module in [self selectedObjects]) {
			if (module.module) {
				auto ship = std::dynamic_pointer_cast<dgmpp::Ship>(module.module->getOwner());
				ship->removeModule(module.module);
			}
		}
		[controller objectDidEndEditing:self];
	}
}

#pragma mark - NSMenuDelegate

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
	return YES;
}

- (void) setContent:(id)content {
	NSMutableIndexSet* set = [self.selectionIndexes mutableCopy];
	[super setContent:content];
	NSUInteger n = [self.arrangedObjects count];
	[set removeIndexesInRange:NSMakeRange(n, 1000)];
	self.selectionIndexes = set;
}

- (void)menuNeedsUpdate:(NSMenu*)menu {
	[menu removeAllItems];
	
	NSMutableSet* chargeCategories = [NSMutableSet new];
	BOOL hasModules = NO;
	
	std::set<dgmpp::Module::State> possibleStates;
	dgmpp::Module::State highestState = dgmpp::Module::STATE_ONLINE;
	
	NSMutableSet* charges = [NSMutableSet new];
	
	for (NCShipModule* module in self.selectedObjects) {
		if (module.module) {
			hasModules = YES;
			if (module.item.charge)
				[chargeCategories addObject:module.item.charge];
			auto state = module.module->getState();
			if (state > highestState)
				highestState = state;
			for (auto s: {dgmpp::Module::STATE_OFFLINE, dgmpp::Module::STATE_ONLINE, dgmpp::Module::STATE_ACTIVE, dgmpp::Module::STATE_OVERLOADED}) {
				if (s != state && module.module->canHaveState(s))
					possibleStates.insert(s);
			}
			auto charge = module.module->getCharge();
			if (charge)
				[charges addObject:@(charge->getTypeID())];
		}
	}
	if (!hasModules)
		return;
	
	[menu addItemWithTitle:NSLocalizedString(@"Delete", nil) action:@selector(remove:) keyEquivalent:@""].target = self;
	
	//[menuItems addObject:@{@"title":NSLocalizedString(@"Delete", nil), @"action":[NSValue valueWithPointer:(void*) @selector(remove:)]}];
	
	if (possibleStates.find(dgmpp::Module::STATE_OFFLINE) != possibleStates.end())
		[menu addItemWithTitle:NSLocalizedString(@"Put Offline", nil) action:@selector(putOffline) keyEquivalent:@""].target = self;
	
	if (possibleStates.find(dgmpp::Module::STATE_ONLINE) != possibleStates.end())
		[menu addItemWithTitle:highestState > dgmpp::Module::STATE_ONLINE ? NSLocalizedString(@"Deactivate", nil) : NSLocalizedString(@"Put Online", nil) action:@selector(putOnline) keyEquivalent:@""].target = self;

	if (possibleStates.find(dgmpp::Module::STATE_ACTIVE) != possibleStates.end())
		[menu addItemWithTitle:highestState > dgmpp::Module::STATE_ACTIVE ? NSLocalizedString(@"Disable Overheating", nil) : NSLocalizedString(@"Activate", nil) action:@selector(activate) keyEquivalent:@""].target = self;
	
	if (possibleStates.find(dgmpp::Module::STATE_OVERLOADED) != possibleStates.end())
		[menu addItemWithTitle:NSLocalizedString(@"Enable Overheating", nil) action:@selector(enableOverheating) keyEquivalent:@""].target = self;
	
	if (chargeCategories.count == 1) {
		NSMenuItem* ammoMenuItem = [menu addItemWithTitle:NSLocalizedString(@"Ammo", nil) action:nil keyEquivalent:@""];
		ammoMenuItem.submenu = [[NSMenu alloc] initWithTitle:@""];
		NCDBDgmppItemCategory* category = [chargeCategories anyObject];
		
		NSMutableArray* groups = [[category.itemGroups allObjects] mutableCopy];
		NSMutableArray* items = [NSMutableArray new];
		while (groups.count > 0) {
			NCDBDgmppItemGroup* group = [groups lastObject];
			[groups removeLastObject];
			if (group.subGroups.count > 0)
				[groups addObjectsFromArray:[group.subGroups allObjects]];
			if (group.items)
				[items addObjectsFromArray:[group.items allObjects]];
		}
		
		[items sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"type.metaGroup.metaGroupID" ascending:YES],
									  [NSSortDescriptor sortDescriptorWithKey:@"type.metaLevel" ascending:YES],
									  [NSSortDescriptor sortDescriptorWithKey:@"type.typeName" ascending:YES]]];
		NSMutableDictionary* metaGroups = [NSMutableDictionary new];
		for (NCDBDgmppItem* item in items) {
			NSMutableArray* group = metaGroups[@(item.type.metaGroup.metaGroupID)];
			if (!group)
				metaGroups[@(item.type.metaGroup.metaGroupID)] = group = [NSMutableArray new];
			[group addObject:item];
		}
		for (id key in [[metaGroups allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
			NSArray* items = metaGroups[key];
			NCDBDgmppItem* item = items[0];
			[ammoMenuItem.submenu addItemWithTitle:[NSString stringWithFormat:@"---%@---", item.type.metaGroupName] action:nil keyEquivalent:@""];
			for (NCDBDgmppItem* item in items) {
				NSMenuItem* menuItem = [ammoMenuItem.submenu addItemWithTitle:item.type.typeName action:@selector(setAmmo:) keyEquivalent:@""];
				if ([charges containsObject:@(item.type.typeID)])
					menuItem.state = NSOnState;
				menuItem.target = self;
				menuItem.representedObject = item;
			}
		}
	}
	
	if (charges.count > 0)
		[menu addItemWithTitle:NSLocalizedString(@"Unload Ammo", nil) action:@selector(unloadAmmo) keyEquivalent:@""].target = self;
}

#pragma mark - Private

- (NSObjectController*) contentController {
	NSDictionary* info = [self infoForBinding:NSContentArrayBinding];
	return info[NSObservedObjectKey];
}

- (void) putOffline {
	[self.contentController objectDidBeginEditing:self];
	for (NCShipModule* module in self.selectedObjects)
		if (module.module)
			module.module->setPreferredState(dgmpp::Module::STATE_OFFLINE);
	[self.contentController objectDidEndEditing:self];
}

- (void) putOnline {
	[self.contentController objectDidBeginEditing:self];
	for (NCShipModule* module in self.selectedObjects)
		if (module.module)
			module.module->setPreferredState(dgmpp::Module::STATE_ONLINE);
	[self.contentController objectDidEndEditing:self];
}

- (void) activate {
	[self.contentController objectDidBeginEditing:self];
	for (NCShipModule* module in self.selectedObjects)
		if (module.module)
			module.module->setPreferredState(dgmpp::Module::STATE_ACTIVE);
	[self.contentController objectDidEndEditing:self];
}

- (void) enableOverheating {
	[self.contentController objectDidBeginEditing:self];
	for (NCShipModule* module in self.selectedObjects)
		if (module.module)
			module.module->setPreferredState(dgmpp::Module::STATE_OVERLOADED);
	[self.contentController objectDidEndEditing:self];
}

- (void) setAmmo:(NSMenuItem*) sender {
	[self.contentController objectDidBeginEditing:self];
	NCDBDgmppItem* item = sender.representedObject;
	for (NCShipModule* module in self.selectedObjects)
		if (module.module)
			module.module->setCharge(item.type.typeID);
	[self.contentController objectDidEndEditing:self];
}

- (void) unloadAmmo {
	[self.contentController objectDidBeginEditing:self];
	for (NCShipModule* module in self.selectedObjects)
		if (module.module)
			module.module->clearCharge();
	[self.contentController objectDidEndEditing:self];
}

@end
