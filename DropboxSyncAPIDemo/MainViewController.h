//
//  ViewController.h
//  DropboxSyncAPIDemo
//
//  Created by Antonio Martinez on 18/02/2013.
//  Copyright (c) 2013 Antonio Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

-(void)accountIsConnected:(NSString *)accID;


@end
