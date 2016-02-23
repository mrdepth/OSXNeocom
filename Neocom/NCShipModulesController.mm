//
//  NCShipModulesController.m
//  Neocom
//
//  Created by Artem Shimanski on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCShipModulesController.h"
#import "NCShipFitController.h"

@interface NCShipModulesController()
@end

@implementation NCShipModulesController

- (BOOL) canRemove {
	BOOL b = [super canRemove];
	return b;
}

- (void) remove:(id)sender {
	if ([[self selectedObjects] count] > 0) {
		NSDictionary* info = [self infoForBinding:NSContentArrayBinding];
		NSObjectController* controller = info[NSObservedObjectKey];
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

- (NSInteger) numberOfItemsInMenu:(NSMenu *)menu {
	return 2;
}

- (BOOL)menu:(NSMenu*)menu updateItem:(NSMenuItem*)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel {
	if (index == 1) {
		[item setTitle:NSLocalizedString(@"Delete 1", nil)];
		[item setAction:@selector(canRemove)];
		[item setTarget:self];
		unichar c = NSDeleteCharacter;
		[item setKeyEquivalent:[NSString stringWithCharacters:&c length:1]];
	}
	return YES;
}

- (BOOL) menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(id  _Nullable __autoreleasing *)target action:(SEL  _Nullable *)action {
	return NO;
}

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

@end
