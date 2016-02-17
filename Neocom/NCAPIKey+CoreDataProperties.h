//
//  NCAPIKey+CoreDataProperties.h
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NCAPIKey.h"

NS_ASSUME_NONNULL_BEGIN

@class EVEAPIKeyInfo;
@interface NCAPIKey (CoreDataProperties)

@property (nullable, nonatomic, retain) EVEAPIKeyInfo* apiKeyInfo;
@property (nonatomic) int32_t keyID;
@property (nullable, nonatomic, retain) NSString *vCode;
@property (nullable, nonatomic, retain) NSSet<NCAccount *> *accounts;

@end

@interface NCAPIKey (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(NCAccount *)value;
- (void)removeAccountsObject:(NCAccount *)value;
- (void)addAccounts:(NSSet<NCAccount *> *)values;
- (void)removeAccounts:(NSSet<NCAccount *> *)values;

@end

NS_ASSUME_NONNULL_END
