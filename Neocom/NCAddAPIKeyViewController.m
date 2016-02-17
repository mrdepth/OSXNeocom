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

@interface NCTextField : NSTextField

@end

@implementation NCTextField

- (CGSize) intrinsicContentSize {
	if ([self stringValue].length == 0)
		return CGSizeZero;
	else
		return [super intrinsicContentSize];
}

@end

@interface NCAddAPIKeyViewController ()

@end

@implementation NCAddAPIKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)onAdd:(id)sender {
	[self.errorTextField setStringValue:@""];
	[self.progressIndicator startAnimation:sender];
	self.addButton.enabled = NO;

	NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[context setParentContext:[[NCStorage sharedStorage] managedObjectContext]];
	NCAPIKey* apiKey = [context apiKeyWithKeyID:[self.keyIDTextField intValue]];
	if (!apiKey) {
		apiKey = [[NCAPIKey alloc] initWithEntity:[NSEntityDescription entityForName:@"APIKey" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
	}
	
	apiKey.keyID = [self.keyIDTextField intValue];
	apiKey.vCode = [self.vCodeTextField stringValue];
	
	EVEOnlineAPI* api = [EVEOnlineAPI apiWithAPIKey:[EVEAPIKey apiKeyWithKeyID:apiKey.keyID vCode:apiKey.vCode] cachePolicy:NSURLRequestUseProtocolCachePolicy];
	
	[api apiKeyInfoWithCompletionBlock:^(EVEAPIKeyInfo *result, NSError *error) {
		if (result) {
			int32_t order = [[[context allAccounts] valueForKey:@"@max.order"] intValue];
			NSMutableArray* accounts = [NSMutableArray new];
			apiKey.apiKeyInfo = result;
			
			for (EVEAPIKeyInfoCharactersItem* character in result.key.characters) {
				BOOL skip = NO;
				for (NCAccount* account in apiKey.accounts)
					if (account.characterID == character.characterID) {
						break;
						skip = YES;
					}
				if (skip)
					continue;
				
				NCAccount* account = [[NCAccount alloc] initWithEntity:[NSEntityDescription entityForName:@"Account" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
				account.characterID = character.characterID;
				account.uuid = [[NSUUID UUID] UUIDString];
				account.apiKey = apiKey;
				account.order = ++order;
				[accounts addObject:account];
			}
			if ([context hasChanges]) {
				[context save:nil];
				NSManagedObjectContext* context = [[NCStorage sharedStorage] managedObjectContext];
				if ([context hasChanges])
					[context save:nil];
			}
			self.accounts = [accounts valueForKey:@"objectID"];
			[self dismissController:sender];
		}
		else if (error) {
			[self.errorTextField setStringValue:[error localizedDescription]];
			self.addButton.enabled = YES;
			[self.progressIndicator stopAnimation:sender];
		}
	} progressBlock:nil];
}

- (IBAction)onLink:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://community.eveonline.com/support/api-key/"]];
}

@end
