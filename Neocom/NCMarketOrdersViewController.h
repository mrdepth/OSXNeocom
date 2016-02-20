//
//  NCMarketOrdersViewController.h
//  Neocom
//
//  Created by Артем Шиманский on 19.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NCDatabase.h"
#import <EVEAPI/EVEAPI.h>

@interface NCMarketOrderNode : NSObject
@property (strong, readonly) NSAttributedString* location;
@property (strong, readonly) NSString* price;
@property (strong) NSMutableArray* orders;
@property (strong) NCDBMapSolarSystem* solarSystem;
@property (strong) NCDBStaStation* station;
@property (strong) CRMarketOrder* order;

@end

@interface NCMarketOrdersViewController : NSViewController
@property (strong) IBOutlet NSTreeController *marketOrders;
@property (strong) IBOutlet NSObjectController *region;
@property (strong) IBOutlet NSObjectController *type;
@property (weak) IBOutlet NSOutlineView *outlineView;
- (void) reload;
@end
