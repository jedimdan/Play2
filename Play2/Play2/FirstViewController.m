//
//  FirstViewController.m
//  Play2
//
//  Created by Jun Kit Lee on 3/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "FirstViewController.h"
#import "CountdownTimerController.h"

@implementation FirstViewController
@synthesize bannerScrollView;
@synthesize bannerPageControl;
@synthesize countdownTimerLabel;
@synthesize loadingSpinner;
@synthesize loadingLabel;
@synthesize countdownTimer;
@synthesize timer;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    serverURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Play2ServerURL"];
    queue = [[NSOperationQueue alloc] init];
    
    bannerScrollView.delegate = self;
    [self performSelectorInBackground:@selector(downloadBannerImages) withObject:nil];
    
    self.countdownTimer = [[CountdownTimerController alloc] initWithLabel:self.countdownTimerLabel];
}

- (void)downloadBannerImages
{
    NSError *error;
    NSString *jsonURI = [serverURL stringByAppendingPathComponent:@"banners"];
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:jsonURI]];
    
    NSArray *bannerURLs = (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonResponse options:0 error:&error];
    
    if (error)
    {
        //handle it
        NSLog(@"Error: %@", error);
    }
    
    __block NSMutableArray *bannerImages = [NSMutableArray arrayWithCapacity:[bannerURLs count]];
    for (int i = 0; i < [bannerURLs count]; i++)
    {
        [bannerImages addObject:[NSNull null]];
    }
    
    [bannerURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            UIImage *banner = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:obj]]];
            [bannerImages replaceObjectAtIndex:idx withObject:banner];
        }];
        
        [queue addOperation:op];
    }];
    
    [queue waitUntilAllOperationsAreFinished];
    [self performSelectorOnMainThread:@selector(displayBannerImages:) withObject:bannerImages waitUntilDone:NO];
    
}


- (void)displayBannerImages: (NSArray *)bannerImages
{
    
    //set the final size of the UIScrollView
    self.bannerScrollView.contentSize = CGSizeMake(self.bannerScrollView.frame.size.width * bannerImages.count, 288);
    
    //put images in UIImageViews and place them in the scrollview
    for (int i = 0; i < [bannerImages count]; i++)
    {
        UIImage *bannerImage = [bannerImages objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(320 * i, 0, 320, 288)];
        imageView.image = bannerImage;
        
        [bannerScrollView addSubview:imageView];
    }
    
    bannerPageControl.numberOfPages = [bannerImages count];
    
    [loadingLabel removeFromSuperview];
    [loadingSpinner removeFromSuperview];
    
    bannerPageControl.hidden = NO;
    bannerScrollView.hidden = NO;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //update the page control
    CGFloat pageWidth = bannerScrollView.frame.size.width;
    float fractionalPage = bannerScrollView.contentOffset.x / pageWidth;
    
    bannerPageControl.currentPage = lroundf(fractionalPage);
}

- (void)viewDidUnload
{
    [self setBannerScrollView:nil];
    [self setBannerPageControl:nil];
    [self setCountdownTimerLabel:nil];
    [self setLoadingSpinner:nil];
    [self setLoadingLabel:nil];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
