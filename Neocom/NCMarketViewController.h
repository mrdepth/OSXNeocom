//
//  NCMarketViewController.h
//  Neocom
//
//  Created by Artem Shimanski on 18.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCDBInvType;
@interface NCMarketViewController : NSViewController
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSTreeController *marketTree;
@property (nonatomic, strong) NSPredicate* searchPredicate;
@property (nonatomic, strong) NCDBInvType* selectedType;

@end
