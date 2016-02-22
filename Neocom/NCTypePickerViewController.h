//
//  NCTypePickerViewController.h
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCDBDgmppItem, NCDBDgmppItemCategory, NCTypePickerViewController;
@protocol NCTypePickerViewControllerDelegate <NSObject>

- (void) typePickerController:(NCTypePickerViewController*)controller didSelectItem:(NCDBDgmppItem*) item;

@end

@interface NCTypePickerViewController : NSViewController
@property (strong) IBOutlet NSTreeController *typesTree;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) NSPredicate* searchPredicate;
@property (weak) id<NCTypePickerViewControllerDelegate> delegate;
@property (strong) NCDBDgmppItemCategory* category;

- (IBAction)didSelect:(NSArray*)selectedObjects;

@end
