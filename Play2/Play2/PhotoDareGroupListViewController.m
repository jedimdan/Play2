//
//  PhotoDareGroupListViewController.m
//  Play2
//
//  Created by Jun Kit Lee on 4/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoDareGroupListViewController.h"
#import "DareGroup.h"
#import "DGTableViewCell.h"
#import "PhotoUploadingCell.h"
#import "UIImage+RotateAndResize.h"
#import "PhotoUploadController.h"

@implementation PhotoDareGroupListViewController
@synthesize dareGroups;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    photoUploadControllersArray = [NSMutableArray array];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //create two sample Dare Groups
    self.dareGroups = [NSArray arrayWithObjects:[[DareGroup alloc] initWithName:@"Furiously Fantastic" photoCount:45], [[DareGroup alloc] initWithName:@"Mercifully Gracious Ones" photoCount:38], nil];
    
}

- (IBAction)photoButtonPressed:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    
    //save the image locally first
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!editedImage)
    {
        UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
    }
    
    else 
    {
        UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil);
    }
    
    PhotoUploadController *uploadController = [[PhotoUploadController alloc] initWithImageInfoDictionary:info];
    uploadController.delegate = self;
    [photoUploadControllersArray addObject:uploadController];
    [uploadController startUpload];
    
    //insert a new row to show users the upload
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[photoUploadControllersArray indexOfObject:uploadController] inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

/** PhotoUploadControllerDelegate methods **/

- (void)photoUploadController: (PhotoUploadController *)controller progressUpdate: (float)progress
{
    //find the cell corresponding to this controller
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[photoUploadControllersArray indexOfObject:controller] inSection:0];
    PhotoUploadingCell *cell = (PhotoUploadingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.imageUploadProgressView.progress = progress;
}

- (void)photoUploadDidFinish:(PhotoUploadController *)controller
{
    //remove the PhotoUploadController object from the array
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[photoUploadControllersArray indexOfObject:controller] inSection:0];
    [photoUploadControllersArray removeObject:controller];
    
    //remove the cell
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)photoUploadController:(PhotoUploadController *)controller didFailWithError: (NSError *)error
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    //find the cell corresponding to this controller
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[photoUploadControllersArray indexOfObject:controller] inSection:0];
    PhotoUploadingCell *cell = (PhotoUploadingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //update the cell to show error state
    [self convertCellToErrorState:cell controller:controller];
    
}

- (void)convertCellToErrorState: (PhotoUploadingCell *)cell controller:(PhotoUploadController *)controller
{
    cell.retryButton.hidden = NO;
    [cell.retryButton addTarget:controller action:@selector(startUpload) forControlEvents:UIControlEventTouchUpInside];
    [cell.retryButton addTarget:self action:@selector(retryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)retryButtonTapped:(id)sender
{
    //disable the button
    UIButton *button = (UIButton *)sender;
    button.hidden = YES;
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            return [photoUploadControllersArray count];
            break;
        case 1:
            return [dareGroups count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *dareGroupCell = @"DareGroupCell";
    static NSString *uploadCell = @"UploadCell";
    
    if ([indexPath section] == 1)
    {
        DGTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dareGroupCell];
        if (cell == nil) {
            cell = [[DGTableViewCell alloc] init];
            
        }
        
        // Configure the cell...
        DareGroup *theDareGroup = [self.dareGroups objectAtIndex:indexPath.row];
        cell.dareGroupName.text = theDareGroup.dareGroupName;
        cell.photoCount.text = [NSString stringWithFormat:@"%@", theDareGroup.photoCount];
        
        return cell;
    }
    
    else if ([indexPath section] == 0)
    {
        PhotoUploadingCell *cell = [tableView dequeueReusableCellWithIdentifier:uploadCell];
        if (cell == nil) {
            cell = [[PhotoUploadingCell alloc] init];
        }
        
        PhotoUploadController *theController = [photoUploadControllersArray objectAtIndex:indexPath.row];
        if ([theController hasFailed])
        {
            [self convertCellToErrorState:cell controller:theController];
        }
        cell.controller = theController;
        cell.previewImageView.image = [theController originalImage];
        cell.imageUploadProgressView.progress = theController.progressPercentage;
        
        return cell;
    }
    
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
