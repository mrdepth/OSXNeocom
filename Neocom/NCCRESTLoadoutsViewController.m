//
//  NCCRESTLoadoutsViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCCRESTLoadoutsViewController.h"
#import "NCLoadoutsViewController.h"
#import "NCStorage.h"
#import <EVEAPI/EVEAPI.h>
#import "NCSetting.h"
#import "NCDatabase.h"
#import "NSOutlineView+Neocom.h"

@interface NCCRESTLoadoutsViewController ()
@property (strong) CRAPI* api;
@end

@implementation NCCRESTLoadoutsViewController

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key {
	if ([key isEqualToString:@"token"])
		return NO;
	else
		return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSManagedObjectContext* context = [[NCStorage sharedStorage] managedObjectContext];
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Setting"];
	request.predicate = [NSPredicate predicateWithFormat:@"key BEGINSWITH \"sso\""];
	self.token = [(NCSetting*) [[context executeFetchRequest:request error:nil] lastObject] value];
	[self.outlineView registerForDraggedTypes:@[@"NCLoadoutsNode"]];
}

- (void) setToken:(CRToken *)token {
	[self willChangeValueForKey:@"token"];
	_token = token;
	[self didChangeValueForKey:@"token"];
	
	self.api = [CRAPI apiWithCachePolicy:NSURLRequestUseProtocolCachePolicy clientID:@"c2cc974798d4485d966fba773a8f7ef8" secretKey:@"GNhSE9GJ6q3QiuPSTIJ8Q1J6on4ClM4v9zvc0Qzu" token:token callbackURL:[NSURL URLWithString:@"neocom://sso"]];
	
	[self.api loadFittingsWithCompletionBlock:^(NSArray<CRFitting *> *result, NSError *error) {
		if (!error && self.api.token != _token && self.api.token) {
			[self willChangeValueForKey:@"token"];
			_token = self.api.token;
			[self didChangeValueForKey:@"token"];
			NSManagedObjectContext* context = [[NCStorage sharedStorage] managedObjectContext];
			[context settingWithKey:[NSString stringWithFormat:@"sso.%d", _token.characterID]].value = _token;
			[context save:nil];
		}
		
		NSManagedObjectContext* databaseManagedObjectContext = [[NCDatabase sharedDatabase] managedObjectContext];
		
		NSMutableDictionary* groups = [NSMutableDictionary new];
		
		for (CRFitting* loadout in result) {
			NCDBInvType* type = [databaseManagedObjectContext invTypeWithTypeID:loadout.ship.typeID];
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
	} progressBlock:nil];
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	return YES;
}

/* In 10.7 multiple drag images are supported by using this delegate method. */
- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item {
	return (id <NSPasteboardWriting>)[item representedObject];
}

/* Setup a local reorder. */
- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems {
	[session.draggingPasteboard setData:[NSData data] forType:@"NCLoadoutsNode"];
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)childIndex {
	if (childIndex == -1)
		return NSDragOperationNone;
	NSLog(@"outlineView:validateDrop:proposedItem:%@ proposedChildIndex:%ld", @"", (long)childIndex);
	NSLog(@"%@", info);
	return NSDragOperationCopy;
}

- (BOOL)outlineView:(NSOutlineView *)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)childIndex {
	return NO;
}

@end
