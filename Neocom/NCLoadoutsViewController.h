//
//  NCLoadoutsViewController.h
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCLoadout, NCDBInvGroup, NCDBInvType, CRFitting;
@interface NCLoadoutsNode : NSObject<NSPasteboardWriting, NSPasteboardReading, NSCoding>
@property (readonly) NSString* title;
@property (readonly) NSImage* image;
@property (strong) NSArray* children;
@property (strong) NCDBInvGroup* group;
@property (strong) NCDBInvType* type;
@property (strong) NCLoadout* loadout;
@property (strong) CRFitting* crestLoadout;
@end


@interface NCLoadoutsViewController : NSViewController
@property (strong) IBOutlet NSTreeController *loadouts;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSMenu *shareMenu;

- (IBAction)onRemove:(id)sender;
- (IBAction)didSelectFit:(NSArray*) selectedObjects;
- (IBAction)onShareButton:(id)sender;
- (IBAction)onImport:(id)sender;
- (IBAction)onExport:(id)sender;
@end
