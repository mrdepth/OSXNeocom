//
//  NCBuyOrdersViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 19.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCBuyOrdersViewController.h"
#import "NSOutlineView+Neocom.h"

@interface NCBuyOrdersViewController ()

@end

@implementation NCBuyOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void) reload {
	NCDBMapRegion* region = [self.region.selectedObjects lastObject];
	NCDBInvType* type = [self.type.selectedObjects lastObject];
	if (region && type) {
		[[CRAPI publicApiWithCachePolicy:NSURLRequestUseProtocolCachePolicy] loadBuyOrdersWithTypeID:type.typeID regionID:region.regionID completionBlock:^(CRMarketOrderCollection *marketOrders, NSError *error) {
			NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
			
			NSMutableDictionary* solarSystems = [NSMutableDictionary new];
			for (CRMarketOrder* order in marketOrders.items) {
				NCDBStaStation* station = [context staStationWithStationID:order.stationID];
				if (station) {
					NCMarketOrderNode* solarSystem = solarSystems[@(station.solarSystem.solarSystemID)];
					if (!solarSystem) {
						solarSystem = [NCMarketOrderNode new];
						solarSystem.solarSystem = station.solarSystem;
						solarSystem.orders = [NSMutableArray new];
						solarSystems[@(station.solarSystem.solarSystemID)] = solarSystem;
					}
					NCMarketOrderNode* orderNode = [NCMarketOrderNode new];
					orderNode.station = station;
					orderNode.order = order;
					[solarSystem.orders addObject:orderNode];
				}
			}
			for (NCMarketOrderNode* solarSystem in [solarSystems allValues])
				[solarSystem.orders sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order.price" ascending:NO]]];
			self.marketOrders.content = [[solarSystems allValues] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"solarSystem.solarSystemName" ascending:YES]]];
			[self.outlineView expandAll];
			
			if (error)
				[[NSAlert alertWithError:error] runModal];
		}];
	}
}

@end
