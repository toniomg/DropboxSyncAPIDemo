//
//  ViewController.m
//  DropboxSyncAPIDemo
//
//  Created by Antonio Martinez on 18/02/2013.
//  Copyright (c) 2013 Antonio Martinez. All rights reserved.
//

#import "MainViewController.h"

#import "AppDelegate.h"

#import <Dropbox/Dropbox.h>

@interface MainViewController ()

enum FileType{
    FileType_Note,
    FileType_Image
};

@property (strong, nonatomic) NSArray * folderContent;
@property (assign) enum FileType fileType;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) UIAlertView *nameAlertView;
@property (strong, nonatomic) UIAlertView *textAlertView;
@property (strong, nonatomic) UIBarButtonItem *buttonAddPicture;
@property (strong, nonatomic) UIBarButtonItem *buttonAddNote;

@end

@implementation MainViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        UIBarButtonItem *buttonLink = [[UIBarButtonItem alloc]  initWithTitle:@"Link" style:UIBarButtonItemStyleBordered target:self action:@selector(linkAccountPressed:)];
    
         self.buttonAddPicture = [[UIBarButtonItem alloc]  initWithTitle:@"Add Picture" style:UIBarButtonItemStyleBordered target:self action:@selector(newImagePressed:)];
        self.buttonAddPicture.enabled = NO;
        
         self.buttonAddNote = [[UIBarButtonItem alloc]  initWithTitle:@"Add Note" style:UIBarButtonItemStyleBordered target:self action:@selector(newNotePressed:)];
        self.buttonAddNote.enabled = NO;
        
        NSArray* toolbarItems = [NSArray arrayWithObjects:buttonLink, self.buttonAddPicture, self.buttonAddNote, nil];
        
        self.toolbarItems = toolbarItems;
        self.navigationController.toolbarHidden = NO;
    }
    
    return self;
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}


/**
 * When the account is created, reload the files in the tableview
 */
-(void)accountIsConnected:(NSString *)accID
{
    self.title = accID;
    self.buttonAddNote.enabled = YES;
    self.buttonAddPicture.enabled = YES;
    
    [[DBFilesystem sharedFilesystem] addObserver:self forPathAndChildren:[DBPath root] block:^(){
        [self performSelectorInBackground:@selector(listContent) withObject:nil];
    }];
    
    
    [self performSelectorInBackground:@selector(listContent) withObject:nil];
}

/** List the content of the dropbox folder
 */
-(void)listContent
{
    //Get the list of files in the folder
    DBError *error;
    NSArray *contents = [[DBFilesystem sharedFilesystem] listFolder:[DBPath root] error:&error];
    
    if (!error)
    {
        NSMutableArray *folderContentMutable = [[NSMutableArray alloc] init];
        
        for (DBFileInfo *info in contents) {
            if (![info isFolder])
                [folderContentMutable addObject:info.path];
        }

        self.folderContent = [[NSArray alloc] initWithArray:folderContentMutable];
        [self performSelectorOnMainThread:@selector(reloadTableData) withObject:nil waitUntilDone:YES];
    }
}

-(void)reloadTableData
{
    if ([self.refreshControl isRefreshing])
        [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

-(IBAction)refreshTable:(id)sender
{
    [self performSelectorInBackground:@selector(listContent) withObject:nil];
}


#pragma mark - Dropbox Util

-(void)addImage:(NSData *)imageData toFile:(NSString *)fileName
{
    DBFile *newImage = [self createNewFile:[NSString stringWithFormat:@"%@.jpg", fileName]];
    [newImage writeData:imageData error:nil];
}


-(void)addNote:(NSString *)text toFile:(NSString *)fileName
{
    DBFile *newNote = [self createNewFile:[NSString stringWithFormat:@"%@.txt", fileName]];
    [newNote writeString:text error:nil];
}

-(DBFile *)createNewFile:(NSString *)name
{
    DBPath *filePath = [[DBPath root] childPath:name];
    
    DBError *error;
    DBFile *newFile = [[DBFilesystem sharedFilesystem] createFile:filePath error:&error];
    
    if (!error)
        return newFile;
    else
        return nil;
}

-(void)removeFileFromPath:(DBPath *)path
{
    [[DBFilesystem sharedFilesystem] deletePath:path error:nil];
}

#pragma mark - Button Actions

-(IBAction)linkAccountPressed:(id)sender
{
    [[DBAccountManager sharedManager] linkFromController:self];
}


-(IBAction)newNotePressed:(id)sender
{
    self.fileType = FileType_Note;
    [self showNameSelector];
}

-(IBAction)newImagePressed:(id)sender
{
    self.fileType = FileType_Image;
    [self showNameSelector];
}


#pragma mark - Selectors

-(void)showImageSelector
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imgPicker animated:YES completion:nil];
}



-(void)showNameSelector
{
    NSString *title = @"";
    
    if (self.fileType == FileType_Note)
        title = @"Note name?";
    else if (self.fileType == FileType_Image)
        title = @"Image name?";
    
    self.nameAlertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    self.nameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.nameAlertView show];
}

-(void)showFileSelected:(DBPath *)filePath
{
    //Look for the selected path
    //DBPath *filePath = [self.folderContent objectAtIndex:indexPath.row];
    DBError *error;
    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:filePath error:&error];
    
    if (!error)
    {
        //Get the file type
        if ([[filePath.stringValue pathExtension] isEqualToString:@"jpg"])
        {
            UIViewController *simpleImage = [[UIViewController alloc] init];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = [UIImage imageWithData:[file readData:nil]];
            simpleImage.view = imageView;
            
            [self.navigationController pushViewController:simpleImage animated:YES];
        }
        else if ([[filePath.stringValue pathExtension] isEqualToString:@"txt"])
        {
            UIViewController *simpleText = [[UIViewController alloc] init];
            UITextField *noteText = [[UITextField alloc] initWithFrame:self.view.frame];
            noteText.backgroundColor = [UIColor whiteColor];
            noteText.text = [file readString:nil];
            simpleText.view = noteText;
            
            [self.navigationController pushViewController:simpleText animated:YES];
        }
    }
}

#pragma mark - UITableView

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
    
    DBPath *filePath = [self.folderContent objectAtIndex:indexPath.row];
    cell.textLabel.text = filePath.name;
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Read the file in background
    [self performSelectorInBackground:@selector(showFileSelected:) withObject:[self.folderContent objectAtIndex:indexPath.row]];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete the file
        DBPath *pathToDelete = [self.folderContent objectAtIndex:indexPath.row];
        [self removeFileFromPath:pathToDelete];
        [self performSelectorInBackground:@selector(listContent) withObject:nil];
    }
}


#pragma mark - ImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    NSData *imageData = UIImageJPEGRepresentation(img, 0.8);
    
    [self addImage:imageData toFile:self.fileName];
}


#pragma mark - UIAlertview Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (alertView == self.nameAlertView)
        {
            NSString *chosenName = [alertView textFieldAtIndex:0].text;
            self.fileName = chosenName;
            
            if (self.fileType == FileType_Note)
            {
                self.textAlertView = [[UIAlertView alloc] initWithTitle:@"Text?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
                self.textAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [self.textAlertView show];
            }
            else if (self.fileType == FileType_Image)
            {
                [self showImageSelector];
            }
        }
        
        else if (alertView == self.textAlertView)
        {
            NSString *text = [alertView textFieldAtIndex:0].text;
            if (text)
            {
                [self addNote:text toFile:self.fileName];
            }
        }
    }
}

@end
