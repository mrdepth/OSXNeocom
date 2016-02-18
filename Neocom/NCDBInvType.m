//
//  NCDBInvType.m
//  Neocom
//
//  Created by Artem Shimanski on 16.02.16.
//  Copyright © 2016 Shimanski Artem. All rights reserved.
//

#import "NCDBInvType.h"
#import "NCDBCertCertificate.h"
#import "NCDBCertSkill.h"
#import "NCDBChrRace.h"
#import "NCDBDgmEffect.h"
#import "NCDBDgmTypeAttribute.h"
#import "NCDBDgmppHullType.h"
#import "NCDBDgmppItem.h"
#import "NCDBEveIcon.h"
#import "NCDBIndBlueprintType.h"
#import "NCDBIndProduct.h"
#import "NCDBIndRequiredMaterial.h"
#import "NCDBIndRequiredSkill.h"
#import "NCDBInvControlTower.h"
#import "NCDBInvControlTowerResource.h"
#import "NCDBInvGroup.h"
#import "NCDBInvMarketGroup.h"
#import "NCDBInvMetaGroup.h"
#import "NCDBInvTypeRequiredSkill.h"
#import "NCDBMapDenormalize.h"
#import "NCDBRamInstallationTypeContent.h"
#import "NCDBStaStation.h"
#import "NCDBTxtDescription.h"
#import "NCDBWhType.h"
#import "NCDBDgmAttributeType.h"

@implementation NCDBInvType
@synthesize attributesDictionary = _attributesDictionary;
@synthesize effectsDictionary = _effectsDictionary;

- (NSString*) metaGroupName {
	return self.metaGroup.metaGroupName;
}

- (NSDictionary*) attributesDictionary {
	if (!_attributesDictionary) {
		NSMutableDictionary* dic = [NSMutableDictionary new];
		for (NCDBDgmTypeAttribute* attribute in self.attributes)
			dic[@(attribute.attributeType.attributeID)] = attribute;
		_attributesDictionary = dic;
	}
	return _attributesDictionary;
}

- (NSDictionary*) effectsDictionary {
	if (!_effectsDictionary) {
		NSMutableDictionary* dic = [NSMutableDictionary new];
		for (NCDBDgmEffect* effect in self.effects)
			dic[@(effect.effectID)] = effect;
		_effectsDictionary = dic;
	}
	return _effectsDictionary;
}

@end
