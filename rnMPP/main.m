//
//  main.m
//  rnMPP
//
//  Created by DươngPQ on 01/03/2018.
//  Copyright © 2018 GMO-Z.com RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPPProfile.h"

void printHelp() {
    printf("Usage: \n");
    printf("$ rnMPP: (no argument) show short description for every `.mobieprovision` in user's `~/Library/MobileDevice/Provisioning Profiles` folder.\n");
    printf("$ rnMPP <path>: Show full description of given provision profile file.\n");
    printf("$ rnMPP <pattern>: Rename all `.mobieprovision` in user's `~/Library/MobileDevice/Provisioning Profiles` folder. with given pattern\n");
    printf("$ rnMPP <pattern> <path>: Rename given provision profile file with given pattern\n");
    printf("$ rnMPP help: Show this help.\n");
    printf("\nPattern should include one or more words below for replace with equivalent value:\n");
    printf("\t%%name%%: Profile name\n");
    printf("\t%%uuid%%: UUID\n");
    printf("\t%%appid%%: App ID Name\n");
    printf("\t%%create%%: Creation date\n");
    printf("\t%%expire%%: Expiration date\n");
    printf("\t%%team%%: Team Name\n");
}

void printProfilesInfoInLibrary() {
    NSString *folder = [ NSHomeDirectory() stringByAppendingPathComponent:@"Library/MobileDevice/Provisioning Profiles" ];
    NSArray *items = [ NSFileManager.defaultManager contentsOfDirectoryAtPath:folder error:NULL ];
    if ( items != nil && items.count > 0 ) {
        for ( NSString *item in items ) {
            if ([ item.pathExtension isEqualToString:@"mobileprovision" ]) {
                MPPProfile *profile = [[ MPPProfile alloc ] initWithFile:[ folder stringByAppendingPathComponent:item ]];
                if ( profile != nil ) {
                    printf( "%s\n", item.UTF8String );
                    printf( "\tNAME: %s\n", profile.name.UTF8String );
                    printf( "\tUUID: %s\n", profile.uuid.UTF8String );
                    if ( profile.bundleId != nil ) {
                        printf( "\tBundle ID: %s\n", profile.bundleId.UTF8String );
                    }
                    printf( "\tCreate: %s\n", profile.creationDate.UTF8String );
                    printf( "\tExpire: %s\n", profile.expirationDate.UTF8String );
                    printf( "\tType: %s\n", profile.typeName.UTF8String );
                    printf( "--\n" );
                }
            }
        }
    }
}

void renameProfile(NSString *path, NSString* pattern) {
    NSString *fullPath = [ path hasPrefix:@"/" ] ? path : [ NSFileManager.defaultManager.currentDirectoryPath stringByAppendingPathComponent:path ];
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf( "Rename Mobile Provision Profile by soleilpqd@gmail.com. Ver 1.0.\n" );
        printf( "----\n" );
//        NSArray<NSString*> *formatKeys = @[@"%name%", @"%uuid%", @"%appid%", @"%create%", @"%expire%", @"%team%"];
        printProfilesInfoInLibrary();
//        printHelp();
    }
    return 0;
}
