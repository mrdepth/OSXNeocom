//
//  NCDgmItemsTreeController.h
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCDBDgmppItemGroup;
@class NCDBDgmppItem;
@interface NCDgmItemNode : NSObject
@property (readonly) NSString* title;
@property (readonly) NSArray* items;
@property (readonly) NSImage* image;
@property (readonly, getter=isLeaf) BOOL leaf;
@property (strong) NCDBDgmppItemGroup* group;
@property (strong) NCDBDgmppItem* item;
@property (nonatomic, strong) NSPredicate* predicate;
@property (nonatomic, strong) NCDgmItemNode* node;

- (id) initWithGroup:(NCDBDgmppItemGroup*) group;
- (id) initWithItem:(NCDBDgmppItem*) item;
- (id) initWithNode:(NCDgmItemNode*) node predicate:(NSPredicate*) predicate;

@end


@class NCShipFit;
@interface NCDgmItemsTreeController : NSTreeController
@property (nonatomic, strong) NCShipFit* fit;
@property (weak) IBOutlet NSOutlineView *outlineView;
@end
