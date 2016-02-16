//
//  NCAddAPIKeyViewController.m
//  Neocom
//
//  Created by Artem Shimanski on 17.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCAddAPIKeyViewController.h"
#import "NCStorage.h"
#import "NCAPIKey.h"
#import "NCAccount.h"
#import <EVEAPI/EVEAPI.h>

@interface NCAddAPIKeyViewController ()

@end

@implementation NCAddAPIKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)onAdd:(id)sender {
	[self.progressIndicator startAnimation:sender];
	self.addButton.enabled = NO;

	NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[context setParentContext:[[NCStorage sharedStorage] managedObjectContext]];
	NCAPIKey* apiKey = [context apiKeyWithKeyID:[self.keyIDTextField intValue]];
	if (!apiKey) {
		apiKey = [[NCAPIKey alloc] initWithEntity:[NSEntityDescription entityForName:@"APIKey" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
		apiKey.keyID = [self.keyIDTextField intValue];
		apiKey.vCode = [self.vCodeTextField stringValue];
		
		EVEOnlineAPI* api = [EVEOnlineAPI apiWithAPIKey:[EVEAPIKey apiKeyWithKeyID:apiKey.keyID vCode:apiKey.vCode] cachePolicy:NSURLRequestUseProtocolCachePolicy];
		[api accountStatusWithCompletionBlock:^(EVEAccountStatus *result, NSError *error) {
			NSLog(@"%@", result);
		} progressBlock:nil];
		
	}
}

- (IBAction)onCancel:(id)sender {
	[NSApp stopModal];
}

@end
