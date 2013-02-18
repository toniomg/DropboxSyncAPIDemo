//
//  ViewController.m
//  DropboxSyncAPIDemo
//
//  Created by Antonio Martinez on 18/02/2013.
//  Copyright (c) 2013 Antonio Martinez. All rights reserved.
//

#import "ViewController.h"

#import <Dropbox/Dropbox.h>

@interface ViewController ()

@property (strong, nonatomic) NSDictionary * folderContent;

@end

@implementation ViewController

@synthesize folderContent = _folderContent;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[[DBAccountManager sharedManager] linkFromController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Dropbox Sync API

-(void)listContent{
    
    NSMutableDictionary *folderContentMutable = [[NSMutableDictionary alloc] init];
    
    NSArray *contents = [[DBFilesystem sharedFilesystem] listFolder:[DBPath root] error:nil];
    for (DBFileInfo *info in contents) {
        [folderContentMutable setObject:@"1" forKey:info.path];
    }
    
    self.folderContent = [[NSDictionary alloc] initWithDictionary:folderContentMutable];

}
#pragma mark - Actions

-(IBAction)linkAccountPressed:(id)sender {
    [[DBAccountManager sharedManager] linkFromController:self];
}

@end
