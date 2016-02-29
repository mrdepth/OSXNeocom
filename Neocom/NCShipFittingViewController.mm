//
//  NCShipFittingViewController.m
//  Neocom
//
//  Created by Артем Шиманский on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCShipFittingViewController.h"
#import "NCShipFit.h"
#import "NCDgmItemsTreeController.h"
#import "NCShipModulesController.h"
#import "NCShipDronesController.h"
#import "NCFittingEngine.h"
#import "NCDatabase.h"
#import "NCShipFitController.h"
#import "NCAccount.h"
#import "NCStorage.h"
#import <EVEAPI/EVEAPI.h>

@interface NCShipFittingCharacter : NSObject
@property (strong) NSString* title;
@property (assign) NSInteger level;
@property (strong) NCAccount* account;
@end

@implementation NCShipFittingCharacter
@end

@interface NCShipFittingViewController ()
@property (strong) NCFittingEngine* engine;
- (void) applicationWillTerminate:(NSNotification*) notification;
- (void) loadCharacter:(NCShipFittingCharacter*) character;
@end

@implementation NCShipFittingViewController

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.fit = nil;
	self.fitController.content = nil;
	self.dgmItems.content = nil;
	self.engine = nil;
	[self.characters removeObserver:self forKeyPath:@"selectedObjects"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.fit.loadoutName;
	self.engine = [NCFittingEngine new];
	[self.engine loadShipFit:self.fit];
	
	NCShipFittingCharacter* selected;
	for (int i = 0; i <= 5; i++) {
		NCShipFittingCharacter* character = [NCShipFittingCharacter new];
		character.title = [NSString stringWithFormat:NSLocalizedString(@"All %d", nil), i];
		character.level = i;
		[self.characters addObject:character];
		selected = character;
	}
	
	NCAccount* currentAccount = [NCAccount currentAccount];
	for (NCAccount* account in [[[NCStorage sharedStorage] managedObjectContext] allAccounts]) {
		if (account.characterSheet) {
			NCShipFittingCharacter* character = [NCShipFittingCharacter new];
			character.title = account.characterSheet.name;
			character.account = account;
			[self.characters addObject:character];
			if ([currentAccount.objectID isEqualTo:account.objectID])
				selected = character;
		}
	}
	self.characters.selectionIndex = [self.characters.arrangedObjects indexOfObject:selected];
	
	[self.characters addObserver:self forKeyPath:@"selectedObjects" options:0 context:nil];
	
	self.fitController.content = self.fit;
	self.dgmItems.fit = self.fit;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];

	[self loadCharacter:selected];
}

- (void) viewWillDisappear {
	[super viewWillDisappear];
	if (self.fit.loadoutID)
		[self.fit save];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if (object == self.characters && [keyPath isEqualToString:@"selectedObjects"]) {
		[self loadCharacter:[self.characters.selectedObjects lastObject]];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (IBAction) didSelectItem:(NSArray*) selectedObjects {
	NCDgmItemNode* node = [selectedObjects lastObject];
	if (node.item) {
		[self.fitController objectDidBeginEditing:self];
		if (node.item.type.group.category.categoryID == dgmpp::DRONE_CATEGORY_ID)
			self.fit.pilot->getShip()->addDrone(node.item.type.typeID);
		else
			self.fit.pilot->getShip()->addModule(node.item.type.typeID);
		[self.fitController objectDidEndEditing:self];
	}
}

- (void) keyDown:(NSEvent *)theEvent {
	unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	if (key == NSBackspaceCharacter || key == NSDeleteCharacter) {
		id view = [self.view.window firstResponder];
		if (view == self.modulesTableView)
			[self.modules remove:self];
		else if (view == self.dronesTableView)
			[self.drones remove:self];
	}
	[super keyDown:theEvent];
}

- (void) applicationWillTerminate:(NSNotification *)notification {
	[self.fit save];
}

- (void) loadCharacter:(NCShipFittingCharacter*) character {
	[self.fitController objectDidBeginEditing:self];
	NCFitCharacter* c;
	if (character.account)
		c = character.account.fitCharacter;
	else
		c = [[[NCStorage sharedStorage] managedObjectContext] fitCharacterWithSkillsLevel:character.level];
	[self.fit setCharacter:c];
	[self.fitController objectDidEndEditing:self];
}

@end
