//
//  PhotoGridViewController.m
//  Play2
//
//  Created by Jun Kit Lee on 24/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoGridViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

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
    NSString *serverURL = @"http://play2server.appspot.com/photos?limit=30";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverURL]];
    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *jsonError;
                               images = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               NSLog(@"%@", images);
                               [self.gridView reloadData];
    }];
}

/** KKGridViewDataSource methods **/
- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section
{
    if (!images) return 0; else return images.count;
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath
{
    NSURL *imageURL = [NSURL URLWithString:[[images objectAtIndex:indexPath.index] objectForKey:@"blob_serving_url"]];
    
    KKGridViewCell *cell = [KKGridViewCell cellForGridView:gridView];
    UIImageView *imageView = cell.imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImageWithURL:imageURL];

    return cell;
}

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath
{
    NSURL *imageURL = [NSURL URLWithString:[[images objectAtIndex:indexPath.index] objectForKey:@"blob_serving_url"]];
    
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
