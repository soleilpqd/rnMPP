//
//  MPPProfile.m
//  rnMPP
//
//  Created by DươngPQ on 01/03/2018.
//  Copyright © 2018 GMO-Z.com RunSystem. All rights reserved.
//

#import "MPPProfile.h"
#import <Security/Security.h>

@implementation NSDictionary (mpp)

-( nonnull NSString* )stringForKey:( nonnull NSString* )key {
    id obj = [ self objectForKey:key ];
    if ( obj != nil ) {
        if ([ obj isKindOfClass:[ NSString class ]]) {
            return obj;
        } else {
            return [ NSString stringWithFormat:@"%@", obj ];
        }
    }
    return  @"";
}

-( nonnull NSArray* )arrayForKey:( nonnull NSString* )key {
    id obj = [ self objectForKey:key ];
    if ( obj != nil ) {
        if ([ obj isKindOfClass:[ NSArray class ]]) {
            return obj;
        } else {
            return @[obj];
        }
    }
    return @[];
}

-( NSUInteger )uintForKey:( nonnull NSString* )key {
    id obj = [ self objectForKey:key ];
    if( obj != nil && [ obj isKindOfClass:[ NSNumber class ]]) {
        return [( NSNumber* )obj unsignedIntegerValue ];
    }
    return 0;
}

@end

@implementation MPPProfile

-( instancetype )initWithFile:( NSString* )path {
    if ( self = [ super init ]) {
        NSData *provisionData = [ NSData dataWithContentsOfFile:path ];
        if ( provisionData == nil ) return nil;

        CMSDecoderRef decoder = NULL;
        CMSDecoderCreate(&decoder);
        CMSDecoderUpdateMessage(decoder, provisionData.bytes, provisionData.length);
        CMSDecoderFinalizeMessage(decoder);
        CFDataRef dataRef = NULL;
        CMSDecoderCopyContent(decoder, &dataRef);
        NSData *data = (NSData *)CFBridgingRelease(dataRef);
        CFRelease(decoder);

        if ( data == nil ) return nil;
        _path = [ path copy ];
        NSDictionary *propertyList = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
        _name = [ propertyList stringForKey:@"Name" ];
        _appIdName = [ propertyList stringForKey:@"AppIDName" ];
        _appIdPrefix = [ propertyList arrayForKey:@"ApplicationIdentifierPrefix" ];
        _creationDate = [ propertyList stringForKey:@"CreationDate" ];
        _expirationDate = [ propertyList stringForKey:@"ExpirationDate" ];
        _teamName = [ propertyList stringForKey:@"TeamName" ];
        _timeToLive = [ propertyList uintForKey:@"TimeToLive" ];
        _version = [ propertyList uintForKey:@"Version" ];
        _uuid = [ propertyList stringForKey:@"UUID" ];
        _teamIds = [ propertyList arrayForKey:@"TeamIdentifier" ];
        _platforms = [ propertyList arrayForKey:@"Platform" ];
        _provisionedDevices = [ propertyList arrayForKey:@"ProvisionedDevices" ];
        _entitlements = [ propertyList objectForKey:@"Entitlements" ];
        if ( _entitlements == nil || ![ _entitlements isKindOfClass:[ NSDictionary class ]]) {
            _entitlements = @{};
        }
        _bundleId = [ _entitlements objectForKey:@"application-identifier" ];
        _apsEnvironment = [ _entitlements objectForKey:@"aps-environment" ];
        NSMutableArray *certsDesc = [ NSMutableArray new ];
        NSArray *certs = [ propertyList objectForKey:@"DeveloperCertificates" ];
        if ( certs != nil && [ certs isKindOfClass:[ NSArray class ]] && certs.count > 0 ) {
            for ( NSData *certData in certs ) {
                SecCertificateRef certificateRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
                if ( certificateRef != nil ) {
                    CFStringRef summaryRef = SecCertificateCopySubjectSummary(certificateRef);
                    NSString *summary = (NSString *)CFBridgingRelease(summaryRef);
                    [ certsDesc addObject:summary ];
                    CFRelease(certificateRef);
                }
            }
        }
        _developerCertificates = [ certsDesc copy ];

        // determine the profile type
        BOOL getTaskAllow = [[ self.entitlements objectForKey:@"get-task-allow" ] boolValue ];
        BOOL hasDevices = self.provisionedDevices.count > 0;
        BOOL isEnterprise = [[propertyList objectForKey:@"ProvisionsAllDevices"] boolValue];
        if ([ self.platforms containsObject:@"iOS" ]) {
            if ( hasDevices ) {
                if ( getTaskAllow ) {
                    _type = kMobileDev;
                } else {
                    _type = kMobileAdhoc;
                }
            } else {
                if ( isEnterprise ) {
                    _type = kMobileEnterprise;
                } else {
                    _type = kMobileStore;
                }
            }
        } else {
            if ( hasDevices ) {
                _type = kMacDev;
            } else {
                _type = kMacStore;
            }
        }
    }
    return self;
}

-( void )addDescriptionOf:( NSArray<NSString*>* )array into:( NSMutableString* )desc {
    for ( NSString *item in array ) {
        [ desc appendFormat:@"\t\t%@\n", item ];
    }
}

-( NSString* )description {
    NSMutableString *result = [ NSMutableString stringWithFormat:@"%@\n", self.path ];
    [ result appendFormat:@"\tName: %@\n", self.name ];
    [ result appendFormat:@"\tUUID: %@\n", self.uuid ];
    [ result appendFormat:@"\tType: %@\n", self.typeName ];
    [ result appendFormat:@"\tApp ID Name: %@\n", self.appIdName ];
    [ result appendString:@"\tApp ID Prefix:\n" ];
    [ self addDescriptionOf:self.appIdPrefix into:result ];
    [ result appendFormat:@"\tCreate: %@\n", self.creationDate ];
    [ result appendFormat:@"\tExpire: %@\n", self.expirationDate ];
    [ result appendFormat:@"\tTeam Name: %@\n", self.teamName ];
    [ result appendString:@"\tTeam Id:\n" ];
    [ self addDescriptionOf:self.teamIds into:result];
    [ result appendString:@"\tPlatform:\n" ];
    [ self addDescriptionOf:self.platforms into:result ];
    [ result appendFormat:@"\tEntitlements:\n%@\n", self.entitlements ];
    [ result appendString:@"\tCertificates:\n" ];
    [ self addDescriptionOf:self.developerCertificates into:result ];
    [ result appendString:@"\tDevices:\n" ];
    [ self addDescriptionOf:self.provisionedDevices into:result ];
    [ result appendFormat:@"\tTime Life: %@\n", @( self.timeToLive )];
    [ result appendFormat:@"\tVersion: %@\n", @( self.version )];
    return [ result copy ];
}

-( NSString* )typeName {
    switch ( self.type ) {
        case kUnknown:
            return @"Unknown";
        case kMacDev:
            return @"Mac OS X Development";
        case kMacStore:
            return @"Mac OS X Store";
        case kMobileDev:
            return @"iOS Development";
        case kMobileAdhoc:
            return @"iOS Adhoc";
        case kMobileEnterprise:
            return @"iOS Enterprise";
        case kMobileStore:
            return  @"iOS Store";
    }
}

+( NSDate* )convertDate:(NSString *)inputDate {
    NSDateFormatter *dateFormatter = [[ NSDateFormatter alloc ] init ];
    dateFormatter.dateFormat = @"y-MM-dd HH:mm:ss Z";
    return [ dateFormatter dateFromString:inputDate ];
}

@end
