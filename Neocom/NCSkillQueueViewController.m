//
//  NCSkillQueueViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 18.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCSkillQueueViewController.h"
#import "global.h"
#import "NCAccount.h"
#import "NCSkillData.h"
#import <EVEAPI/EVEAPI.h>
#import "NCCharacterAttributes.h"

@interface NCSkillQueueViewController ()
@property (nonatomic, strong) NCAccount* account;

- (void) didChangeAccount:(NSNotification*) note;
- (void) reload;
@end

@implementation NCSkillQueueViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.account = [NCAccount currentAccount];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAccount:) name:NCDidChangeAccountNotification object:nil];
}

- (void) dealloc {
	self.account = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if (object == self.account && ([keyPath isEqualToString:@"skillQueue"] || [keyPath isEqualToString:@"characterSheet"]))
		[self reload];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Private

- (void) didChangeAccount:(NSNotification*) note {
	self.account = note.object;
}

- (void) reload {
	[self.skillQueue removeObjects:[self.skillQueue arrangedObjects]];
	NCAccount* account = [NCAccount currentAccount];
	if (account.skillQueue && account.characterSheet) {
		NSManagedObjectContext* databaseManagedObjectContext = [[NCDatabase sharedDatabase] managedObjectContext];
		
		NCCharacterAttributes* characterAttributes = [[NCCharacterAttributes alloc] initWithCharacterSheet:account.characterSheet];
		for (EVESkillQueueItem *item in account.skillQueue.skillQueue) {
			NCDBInvType* type = [databaseManagedObjectContext invTypeWithTypeID:item.typeID];
			if (!type)
				continue;
			
			NCSkillData* skillData = [[NCSkillData alloc] initWithInvType:type];
			skillData.targetLevel = item.level;
			skillData.currentLevel = item.level - 1;
			skillData.characterSkill = account.characterSheet.skillsMap[@(item.typeID)];
			skillData.characterAttributes = characterAttributes;
			[self.skillQueue addObject:skillData];
		}
	}
}

- (void) setAccount:(NCAccount *)account {
	[_account removeObserver:self forKeyPath:@"skillQueue"];
	[_account removeObserver:self forKeyPath:@"characterSheet"];
	_account = account;
	[account addObserver:self forKeyPath:@"skillQueue" options:NSKeyValueObservingOptionNew context:nil];
	[account addObserver:self forKeyPath:@"characterSheet" options:NSKeyValueObservingOptionNew context:nil];
	[self reload];
}

@end
