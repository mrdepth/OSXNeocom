//
//  NCShipDronesController.m
//  Neocom
//
//  Created by Артем Шиманский on 25.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCShipDronesController.h"
#import "NCShipFitController.h"

@interface NCShipDronesController()
@property (readonly) NSObjectController* contentController;

- (void) removeStack;
@end

@implementation NCShipDronesController

- (void) remove:(id)sender {
	if ([[self selectedObjects] count] > 0) {
		NSObjectController* controller = self.contentController;
		[controller objectDidBeginEditing:self];
		for (NCShipDrone* drone in [self selectedObjects]) {
			if (drone.drones.size() > 0) {
				auto d = drone.drones.front();
				auto ship = std::dynamic_pointer_cast<dgmpp::Ship>(d->getOwner());
				ship->removeDrone(d);
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
	if ([self.selectedObjects count] > 0) {
		[menu addItemWithTitle:NSLocalizedString(@"Remove Drone", nil) action:@selector(remove:) keyEquivalent:@""].target = self;
		[menu addItemWithTitle:NSLocalizedString(@"Remove Drone Stack", nil) action:@selector(removeStack) keyEquivalent:@""].target = self;
	}
}

#pragma mark - Private

- (NSObjectController*) contentController {
	NSDictionary* info = [self infoForBinding:NSContentArrayBinding];
	return info[NSObservedObjectKey];
}

- (void) removeStack {
	if ([[self selectedObjects] count] > 0) {
		NSObjectController* controller = self.contentController;
		[controller objectDidBeginEditing:self];
		for (NCShipDrone* drone in [self selectedObjects]) {
			for (auto d: drone.drones) {
				auto ship = std::dynamic_pointer_cast<dgmpp::Ship>(d->getOwner());
				ship->removeDrone(d);
			}
		}
		[controller objectDidEndEditing:self];
	}
}

@end
