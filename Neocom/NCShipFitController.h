//
//  NCShipFitController.h
//  Neocom
//
//  Created by Artem Shimanski on 22.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Dgmpp/Dgmpp.h>

@interface NCShipModule: NSObject

@property (readonly) NSImage* slotImage;
@property (readonly) NSImage* typeImage;
@property (readonly) NSString* title;
@property (readonly) NSImage* ammoImage;
@property (readonly) NSString* ammoName;
@property (assign) dgmpp::Module::Slot slot;
@property (assign) std::shared_ptr<dgmpp::Module> module;

@end

@interface NCShipFitController : NSObjectController
@property (readonly) NSArray* modules;
@end
