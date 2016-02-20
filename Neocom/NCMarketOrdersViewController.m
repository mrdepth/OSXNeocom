//
//  NCMarketOrdersViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 19.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCMarketOrdersViewController.h"
#import "NCMarketContainerViewController.h"
#import "NCMarketViewController.h"
#import "NSNumberFormatter+Neocom.h"
#import "NSColor+Neocom.h"


@implementation NCMarketOrderNode

- (NSAttributedString*) location {
	if (self.station)
		return [[NSAttributedString alloc] initWithString:self.station.stationName attributes:nil];
	else if (self.solarSystem) {
		NSMutableAttributedString* s = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1f ", self.solarSystem.security] attributes:@{NSForegroundColorAttributeName:[NSColor colorWithSecurity:self.solarSystem.security]}];
		[s appendAttributedString:[[NSAttributedString alloc] initWithString:self.solarSystem.solarSystemName attributes:nil]];
		return s;
	}
	else
		return nil;
}

- (NSString*) price {
	if (self.order)
		return [NSString stringWithFormat:NSLocalizedString(@"%@ ISK", nil), [NSNumberFormatter neocomLocalizedStringFromNumber:@(self.order.price)]];
	else
		return nil;
}

@end

@interface NCMarketOrdersViewController ()
@property (assign) BOOL binded;
@end

@implementation NCMarketOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.region addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:nil];
	[self.type addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:nil];
}

- (void) dealloc {
	[self.region removeObserver:self forKeyPath:@"selection"];
	[self.type removeObserver:self forKeyPath:@"selection"];
}

- (void) viewWillAppear {
	[super viewWillAppear];
	if (!self.binded) {
		NCMarketContainerViewController* marketContainerViewController = (NCMarketContainerViewController*) [self.parentViewController parentViewController];
		NSSplitViewController* splitViewController = (NSSplitViewController*) [marketContainerViewController parentViewController];
		NCMarketViewController* marketViewController = (NCMarketViewController*) [splitViewController.splitViewItems[0] viewController];

		[self.region bind:NSContentBinding toObject:marketContainerViewController.region withKeyPath:@"content" options:nil];
		[self.type bind:NSContentBinding toObject:marketViewController withKeyPath:@"selectedType" options:nil];
		
		self.binded = YES;
		[self reload];
	}
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if (object == self.region || object == self.type)
		[self reload];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:nil];
}

- (void) reload {
}

@end
