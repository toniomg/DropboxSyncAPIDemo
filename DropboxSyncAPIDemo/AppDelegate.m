//
//  AppDelegate.m
//  DropboxSyncAPIDemo
//
//  Created by Antonio Martinez on 18/02/2013.
//  Copyright (c) 2013 Antonio Martinez. All rights reserved.
//

#import "AppDelegate.h"

#import <Dropbox/Dropbox.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *APP_KEY     = @"g7i6yjcw64au1j8";
    NSString *APP_SECRET  = @"6klwyiwc5ew1nug";
    
    DBAccountManager* accountMgr = [[DBAccountManager alloc] initWithAppKey:APP_KEY secret:APP_SECRET];
    [DBAccountManager setSharedManager:accountMgr];
    DBAccount *account = accountMgr.linkedAccount;
    
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation {
    
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
        NSLog(@"App linked successfully!");
        return YES;
    }
}
							


@end
