//
//  main.m
//  rnMPP
//
//  Created by DươngPQ on 01/03/2018.
//  Copyright © 2018 GMO-Z.com RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPPProfile.h"

void printError( NSString *errDesc ) {
    NSFileHandle *fileHandle = [ NSFileHandle fileHandleWithStandardError ];
    [ fileHandle writeData:[ errDesc dataUsingEncoding:NSUTF8StringEncoding ]];
}

void printHelp() {
    printf("Usage: \n");
    printf("$ rnMPP: (no argument) show short description for every `.mobieprovision` in user's `~/Library/MobileDevice/Provisioning Profiles` folder.\n");
    printf("$ rnMPP <path>: Show full description of given provision profile file.\n");
    printf("$ rnMPP install <path>: Copy the file into default folder if it's not existed or it's newer than the existed one.\n");
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

void printProfile( NSString *path ) {
    NSString *fullPath = [ path hasPrefix:@"/" ] ? path : [ NSFileManager.defaultManager.currentDirectoryPath stringByAppendingPathComponent:path ];
    NSFileManager *fileMan = [ NSFileManager defaultManager ];
    if (![ fileMan fileExistsAtPath:fullPath ]) return;
    MPPProfile *profile = [[ MPPProfile alloc ] initWithFile:fullPath ];
    if ( profile == nil ) return;
    printf( "%s\n", profile.description.UTF8String );
}

NSString *makeProfileName( MPPProfile* profile, NSString *pattern ) {
    NSString *destName = pattern;
    destName = [ destName stringByReplacingOccurrencesOfString:@"%name%" withString:profile.name ];
    destName = [ destName stringByReplacingOccurrencesOfString:@"%uuid%" withString:profile.uuid ];
    destName = [ destName stringByReplacingOccurrencesOfString:@"%appid%" withString:profile.appIdName ];
    destName = [ destName stringByReplacingOccurrencesOfString:@"%create%" withString:profile.creationDate ];
    destName = [ destName stringByReplacingOccurrencesOfString:@"%expire%" withString:profile.expirationDate ];
    destName = [ destName stringByReplacingOccurrencesOfString:@"%team%" withString:profile.teamName ];
    destName = [ destName stringByReplacingOccurrencesOfString:@"/" withString:@"_" ];
    destName = [ destName stringByReplacingOccurrencesOfString:@":" withString:@"_" ];
    destName = [ destName stringByReplacingOccurrencesOfString:@"*" withString:@"Wildcat" ];
    if (![ destName.pathExtension isEqualToString:@"mobileprovision" ]) {
        destName = [ destName stringByAppendingPathExtension:@"mobileprovision" ];
    }
    return destName;
}

void renameProfile( NSString *path, NSString* pattern ) {
    NSString *fullPath = [ path hasPrefix:@"/" ] ? path : [ NSFileManager.defaultManager.currentDirectoryPath stringByAppendingPathComponent:path ];
    NSFileManager *fileMan = [ NSFileManager defaultManager ];
    if (![ fileMan fileExistsAtPath:fullPath ]) {
        printError([ NSString stringWithFormat:@"\"%@\" not found!", path ]);
        return;
    }
    MPPProfile *profile = [[ MPPProfile alloc ] initWithFile:fullPath ];
    if ( profile == nil ) {
        printError([ NSString stringWithFormat:@"Faile to load \"%@\" as provision profile file!", path ]);
        return;
    }
    NSString *destName = makeProfileName( profile, pattern );
    printf( "%s => %s\n", fullPath.lastPathComponent.UTF8String, destName.UTF8String );
    NSString *fullDestPath = [[ fullPath stringByDeletingLastPathComponent ] stringByAppendingPathComponent:destName ];
    if ([ fullDestPath isEqualToString:fullPath ]) {
        printf( "Ignore...\n" );
        return;
    }
    NSError *err = nil;
    [ fileMan moveItemAtPath:fullPath toPath:fullDestPath error:nil ];
    if ( err != nil ) {
        printError( err.localizedDescription );
    }
}

void renameProfilesInLibrary( NSString *pattern ) {
    NSString *folder = [ NSHomeDirectory() stringByAppendingPathComponent:@"Library/MobileDevice/Provisioning Profiles" ];
    NSArray *items = [ NSFileManager.defaultManager contentsOfDirectoryAtPath:folder error:NULL ];
    if ( items != nil && items.count > 0 ) {
        for ( NSString *item in items ) {
            if ([ item.pathExtension isEqualToString:@"mobileprovision" ]) {
                renameProfile([ folder stringByAppendingPathComponent:item ], pattern );
            }
        }
    }
}

int installProfile( NSString* path ) {
    MPPProfile *inputProfile = [[ MPPProfile alloc ] initWithFile:path ];
    if ( inputProfile == nil ) { return 1; }
    NSFileManager *fileMan = [ NSFileManager defaultManager ];
    NSDate *inputExDate = [ MPPProfile convertDate:inputProfile.expirationDate ];
    printf( "Installing profile info: %s\n", inputProfile.description.UTF8String );
    NSString *folder = [ NSHomeDirectory() stringByAppendingPathComponent:@"Library/MobileDevice/Provisioning Profiles" ];
    NSArray *items = [ fileMan contentsOfDirectoryAtPath:folder error:NULL ];
    NSString *oldItem = nil;
    if ( items != nil && items.count > 0 ) {
        for ( NSString *item in items ) {
            if ([ item.pathExtension isEqualToString:@"mobileprovision" ]) {
                NSString *fullItemPath = [ folder stringByAppendingPathComponent:item ];
                MPPProfile *profile = [[ MPPProfile alloc ] initWithFile:fullItemPath ];
                if ( profile != nil && ([ profile.uuid isEqualToString:inputProfile.uuid ] || [ profile.name isEqualToString:inputProfile.name ])) {
                    NSDate *exDate = [ MPPProfile convertDate:profile.expirationDate ];
                    if ( exDate != nil && inputExDate != nil && [ inputExDate timeIntervalSinceDate:exDate ] <= 0 ) {
                        printf( "Found existed profile: %s [%s]\n", item.UTF8String, profile.expirationDate.UTF8String );
                        return 0;
                    }
                    oldItem = fullItemPath;
                }
            }
        }
    }

    if (![ fileMan fileExistsAtPath:folder ]) {
        [ fileMan createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL ];
    }
    if ( oldItem != nil ) {
        printf( "Remove old \"%s\"\n", oldItem.UTF8String );
        [ fileMan removeItemAtPath:oldItem error:NULL ];
    }
    NSError *error = NULL;
    NSString *targetPath = [ folder stringByAppendingPathComponent:makeProfileName( inputProfile, @"%name%" )];
    printf( "Copy to \"%s\"\n", targetPath.UTF8String );
    BOOL result = [ fileMan copyItemAtPath:path toPath:targetPath error:NULL ];
    if ( !result ) {
        printf( "ERROR: %s\n", error.localizedDescription.UTF8String );
    }
    return result;
}

int main( int argc, const char * argv[] ) {
    @autoreleasepool {
        printf( "Rename Mobile Provision Profile by soleilpqd@gmail.com. Ver 1.0.\n" );
        printf( "----\n" );
        switch ( argc ) {
            case 1:
                printProfilesInfoInLibrary();
                break;
            case 2:
            {
                NSString *arg1 = [ NSString stringWithUTF8String:argv[1] ];
                if ([ arg1 isEqualToString:@"help" ]) {
                    printHelp();
                } else if ([ arg1 containsString:@"%" ]) {
                    renameProfilesInLibrary( arg1 );
                } else {
                    printProfile( arg1 );
                }
            }
                break;
            case 3:
            {
                NSString *arg1 = [ NSString stringWithUTF8String:argv[1] ];
                NSString *arg2 = [ NSString stringWithUTF8String:argv[2] ];
                if ([ arg1 isEqualToString:@"install" ]) {
                    return installProfile( arg2 );
                } else {
                    renameProfile( arg2, arg1 );
                }
            }
                break;
            default:
                break;
        }
    }
    return 0;
}
