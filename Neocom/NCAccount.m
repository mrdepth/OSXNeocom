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
#import "NSNumberFormatter+Neocom.h"
#import "NCFitCharacter.h"

static NCAccount* currentAccount;

@interface NCAccount()
@property (strong, nonatomic) NCCacheRecord* characterInfoCacheRecord;

@property (strong, nonatomic) NCCacheRecord* characterSmallImageCacheRecord;
@property (strong, nonatomic) NCCacheRecord* characterLargeImageCacheRecord;
@property (strong, nonatomic) NCCacheRecord* corporationSmallImageCacheRecord;
@property (strong, nonatomic) NCCacheRecord* corporationLargeImageCacheRecord;
@property (strong, nonatomic) NCCacheRecord* allianceSmallImageCacheRecord;
@property (strong, nonatomic) NCCacheRecord* allianceLargeImageCacheRecord;
@property (strong, nonatomic) NCCacheRecord* accountBalanceCacheRecord;
@property (strong, nonatomic) NCCacheRecord* accountStatusCacheRecord;

@property (strong, nonatomic) NCCacheRecord* skillQueueCacheRecord;
@property (strong, nonatomic) NCCacheRecord* characterSheetCacheRecord;
@property (nonatomic, strong) NSMutableDictionary* locks;
@property (readonly) EVEOnlineAPI* eveOnlineAPI;
- (void) saveCache;

@end

@implementation NCAccount
@synthesize characterInfoCacheRecord = _characterInfoCacheRecord;

@synthesize characterSmallImageCacheRecord = _characterSmallImageCacheRecord;
@synthesize characterLargeImageCacheRecord = _characterLargeImageCacheRecord;
@synthesize corporationSmallImageCacheRecord = _corporationSmallImageCacheRecord;
@synthesize corporationLargeImageCacheRecord = _corporationLargeImageCacheRecord;
@synthesize allianceSmallImageCacheRecord = _allianceSmallImageCacheRecord;
@synthesize allianceLargeImageCacheRecord = _allianceLargeImageCacheRecord;

@synthesize accountBalanceCacheRecord = _accountBalanceCacheRecord;
@synthesize accountStatusCacheRecord = _accountStatusCacheRecord;
@synthesize skillQueueCacheRecord = _skillQueueCacheRecord;
@synthesize characterSheetCacheRecord = _characterSheetCacheRecord;
@synthesize locks = _locks;

+ (instancetype) currentAccount {
	return currentAccount;
}

+ (void) setCurrentAccount:(NCAccount*) account {
	currentAccount = account;
}

- (BOOL) isCorporate {
	return self.apiKey.apiKeyInfo.key.type == EVEAPIKeyTypeCorporation;
}

- (IBAction) reload {
	NSArray* keys = @[@"characterInfo",
					  @"characterSheet",
					  @"skillQueue",
					  @"accountBalance",
					  @"accountStatus",
					  
					  @"characterSmallImage",
					  @"characterLargeImage",
					  @"corporationSmallImage",
					  @"corporationLargeImage",
					  @"allianceSmallImage",
					  @"allianceLargeImage",
					  
					  @"skillQueueInfo",
					  @"skillsInfo",
					  @"accountBalanceInfo",
					  @"paidUntil"];
	for (NSString* key in keys)
		[self willChangeValueForKey:key];

	self.characterInfoCacheRecord.expireDate = [NSDate distantPast];
	self.characterSmallImageCacheRecord.expireDate = [NSDate distantPast];
	self.characterLargeImageCacheRecord.expireDate = [NSDate distantPast];
	self.corporationSmallImageCacheRecord.expireDate = [NSDate distantPast];
	self.corporationLargeImageCacheRecord.expireDate = [NSDate distantPast];
	self.allianceSmallImageCacheRecord.expireDate = [NSDate distantPast];
	self.allianceLargeImageCacheRecord.expireDate = [NSDate distantPast];
	self.accountBalanceCacheRecord.expireDate = [NSDate distantPast];
	self.accountStatusCacheRecord.expireDate = [NSDate distantPast];
	self.skillQueueCacheRecord.expireDate = [NSDate distantPast];
	self.characterSheetCacheRecord.expireDate = [NSDate distantPast];
	
	for (NSString* key in keys)
		[self didChangeValueForKey:key];
}

- (NCCacheRecord*) characterInfoCacheRecord {
	if (!_characterInfoCacheRecord)
		_characterInfoCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.characterInfo", self.uuid]];

	if (_characterInfoCacheRecord && ![self.locks[@"characterInfo"] boolValue] && ([_characterInfoCacheRecord isExpired] || !_characterInfoCacheRecord.data.data)) {
		self.locks[@"characterInfo"] = @(YES);
		[self.eveOnlineAPI characterInfoWithCharacterID:self.characterID completionBlock:^(EVECharacterInfo *result, NSError *error) {
			if (result) {
				[self willChangeValueForKey:@"characterInfo"];
				[self willChangeValueForKey:@"skillsInfo"];
				
				[self willChangeValueForKey:@"corporationSmallImage"];
				[self willChangeValueForKey:@"corporationLargeImage"];
				[self willChangeValueForKey:@"allianceSmallImage"];
				[self willChangeValueForKey:@"allianceLargeImage"];
				
				self.characterInfoCacheRecord.data.data = result;
				self.characterInfoCacheRecord.date = [result.eveapi localTimeWithServerTime:result.eveapi.cacheDate];
				self.characterInfoCacheRecord.expireDate = [result.eveapi localTimeWithServerTime:result.eveapi.cachedUntil];
				self.corporationSmallImageCacheRecord = nil;
				self.corporationLargeImageCacheRecord = nil;
				self.allianceSmallImageCacheRecord = nil;
				self.allianceLargeImageCacheRecord = nil;
				
				[self didChangeValueForKey:@"allianceLargeImage"];
				[self didChangeValueForKey:@"allianceSmallImage"];
				[self didChangeValueForKey:@"corporationLargeImage"];
				[self didChangeValueForKey:@"corporationSmallImage"];

				[self didChangeValueForKey:@"skillsInfo"];
				[self didChangeValueForKey:@"characterInfo"];
				[self saveCache];
			}
			self.locks[@"characterInfo"] = @(NO);
		} progressBlock:nil];
	}
	
	return _characterInfoCacheRecord;
}

- (NCCacheRecord*) characterSmallImageCacheRecord {
	if (!_characterSmallImageCacheRecord)
		_characterSmallImageCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.characterSmallImage", self.uuid]];
	
	if (_characterSmallImageCacheRecord && ![self.locks[@"characterSmallImage"] boolValue] && ([_characterSmallImageCacheRecord isExpired] || !_characterSmallImageCacheRecord.data.data)) {
		self.locks[@"characterSmallImage"] = @(YES);
		NSURL* url = [EVEImage characterPortraitURLWithCharacterID:self.characterID size:EVEImageSizeRetina64 error:nil];
		AFHTTPRequestOperation* operation = [self.eveOnlineAPI.httpRequestOperationManager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
			if (responseObject) {
				NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:responseObject];
				if (imageRep) {
					NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
					[image addRepresentation:imageRep];
					[self willChangeValueForKey:@"characterSmallImage"];
					_characterSmallImageCacheRecord.data.data = image;
					_characterSmallImageCacheRecord.date = [NSDate date];
					_characterSmallImageCacheRecord.expireDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
					[self didChangeValueForKey:@"characterSmallImage"];
					[self saveCache];
				}
			}
			self.locks[@"characterSmallImage"] = @(NO);
		} failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
			self.locks[@"characterSmallImage"] = @(NO);
		}];
		operation.responseSerializer = [AFHTTPResponseSerializer serializer];
	}
	
	return _characterSmallImageCacheRecord;
}

- (NCCacheRecord*) characterLargeImageCacheRecord {
	if (!_characterLargeImageCacheRecord)
		_characterLargeImageCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.characterLargeImage", self.uuid]];

	if (_characterLargeImageCacheRecord && ![self.locks[@"characterLargeImage"] boolValue] && ([_characterLargeImageCacheRecord isExpired] || !_characterLargeImageCacheRecord.data.data)) {
		self.locks[@"characterLargeImage"] = @(YES);
		NSURL* url = [EVEImage characterPortraitURLWithCharacterID:self.characterID size:EVEImageSizeRetina256 error:nil];
		AFHTTPRequestOperation* operation = [self.eveOnlineAPI.httpRequestOperationManager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
			if (responseObject) {
				NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:responseObject];
				if (imageRep) {
					NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
					[image addRepresentation:imageRep];
					[self willChangeValueForKey:@"characterLargeImage"];
					_characterLargeImageCacheRecord.data.data = image;
					_characterLargeImageCacheRecord.date = [NSDate date];
					_characterLargeImageCacheRecord.expireDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
					[self didChangeValueForKey:@"characterLargeImage"];
					[self saveCache];
				}
			}
			self.locks[@"characterSmallImage"] = @(NO);
		} failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
			self.locks[@"characterSmallImage"] = @(NO);
		}];
		operation.responseSerializer = [AFHTTPResponseSerializer serializer];
	}
	
	return _characterLargeImageCacheRecord;
}

- (NCCacheRecord*) corporationSmallImageCacheRecord {
	if (!_corporationSmallImageCacheRecord && self.characterInfo.corporationID)
		_corporationSmallImageCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.%d.corporationSmallImage", self.uuid, self.characterInfo.corporationID]];
	
	if (_corporationSmallImageCacheRecord && ![self.locks[@"corporationSmallImage"] boolValue] && ([_corporationSmallImageCacheRecord isExpired] || !_corporationSmallImageCacheRecord.data.data)) {
		self.locks[@"corporationSmallImage"] = @(YES);
		NSURL* url = [EVEImage corporationLogoURLWithCorporationID:self.characterInfo.corporationID size:EVEImageSizeRetina32 error:nil];
		AFHTTPRequestOperation* operation = [self.eveOnlineAPI.httpRequestOperationManager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
			if (responseObject) {
				NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:responseObject];
				if (imageRep) {
					NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
					[image addRepresentation:imageRep];
					[self willChangeValueForKey:@"corporationSmallImage"];
					_corporationSmallImageCacheRecord.data.data = image;
					_corporationSmallImageCacheRecord.date = [NSDate date];
					_corporationSmallImageCacheRecord.expireDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
					[self didChangeValueForKey:@"corporationSmallImage"];
					[self saveCache];
				}
			}
			self.locks[@"corporationSmallImage"] = @(NO);
		} failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
			self.locks[@"corporationSmallImage"] = @(NO);
		}];
		operation.responseSerializer = [AFHTTPResponseSerializer serializer];
	}

	return _corporationSmallImageCacheRecord;
}

- (NCCacheRecord*) corporationLargeImageCacheRecord {
	if (!_corporationLargeImageCacheRecord && self.characterInfo.corporationID)
		_corporationLargeImageCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.%d.corporationLargeImage", self.uuid, self.characterInfo.corporationID]];

	if (_corporationLargeImageCacheRecord && ![self.locks[@"corporationLargeImage"] boolValue] && ([_corporationLargeImageCacheRecord isExpired] || !_corporationLargeImageCacheRecord.data.data)) {
		self.locks[@"corporationLargeImage"] = @(YES);
		NSURL* url = [EVEImage corporationLogoURLWithCorporationID:self.characterInfo.corporationID size:EVEImageSizeRetina64 error:nil];
		AFHTTPRequestOperation* operation = [self.eveOnlineAPI.httpRequestOperationManager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
			if (responseObject) {
				NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:responseObject];
				if (imageRep) {
					NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
					[image addRepresentation:imageRep];
					[self willChangeValueForKey:@"corporationLargeImage"];
					_corporationLargeImageCacheRecord.data.data = image;
					_corporationLargeImageCacheRecord.date = [NSDate date];
					_corporationLargeImageCacheRecord.expireDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
					[self didChangeValueForKey:@"corporationLargeImage"];
					[self saveCache];
				}
			}
			self.locks[@"corporationLargeImage"] = @(NO);
		} failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
			self.locks[@"corporationLargeImage"] = @(NO);
		}];
		operation.responseSerializer = [AFHTTPResponseSerializer serializer];
	}
	
	return _corporationLargeImageCacheRecord;
}

- (NCCacheRecord*) allianceSmallImageCacheRecord {
	if (!_allianceSmallImageCacheRecord && self.characterInfo.allianceID)
		_allianceSmallImageCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.%d.allianceSmallImage", self.uuid, self.characterInfo.allianceID]];

	if (_allianceSmallImageCacheRecord && ![self.locks[@"allianceSmallImage"] boolValue] && ([_allianceSmallImageCacheRecord isExpired] || !_allianceSmallImageCacheRecord.data.data)) {
		self.locks[@"allianceSmallImage"] = @(YES);
		NSURL* url = [EVEImage allianceLogoURLWithAllianceID:self.characterInfo.allianceID size:EVEImageSizeRetina32 error:nil];
		AFHTTPRequestOperation* operation = [self.eveOnlineAPI.httpRequestOperationManager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
			if (responseObject) {
				NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:responseObject];
				if (imageRep) {
					NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
					[image addRepresentation:imageRep];
					[self willChangeValueForKey:@"allianceSmallImage"];
					_allianceSmallImageCacheRecord.data.data = image;
					_allianceSmallImageCacheRecord.date = [NSDate date];
					_allianceSmallImageCacheRecord.expireDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
					[self didChangeValueForKey:@"allianceSmallImage"];
					[self saveCache];
				}
			}
			self.locks[@"allianceSmallImage"] = @(NO);
		} failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
			self.locks[@"allianceSmallImage"] = @(NO);
		}];
		operation.responseSerializer = [AFHTTPResponseSerializer serializer];
	}
	
	return _allianceSmallImageCacheRecord;
}

- (NCCacheRecord*) allianceLargeImageCacheRecord {
	if (!_allianceLargeImageCacheRecord && self.characterInfo.allianceID)
		_allianceLargeImageCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.%d.allianceLargeImage", self.uuid, self.characterInfo.allianceID]];

	if (_allianceLargeImageCacheRecord && ![self.locks[@"allianceLargeImage"] boolValue] && ([_allianceLargeImageCacheRecord isExpired] || !_allianceLargeImageCacheRecord.data.data)) {
		self.locks[@"allianceLargeImage"] = @(YES);
		NSURL* url = [EVEImage allianceLogoURLWithAllianceID:self.characterInfo.allianceID size:EVEImageSizeRetina64 error:nil];
		AFHTTPRequestOperation* operation = [self.eveOnlineAPI.httpRequestOperationManager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
			if (responseObject) {
				NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:responseObject];
				if (imageRep) {
					NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
					[image addRepresentation:imageRep];
					[self willChangeValueForKey:@"allianceLargeImage"];
					_allianceLargeImageCacheRecord.data.data = image;
					_allianceLargeImageCacheRecord.date = [NSDate date];
					_allianceLargeImageCacheRecord.expireDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
					[self didChangeValueForKey:@"allianceLargeImage"];
					[self saveCache];
				}
			}
			self.locks[@"allianceLargeImage"] = @(NO);
		} failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
			self.locks[@"allianceLargeImage"] = @(NO);
		}];
		operation.responseSerializer = [AFHTTPResponseSerializer serializer];
	}
	
	return _allianceLargeImageCacheRecord;
}

- (NCCacheRecord*) skillQueueCacheRecord {
	if (!_skillQueueCacheRecord && !self.corporate)
		_skillQueueCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.skillQueue", self.uuid]];

	if (_skillQueueCacheRecord && ![self.locks[@"skillQueue"] boolValue] && ([_skillQueueCacheRecord isExpired] || !_skillQueueCacheRecord.data.data)) {
		self.locks[@"skillQueue"] = @(YES);
		[self.eveOnlineAPI skillQueueWithCompletionBlock:^(EVESkillQueue *result, NSError *error) {
			if (result) {
				[self willChangeValueForKey:@"skillQueue"];
				[self willChangeValueForKey:@"skillsInfo"];
				[self willChangeValueForKey:@"skillQueueInfo"];
				_skillQueueCacheRecord.data.data = result;
				_skillQueueCacheRecord.date = [result.eveapi localTimeWithServerTime:result.eveapi.cacheDate];
				_skillQueueCacheRecord.expireDate = [result.eveapi localTimeWithServerTime:result.eveapi.cachedUntil];
				self.characterSheetCacheRecord = nil;
				[self didChangeValueForKey:@"skillQueueInfo"];
				[self didChangeValueForKey:@"skillsInfo"];
				[self didChangeValueForKey:@"skillQueue"];
				[self saveCache];
			}
			self.locks[@"skillQueue"] = @(NO);
		} progressBlock:nil];
	}
	
	return _skillQueueCacheRecord;
}

- (NCCacheRecord*) characterSheetCacheRecord {
	if (!_characterSheetCacheRecord) {
		_characterSheetCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.characterSheet", self.uuid]];
		EVECharacterSheet* characterSheet = _characterSheetCacheRecord.data.data;
		if (characterSheet && self.skillQueue)
			[characterSheet attachSkillQueue:self.skillQueue];
	}
	
	if (_characterSheetCacheRecord && ![self.locks[@"characterSheet"] boolValue] && ([_characterSheetCacheRecord isExpired] || !_characterSheetCacheRecord.data.data)) {
		self.locks[@"characterSheet"] = @(YES);
		[self.eveOnlineAPI characterSheetWithCompletionBlock:^(EVECharacterSheet *result, NSError *error) {
			if (result) {
				[self willChangeValueForKey:@"characterSheet"];
				[self willChangeValueForKey:@"skillsInfo"];
				[self willChangeValueForKey:@"skillQueueInfo"];
				if (self.skillQueue)
					[result attachSkillQueue:self.skillQueue];
				
				_characterSheetCacheRecord.data.data = result;
				_characterSheetCacheRecord.date = [result.eveapi localTimeWithServerTime:result.eveapi.cacheDate];
				_characterSheetCacheRecord.expireDate = [result.eveapi localTimeWithServerTime:result.eveapi.cachedUntil];
				self.characterSheetCacheRecord = nil;
				[self didChangeValueForKey:@"skillQueueInfo"];
				[self didChangeValueForKey:@"skillsInfo"];
				[self didChangeValueForKey:@"characterSheet"];
				[self saveCache];
			}
			self.locks[@"characterSheet"] = @(NO);
		} progressBlock:nil];
	}
	
	return _characterSheetCacheRecord;
}

- (NCCacheRecord*) accountBalanceCacheRecord {
	if (!_accountBalanceCacheRecord)
		_accountBalanceCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.accountBalance", self.uuid]];
	
	if (_accountBalanceCacheRecord && ![self.locks[@"accountBalance"] boolValue] && ([_accountBalanceCacheRecord isExpired] || !_accountBalanceCacheRecord.data.data)) {
		self.locks[@"accountBalance"] = @(YES);
		[self.eveOnlineAPI accountBalanceWithCompletionBlock:^(EVEAccountBalance *result, NSError *error) {
			if (result) {
				[self willChangeValueForKey:@"accountBalance"];
				[self willChangeValueForKey:@"accountBalanceInfo"];
				_accountBalanceCacheRecord.data.data = result;
				_accountBalanceCacheRecord.date = [result.eveapi localTimeWithServerTime:result.eveapi.cacheDate];
				_accountBalanceCacheRecord.expireDate = [result.eveapi localTimeWithServerTime:result.eveapi.cachedUntil];
				[self didChangeValueForKey:@"accountBalanceInfo"];
				[self didChangeValueForKey:@"accountBalance"];
				[self saveCache];
			}
			self.locks[@"accountBalance"] = @(NO);
		} progressBlock:nil];
	}
	
	return _accountBalanceCacheRecord;
}

- (NCCacheRecord*) accountStatusCacheRecord {
	if (!_accountStatusCacheRecord)
		_accountStatusCacheRecord = [[[NCCache sharedCache] managedObjectContext] cacheRecordWithRecordID:[NSString stringWithFormat:@"%@.accountStatus", self.uuid]];
	
	if (_accountBalanceCacheRecord && ![self.locks[@"accountStatus"] boolValue] && ([_accountStatusCacheRecord isExpired] || !_accountStatusCacheRecord.data.data)) {
		self.locks[@"accountStatus"] = @(YES);
		[self.eveOnlineAPI accountStatusWithCompletionBlock:^(EVEAccountStatus *result, NSError *error) {
			if (result) {
				[self willChangeValueForKey:@"accountStatus"];
				[self willChangeValueForKey:@"paidUntil"];
				_accountStatusCacheRecord.data.data = result;
				_accountStatusCacheRecord.date = [result.eveapi localTimeWithServerTime:result.eveapi.cacheDate];
				_accountStatusCacheRecord.expireDate = [result.eveapi localTimeWithServerTime:result.eveapi.cachedUntil];
				[self didChangeValueForKey:@"paidUntil"];
				[self didChangeValueForKey:@"accountStatus"];
				[self saveCache];
			}
			self.locks[@"accountStatus"] = @(NO);
		} progressBlock:nil];
	}
	
	return _accountStatusCacheRecord;
}

- (EVECharacterInfo*) characterInfo {
	EVECharacterInfo* characterInfo = self.characterInfoCacheRecord.data.data;
	return characterInfo;
}

- (EVECharacterSheet*) characterSheet {
	EVECharacterSheet* characterSheet = self.characterSheetCacheRecord.data.data;
	return characterSheet;
}

- (EVESkillQueue*) skillQueue {
	EVESkillQueue* skillQueue = self.skillQueueCacheRecord.data.data;
	return skillQueue;
}

- (NSImage*) characterSmallImage {
	NSImage* characterSmallImage = self.characterSmallImageCacheRecord.data.data;
	return characterSmallImage;
}

- (NSImage*) characterLargeImage {
	NSImage* characterLargeImage = self.characterLargeImageCacheRecord.data.data;
	return characterLargeImage;
}

- (NSImage*) corporationSmallImage {
	NSImage* corporationSmallImage = self.corporationSmallImageCacheRecord.data.data;
	return corporationSmallImage;
}

- (NSImage*) corporationLargeImage {
	NSImage* corporationLargeImage = self.corporationLargeImageCacheRecord.data.data;
	return corporationLargeImage;
}

- (NSImage*) allianceSmallImage {
	NSImage* allianceSmallImage = self.allianceSmallImageCacheRecord.data.data;
	return allianceSmallImage;
}

- (NSImage*) allianceLargeImage {
	NSImage* allianceLargeImage = self.allianceLargeImageCacheRecord.data.data;
	return allianceLargeImage;
}

- (EVEAccountBalance*) accountBalance {
	EVEAccountBalance* accountBalance = self.accountBalanceCacheRecord.data.data;
	return accountBalance;
}

- (EVEAccountStatus*) accountStatus {
	EVEAccountStatus* accountStatus = self.accountStatusCacheRecord.data.data;
	return accountStatus;
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

- (NSString*) skillsInfo {
	return self.characterInfo && self.characterSheet ? [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ skills)", nil),
							 [NSString shortStringWithFloat:self.characterInfo.skillPoints unit:@"SP"],
														[NSNumberFormatter neocomLocalizedStringFromNumber:@(self.characterSheet.skills.count)]] : nil;

}

- (NSString*) accountBalanceInfo {
	EVEAccountBalance* balance = self.accountBalance;
	if (balance) {
		double sum = 0;
		for (EVEAccountBalanceItem* item in balance.accounts)
			sum += item.balance;
		return [NSString shortStringWithFloat:sum unit:NSLocalizedString(@"ISK", nil)];
	}
	else
		return nil;
}

- (NSAttributedString*) paidUntil {
	EVEAccountStatus* accountStatus = self.accountStatus;
	if (accountStatus) {
		NSColor *color;
		int days = [accountStatus.paidUntil timeIntervalSinceNow] / (60 * 60 * 24);
		if (days < 0)
			days = 0;
		if (days > 7)
			color = [NSColor blackColor];
		else if (days == 0)
			color = [NSColor redColor];
		else
			color = [NSColor blackColor];
		return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"%@ (%d days remaining)", nil), [[NSDateFormatter eveDateFormatter] stringFromDate:self.accountStatus.paidUntil], (int32_t) days]
											   attributes:@{NSForegroundColorAttributeName:color}];
	}
	else
		return nil;
}

- (NCFitCharacter*) fitCharacter {
	EVECharacterSheet* characterSheet = self.characterSheet;
	if (characterSheet) {
		NCFitCharacter* character = [[NCFitCharacter alloc] initWithEntity:[NSEntityDescription entityForName:@"FitCharacter" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
		
		character.name = characterSheet.name;
		
		NSMutableDictionary* skills = [NSMutableDictionary new];
		for (EVECharacterSheetSkill* skill in characterSheet.skills)
			skills[@(skill.typeID)] = @(skill.level);
		character.skills = skills;
		return character;
	}
	else
		return nil;
}

#pragma mark - Private

- (void) saveCache {
	NSManagedObjectContext* context = [[NCCache sharedCache] managedObjectContext];
	if ([context hasChanges])
		[context save:nil];
}

- (NSMutableDictionary*) locks {
	if (!_locks)
		_locks = [NSMutableDictionary new];
	return _locks;
}

- (EVEOnlineAPI*) eveOnlineAPI {
	return [[EVEOnlineAPI alloc] initWithAPIKey:[EVEAPIKey apiKeyWithKeyID:self.apiKey.keyID vCode:self.apiKey.vCode characterID:self.characterID corporate:self.corporate] cachePolicy:NSURLRequestUseProtocolCachePolicy];
}

@end
