//
//  NCSellOrdersViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 19.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCSellOrdersViewController.h"

@interface NCSellOrdersViewController ()

@end

@implementation NCSellOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void) reload {
	NCDBMapRegion* region = [self.region.selectedObjects lastObject];
	NCDBInvType* type = [self.type.selectedObjects lastObject];
	if (region && type) {
		[[CRAPI publicApiWithCachePolicy:NSURLRequestUseProtocolCachePolicy] loadSellOrdersWithTypeID:type.typeID regionID:region.regionID completionBlock:^(CRMarketOrderCollection *marketOrders, NSError *error) {
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
				[solarSystem.orders sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order.price" ascending:YES]]];
			self.marketOrders.content = [[solarSystems allValues] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"solarSystem.solarSystemName" ascending:YES]]];
			for (id item in [self.marketOrders.arrangedObjects childNodes])
				[self.outlineView expandItem:item expandChildren:YES];
		}];
	}
}

@end

