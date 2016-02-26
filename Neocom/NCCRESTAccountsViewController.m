//
//  NCCRESTAccountsViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 26.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCCRESTAccountsViewController.h"
#import "NCStorage.h"
#import <EVEAPI/EVEAPI.h>
#import "NCSetting.h"
#import "NCCache.h"
#import <objc/runtime.h>

@interface CRToken(Neocom)
@property (strong) NSImage* image;
@end

@implementation CRToken(Neocom)

- (NSImage*) image {
	NSImage* image = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"sso.image.%d", self.characterID]].data.data;
	if (!image) {
		if ([objc_getAssociatedObject(self, @"loading") boolValue])
			return nil;
		objc_setAssociatedObject(self, @"loading", @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
		
		EVEOnlineAPI* api = [EVEOnlineAPI apiWithAPIKey:nil cachePolicy:NSURLRequestUseProtocolCachePolicy];
		
		NSURL* url = [EVEImage characterPortraitURLWithCharacterID:self.characterID size:EVEImageSizeRetina64 error:nil];
		AFHTTPRequestOperation* operation = [api.httpRequestOperationManager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
			if (responseObject) {
				NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:responseObject];
				if (imageRep) {
					NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
					[image addRepresentation:imageRep];
					self.image = image;
				}
			}
			objc_setAssociatedObject(self, @"loading", @(NO), OBJC_ASSOCIATION_COPY_NONATOMIC);
		} failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
			objc_setAssociatedObject(self, @"loading", @(NO), OBJC_ASSOCIATION_COPY_NONATOMIC);
		}];
		operation.responseSerializer = [AFHTTPResponseSerializer serializer];
	}
	return image;
}

- (void) setImage:(NSImage *)image {
	[self willChangeValueForKey:@"image"];
	NCCacheRecord* record = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"sso.image.%d", self.characterID]];
	record.data.data = image;
	record.date = [NSDate date];
	record.expireDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
	if ([record.managedObjectContext hasChanges])
		[record.managedObjectContext save:nil];
	
	[self didChangeValueForKey:@"image"];
}

@end

@interface NCCRESTAccountsViewController ()
@property (strong) CRAPI* api;
@end

@implementation NCCRESTAccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.accounts.managedObjectContext = [[NCStorage sharedStorage] managedObjectContext];
	self.accounts.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"value.characterName" ascending:YES]];
}

- (IBAction)onAddAccount:(id)sender {
	self.api = [CRAPI apiWithCachePolicy:NSURLRequestUseProtocolCachePolicy clientID:@"c2cc974798d4485d966fba773a8f7ef8" secretKey:@"GNhSE9GJ6q3QiuPSTIJ8Q1J6on4ClM4v9zvc0Qzu" token:nil callbackURL:[NSURL URLWithString:@"neocom://sso"]];
	NSManagedObjectContext* context = [[NCStorage sharedStorage] managedObjectContext];
	
	[self.api authenticateWithCompletionBlock:^(CRToken *token, NSError *error) {
		if (token) {
			[context settingWithKey:[NSString stringWithFormat:@"sso.%d", token.characterID]].value = token;
			[context save:nil];
		}
		else if (error)
			[[NSAlert alertWithError:error] runModal];
	}];
}

- (IBAction)onRemove:(id)sender {
	NCSetting* setting = [self.accounts.selectedObjects lastObject];
	NSManagedObjectContext* context = setting.managedObjectContext;
	[context deleteObject:setting];
	if ([context hasChanges])
		[context save:nil];
}

- (IBAction)onSelect:(id)sender {
}

@end
