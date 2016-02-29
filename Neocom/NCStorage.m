//
//  NCStorage.m
//  Neocom
//
//  Created by Artem Shimanski on 25.01.13.
//
//

#import "NCStorage.h"
#import "NCAccount.h"
#import "NCLoadout.h"
#import "NCSkillPlan.h"
#import "NCDamagePattern.h"
#import "NCImplantSet.h"
#import "NCFitCharacter.h"
#import <objc/runtime.h>


@interface NCValueTransformer : NSValueTransformer

@end

@implementation NCValueTransformer

+ (void) load {
	[NSValueTransformer setValueTransformer:[self new] forName:@"NCValueTransformer"];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}


+ (Class)transformedValueClass {
    return [NSData class];
}


- (id)transformedValue:(id)value {
	@try {
		if (![value respondsToSelector:@selector(encodeWithCoder:)])
			return nil;
		else
			return [NSKeyedArchiver archivedDataWithRootObject:value];
	}
	@catch (NSException *exception) {
		return nil;
	}
}


- (id)reverseTransformedValue:(id)value {
	@try {
		return [NSKeyedUnarchiver unarchiveObjectWithData:value];
	}
	@catch (NSException *exception) {
		return nil;
	}
}

@end

static NCStorage* sharedStorage;

@interface NCStorage()
@end

@implementation NCStorage

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;

+ (instancetype) sharedStorage {
	@synchronized(self) {
		static NCStorage* sharedStorage = nil;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			sharedStorage = [NCStorage new];
		});
		return sharedStorage;
	}
}



#pragma mark - Core Data stack

- (NSManagedObjectContext*) managedObjectContext {
	if (!_managedObjectContext) {
		_managedObjectContext = [self createManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
	}
	return _managedObjectContext;
}

- (NSManagedObjectContext*) createManagedObjectContext {
	return [self createManagedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (NSManagedObjectContext*) createManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType) concurrencyType {
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		NSManagedObjectContext* managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
		[managedObjectContext setPersistentStoreCoordinator:coordinator];
		[managedObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSRollbackMergePolicyType]];
		return managedObjectContext;
	}
	else
		return nil;
}

- (NSManagedObjectModel*) managedObjectModel {
	@synchronized(self) {
		if (_managedObjectModel != nil) {
			return _managedObjectModel;
		}
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NCStorage" withExtension:@"momd"];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
		return _managedObjectModel;
	}
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	@synchronized(self) {
		NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];

		NSURL* directory = [appSupportURL URLByAppendingPathComponent:@"Neocom"];
		[[NSFileManager defaultManager] createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:nil];
		
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
		
		NSError *error = nil;
		NSURL *storeURL = [directory URLByAppendingPathComponent:@"fallbackStore.sqlite"];
		for (int n = 0; n < 2; n++) {
			error = nil;
			if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
														  configuration:@"Cloud"
																	URL:storeURL
																options:@{NSInferMappingModelAutomaticallyOption : @(NO),
																		  NSMigratePersistentStoresAutomaticallyOption : @(NO)}
																  error:&error])
				break;
			else
				[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
		}
		if (error) {
			return nil;
		}
		storeURL = [directory URLByAppendingPathComponent:@"localStore.sqlite"];
		
		for (int n = 0; n < 2; n++) {
			error = nil;
			if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
														  configuration:@"Local"
																	URL:storeURL
																options:@{NSInferMappingModelAutomaticallyOption : @(YES),
																		  NSMigratePersistentStoresAutomaticallyOption : @(YES)}
																  error:&error])
				break;
			else
				[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
		}
		if (error) {
			return nil;
		}
		return _persistentStoreCoordinator;
	}
}

#pragma mark - Private


@end
