//
//  NCAccount.m
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCAccount.h"
#import "NCAPIKey.h"
#import "NCMailBox.h"
#import "NCSkillPlan.h"
#import "NCCache.h"
#import <EVEAPI/EVEAPI.h>
#import "NSString+Neocom.h"

@interface NCAccount()
@property (strong, nonatomic) NCCacheRecord* characterInfoCacheRecord;
@property (strong, nonatomic) NCCacheRecord* characterImageCacheRecord;
@property (strong, nonatomic) NCCacheRecord* skillQueueCacheRecord;
@property (strong, nonatomic) NCCacheRecord* characterSheetCacheRecord;
- (void) saveCache;

@end

@implementation NCAccount
@synthesize characterInfoCacheRecord = _characterInfoCacheRecord;
@synthesize characterImageCacheRecord = _characterImageCacheRecord;
@synthesize skillQueueCacheRecord = _skillQueueCacheRecord;
@synthesize characterSheetCacheRecord = _characterSheetCacheRecord;

- (void) awakeFromFetch {
	[self reload];
}

- (void) awakeFromInsert {
	[self reload];
}

- (BOOL) isCorporate {
	return self.apiKey.apiKeyInfo.key.type == EVEAPIKeyTypeCorporation;
}

- (void) reload {
	EVEOnlineAPI* api = [EVEOnlineAPI apiWithAPIKey:[EVEAPIKey apiKeyWithKeyID:self.apiKey.keyID vCode:self.apiKey.vCode characterID:self.characterID corporate:self.corporate] cachePolicy:NSURLRequestUseProtocolCachePolicy];

	if ([self.characterInfoCacheRecord isExpired]) {
		[api characterInfoWithCharacterID:self.characterID completionBlock:^(EVECharacterInfo *result, NSError *error) {
			if (result) {
				[self willChangeValueForKey:@"characterInfo"];
				self.characterInfoCacheRecord.data.data = result;
				self.characterInfoCacheRecord.date = [result.eveapi localTimeWithServerTime:result.eveapi.cacheDate];
				self.characterInfoCacheRecord.expireDate = [result.eveapi localTimeWithServerTime:result.eveapi.cachedUntil];
				[self didChangeValueForKey:@"characterInfo"];
				[self saveCache];
			}
		} progressBlock:nil];
	}
	if ([self.characterImageCacheRecord isExpired]) {
		NSURL* url = [EVEImage characterPortraitURLWithCharacterID:self.characterID size:EVEImageSizeRetina64 error:nil];
		AFHTTPRequestOperation* operation = [api.httpRequestOperationManager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
			if (responseObject) {
				NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:responseObject];
				if (imageRep) {
					NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
					[image addRepresentation:imageRep];
					[self willChangeValueForKey:@"characterImage"];
					self.characterImageCacheRecord.data.data = image;
					self.characterImageCacheRecord.date = [NSDate date];
					self.characterImageCacheRecord.expireDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
					[self didChangeValueForKey:@"characterImage"];
					[self saveCache];
				}
			}
		} failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
			
		}];
		operation.responseSerializer = [AFHTTPResponseSerializer serializer];
	}
	
	if (!self.corporate) {
		dispatch_group_t finishDispatchGroup = dispatch_group_create();
		__block EVESkillQueue* skillQueue;
		
		if ([self.skillQueueCacheRecord isExpired]) {
			dispatch_group_enter(finishDispatchGroup);
			[api skillQueueWithCompletionBlock:^(EVESkillQueue *result, NSError *error) {
				skillQueue = result;
				dispatch_group_leave(finishDispatchGroup);
			} progressBlock:nil];
		}
		
		__block EVECharacterSheet* characterSheet;
		if ([self.characterSheetCacheRecord isExpired]) {
			dispatch_group_enter(finishDispatchGroup);
			[api characterSheetWithCompletionBlock:^(EVECharacterSheet *result, NSError *error) {
				characterSheet = result;
				dispatch_group_leave(finishDispatchGroup);
			} progressBlock:nil];
		}
		
		dispatch_group_notify(finishDispatchGroup, dispatch_get_main_queue(), ^{
			if (skillQueue || characterSheet) {
				[self willChangeValueForKey:@"skillQueueInfo"];
				if (skillQueue) {
					self.skillQueueCacheRecord.data.data = skillQueue;
					self.skillQueueCacheRecord.date = [skillQueue.eveapi localTimeWithServerTime:skillQueue.eveapi.cacheDate];
					self.skillQueueCacheRecord.expireDate = [skillQueue.eveapi localTimeWithServerTime:skillQueue.eveapi.cachedUntil];
				}
				if (characterSheet) {
					if (skillQueue)
						[characterSheet attachSkillQueue:skillQueue];
					
					self.characterSheetCacheRecord.data.data = characterSheet;
					self.characterSheetCacheRecord.date = [characterSheet.eveapi localTimeWithServerTime:characterSheet.eveapi.cacheDate];
					self.characterSheetCacheRecord.expireDate = [characterSheet.eveapi localTimeWithServerTime:characterSheet.eveapi.cachedUntil];
				}
				[self didChangeValueForKey:@"skillQueueInfo"];
			}
		});
	}
}

- (NCCacheRecord*) characterInfoCacheRecord {
	if (!_characterInfoCacheRecord) {
		_characterInfoCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.characterInfo", self.uuid]];
	}
	return _characterInfoCacheRecord;
}

- (NCCacheRecord*) characterImageCacheRecord {
	if (!_characterImageCacheRecord) {
		_characterImageCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.characterImage", self.uuid]];
	}
	return _characterImageCacheRecord;
}

- (NCCacheRecord*) skillQueueCacheRecord {
	if (!_skillQueueCacheRecord) {
		_skillQueueCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.skillQueueCacheRecord", self.uuid]];
	}
	return _skillQueueCacheRecord;
}

- (NCCacheRecord*) characterSheetCacheRecord {
	if (!_characterSheetCacheRecord) {
		_characterSheetCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.characterSheetCacheRecord", self.uuid]];
	}
	return _characterSheetCacheRecord;
}

- (EVECharacterInfo*) characterInfo {
	EVECharacterInfo* characterInfo = self.characterInfoCacheRecord.data.data;
	return characterInfo;
}

- (NSImage*) characterImage {
	NSImage* characterImage = self.characterImageCacheRecord.data.data;
	return characterImage;
}

- (void) saveCache {
	NSManagedObjectContext* context = [[NCCache sharedCache] managedObjectContext];
	if ([context hasChanges])
		[context save:nil];
}

- (NSAttributedString*) skillQueueInfo {
	EVESkillQueue* skillQueue = self.skillQueueCacheRecord.data.data;
	if (skillQueue) {
		NSString *text;
		NSColor *color = nil;
		NSTimeInterval timeLeft = [skillQueue timeLeft];
		if (timeLeft > 0) {
			if (timeLeft > 3600 * 24)
				color = [NSColor blackColor];
			else
				color = [NSColor blackColor];
			text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%d skills in queue)", nil), [NSString stringWithTimeLeft:timeLeft], skillQueue.skillQueue.count];
		}
		else {
			text = NSLocalizedString(@"Training queue is inactive", nil);
			color = [NSColor redColor];
		}
		return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:color}];
	}
	else
		return nil;
}

@end
