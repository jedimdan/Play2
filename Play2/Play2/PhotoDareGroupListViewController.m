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
    uploadConnectionsArray = [NSMutableArray array];
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
    
    NSString *serverURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Play2ServerURL"];
    NSURL *imageUploadURL = [NSURL URLWithString:[serverURL stringByAppendingPathComponent:@"upload"]];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imageUploadURL] 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSString *imageUploadString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog(@"URL is %@", imageUploadString);
                               [self uploadImageToServer:[NSURL URLWithString:imageUploadString] imageData:info];
                           }];
}

- (void)uploadImageToServer: (NSURL *)imageUploadURL imageData:(NSDictionary *)imageDictionary
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cgName = [defaults stringForKey:@"cgName"];
    
    UIImage *theImage = [imageDictionary objectForKey:UIImagePickerControllerOriginalImage];    
    UIImage *resizedImage = [theImage imageByScalingToSize:CGSizeMake(1024, 768)];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0);
    NSString *imageDate = [[[imageDictionary objectForKey:@"UIImagePickerControllerMediaMetadata"]
                                             objectForKey:@"{Exif}"]
                                             objectForKey:@"DateTimeOriginal"];
    NSString *imageFileName = [[[cgName stringByAppendingString:@" - "] stringByAppendingString:imageDate] stringByAppendingPathExtension:@"jpg"];

    
    //prepare the multipart request
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:imageUploadURL];
    
    NSString *boundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    [uploadRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    uploadRequest.HTTPMethod = @"POST";
    
    //prepare the multipart POST body
    NSMutableData *postBody = [NSMutableData data];
    @autoreleasepool {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"cg_name\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[cgName dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image_file\"; filename=\"%@\"\r\n", imageFileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:imageData];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"image_date\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[imageDate dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    uploadRequest.HTTPBody = postBody;
    
    NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:uploadRequest delegate:self];
    [uploadConnectionsArray addObject:theConnection];
    
    //get the index of the newly-added connection
    NSUInteger connectionIndex = [uploadConnectionsArray indexOfObject:theConnection];
    
    //and use this index to animate in the cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:connectionIndex inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancelled");
    [picker dismissModalViewControllerAnimated:YES];
}

/** NSURLConnectionDelegate methods **/

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    //get the correct cell
    NSUInteger connectionObjIndex = [uploadConnectionsArray indexOfObject:connection];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:connectionObjIndex inSection:0];
    PhotoUploadingCell *theCell = (PhotoUploadingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    theCell.imageUploadProgressView.progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    //NSLog(@"Getting a redirect to %@", [request URL]);
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //get the index path of the upload table view cell
    NSUInteger connectionObjIndex = [uploadConnectionsArray indexOfObject:connection];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:connectionObjIndex inSection:0];
    
    //remove the used connection object from the array
    [uploadConnectionsArray removeObject:connection];
    
    //remove the cell
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed with %@. %@", [error localizedDescription], [error userInfo]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
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
            return [uploadConnectionsArray count];
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
        
        cell.imageUploadProgressView.progress = 0.0;
        
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
