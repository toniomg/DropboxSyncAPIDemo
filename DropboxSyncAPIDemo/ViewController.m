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

@property (strong, nonatomic) NSArray * folderContent;

@end

@implementation ViewController

@synthesize folderContent = _folderContent;
@synthesize dropboxContentTableView = _dropboxContentTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Dropbox Sync API

-(void)listContent{
    
    NSMutableArray *folderContentMutable = [[NSMutableArray alloc] init];
    
    NSArray *contents = [[DBFilesystem sharedFilesystem] listFolder:[DBPath root] error:nil];
    for (DBFileInfo *info in contents) {
        [folderContentMutable addObject:info.path];
    }
    
    self.folderContent = [[NSArray alloc] initWithArray:folderContentMutable];
    
    [self.dropboxContentTableView reloadData];

}

#pragma mark - Button Actions

-(IBAction)linkAccountPressed:(id)sender {
    [[DBAccountManager sharedManager] linkFromController:self];
}


#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.folderContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"DropboxListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.folderContent objectAtIndex:indexPath.row];
    
    return cell;

}


@end
