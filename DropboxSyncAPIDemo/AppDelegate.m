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

static NSString *APP_KEY     = @"g7i6yjcw64au1j8";
static NSString *APP_SECRET  = @"6klwyiwc5ew1nug";

@synthesize mainViewController = _mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    self.mainViewController = (MainViewController *)[navController.viewControllers objectAtIndex:0];
    
    //Init the account manager
    DBAccountManager* accountMgr = [[DBAccountManager alloc] initWithAppKey:APP_KEY secret:APP_SECRET];
    [DBAccountManager setSharedManager:accountMgr];
    
    //check if the account is already conected
    DBAccount *account = accountMgr.linkedAccount;
    [self checkAccountConnected:account];

    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation {
    
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    
    BOOL connected = [self checkAccountConnected:account];

    return connected;
}


/** Check if the account is connected, and tell the MainController
 */
-(BOOL)checkAccountConnected:(DBAccount *)account
{
    if (account)
    {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
        
        DBAccountInfo *accInfo = account.info;
        
        [self.mainViewController accountIsConnected:accInfo.displayName];
        
        return YES;
    }

    return NO;
}



@end
