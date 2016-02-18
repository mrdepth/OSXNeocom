//
//  NCMarketViewController.m
//  Neocom
//
//  Created by Artem Shimanski on 18.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCMarketViewController.h"
#import "NCDatabase.h"

@interface NCDBInvMarketGroup(Neocom)
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) NSSet* items;
@property (nonatomic, readonly) NSImage* image;
@end

@implementation NCDBInvMarketGroup(Neocom)

- (NSString*) title {
	return self.marketGroupName;
}

- (NSSet*) items {
	return self.subGroups.count > 0 ? (NSSet*) self.subGroups : (NSSet*) self.types;
}

- (NSImage*) image {
	return self.icon.image.image ?: [self.managedObjectContext defaultGroupIcon].image.image;
}

@end

@interface NCDBInvType(Neocom)
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) NSSet* items;
@property (nonatomic, readonly) NSImage* image;
@end

@implementation NCDBInvType(Neocom)

- (NSString*) title {
	return self.typeName;
}

- (NSSet*) items {
	return nil;
}

- (NSImage*) image {
	return self.icon.image.image ?: [self.managedObjectContext defaultTypeIcon].image.image;
}


@end

@interface NCMarketViewController ()

@end

@implementation NCMarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	NSManagedObjectContext* context = [[NCDatabase sharedDatabase] managedObjectContext];
	self.marketTree.managedObjectContext = context;
	self.marketTree.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
}

@end
