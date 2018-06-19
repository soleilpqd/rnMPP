//
//  MPPProfile.h
//  rnMPP
//
//  Created by DươngPQ on 01/03/2018.
//  Copyright © 2018 GMO-Z.com RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MPPProfileType) {
    kUnknown, kMacDev, kMacStore, kMobileDev, kMobileAdhoc, kMobileEnterprise,  kMobileStore
};

@interface MPPProfile : NSObject

@property ( nonatomic, copy, readonly, nonnull ) NSString *path;
@property ( nonatomic, copy, readonly, nonnull ) NSString *name;
@property ( nonatomic, copy, readonly, nonnull ) NSString *appIdName;
@property ( nonatomic, copy, readonly, nonnull ) NSString *creationDate;
@property ( nonatomic, copy, readonly, nonnull ) NSString *expirationDate;
@property ( nonatomic, copy, readonly, nonnull ) NSString *teamName;
@property ( nonatomic, assign, readonly ) NSUInteger timeToLive;
@property ( nonatomic, copy, readonly, nonnull ) NSString *uuid;
@property ( nonatomic, assign, readonly ) NSUInteger version;
@property ( nonatomic, copy, readonly, nonnull ) NSArray<NSString*> *appIdPrefix;
@property ( nonatomic, copy, readonly, nonnull ) NSArray<NSString*> *teamIds;
@property ( nonatomic, copy, readonly, nonnull ) NSArray<NSString*> *developerCertificates;
@property ( nonatomic, copy, readonly, nonnull ) NSArray<NSString*> *platforms;
@property ( nonatomic, copy, readonly, nonnull ) NSArray<NSString*> *provisionedDevices;
@property ( nonatomic, copy, readonly, nonnull ) NSDictionary <NSString*, id> * entitlements;

@property ( nonatomic, copy, readonly, nullable ) NSString *bundleId;
@property ( nonatomic, copy, readonly, nullable ) NSString *apsEnvironment;

@property ( nonatomic, assign, readonly ) MPPProfileType type;
@property ( nonnull, readonly ) NSString *typeName;

-( nullable instancetype )initWithFile:( nonnull NSString* )path;

+( nullable NSDate* )convertDate:( nonnull NSString* )inputDate;

@end
