//
//  PhotoGridViewController.m
//  Play2
//
//  Created by Jun Kit Lee on 24/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoGridViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Play2Photo.h"

@interface PhotoGridViewController ()

@end

@implementation PhotoGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    NSString *serverURL = @"http://play2server.appspot.com/photos?limit=30";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverURL]];
    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *jsonError;
                               NSArray *imagesArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               images = [self Play2PhotoArrayFromJSONArray:imagesArray];
                               [self.gridView reloadData];
    }];
}

- (NSArray *)Play2PhotoArrayFromJSONArray: (NSArray *)imagesArray
{
    __block NSMutableArray *mwPhotoArray = [NSMutableArray array];
    [imagesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Play2Photo *photo = [[Play2Photo alloc] initWithURL:[NSURL URLWithString:[obj objectForKey:@"blob_serving_url"]]];
        [mwPhotoArray addObject:photo];
    }];
    
    return mwPhotoArray;
}

/** KKGridViewDataSource methods **/
- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section
{
    if (!images) return 0; else return images.count;
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath
{
    Play2Photo *photo = [images objectAtIndex:indexPath.index];
    NSString *thumbnailString = [photo.URL absoluteString];
    
    //get the frame of the cell
    KKGridViewCell *cell = [KKGridViewCell cellForGridView:gridView];
    int cellWidth = cell.frame.size.width;
    
    //get the correct-sized thumbnail
    NSURL *imageURL = [NSURL URLWithString:[thumbnailString stringByAppendingFormat:@"=s%i", cellWidth]];
    
    UIImageView *imageView = cell.imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImageWithURL:imageURL];

    return cell;
}

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath
{
    [photoBrowser setInitialPageIndex:indexPath.index];
    [self.navigationController pushViewController:photoBrowser animated:YES];
    
}


/** MWPhotoBrowserDelegate objects **/
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return images.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < images.count)
        return [images objectAtIndex:index];
    return nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
