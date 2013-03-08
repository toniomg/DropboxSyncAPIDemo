//
//  ViewController.h
//  DropboxSyncAPIDemo
//
//  Created by Antonio Martinez on 18/02/2013.
//  Copyright (c) 2013 Antonio Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView * dropboxContentTableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *linkAccountButton;

-(IBAction)linkAccountPressed:(id)sender;
-(IBAction)newImagePressed:(id)sender;
-(IBAction)newNotePressed:(id)sender;

-(void)accountIsConnected:(NSString *)accID;

@end
