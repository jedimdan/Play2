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
@synthesize countdownWebView;
@synthesize loadingLabel;

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
    [self performSelectorInBackground:@selector(determineDisplayCachedImagesOrNot) withObject:nil];
    
    NSString *countdownHTMLPath = [[NSBundle mainBundle] pathForResource:@"index2" ofType:@"html"];
    [self.countdownWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:countdownHTMLPath]]];
    
    self.countdownWebView.scalesPageToFit = YES;
    
}

- (void)determineDisplayCachedImagesOrNot
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *cachedBannerImages = [currentDefaults objectForKey:@"cachedBannerImages"];
    NSDate *cachedDate = (NSDate *)[currentDefaults objectForKey:@"cachedBannerDate"];
    
    if ((cachedBannerImages) && ([[NSDate date] timeIntervalSinceDate:cachedDate] < 3600))
    {
        NSLog(@"INFO: Cache present, and still fresh. Using cached banners for now.");
        NSArray *oldImages = [NSKeyedUnarchiver unarchiveObjectWithData:cachedBannerImages];
        if (oldImages)
        {
            [self performSelectorOnMainThread:@selector(displayBannerImages:) withObject:oldImages waitUntilDone:NO];
        }
    }
    
    else
    {
        NSLog(@"INFO: No cache, or cache is stale. Redownloading banners.");
        [self downloadBannerImages];
    }
}

- (void)downloadBannerImages
{
    NSError *error;
    NSURLResponse *response;
    NSString *jsonURI = [serverURL stringByAppendingPathComponent:@"banners"];
    
    NSURLRequest *jsonRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonURI] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    
    NSData *jsonResponse = [NSURLConnection sendSynchronousRequest:jsonRequest returningResponse:&response error:&error];
    
    if (error)
    {
        NSLog(@"Error downloading banner JSON: %@", [error localizedDescription]);
        return;
    }
    
    NSArray *bannerURLs = (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonResponse options:0 error:&error];
    
    if (error)
    {
        NSLog(@"Error parsing banner JSON: %@", [error localizedDescription]);
        return;
    }
    
    __block NSMutableArray *bannerImages = [NSMutableArray arrayWithCapacity:[bannerURLs count]];
    for (int i = 0; i < [bannerURLs count]; i++)
    {
        [bannerImages addObject:[NSNull null]];
    }
    
    [bannerURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            NSURLRequest *bannerRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:obj] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
            
            NSURLResponse *bannerResponse;
            NSError *bannerError;
            NSData *bannerImageData = [NSURLConnection sendSynchronousRequest:bannerRequest returningResponse:&bannerResponse error:&bannerError];
            
            if (bannerError)
            {
                //handle it
                NSLog(@"Error: %@", bannerError);
            }
            
            else {
                UIImage *banner = [UIImage imageWithData:bannerImageData];
                [bannerImages replaceObjectAtIndex:idx withObject:banner];
            }
        }];
        
        [queue addOperation:op];
    }];
    
    [queue waitUntilAllOperationsAreFinished];
    [self performSelectorInBackground:@selector(archiveBannerImagesArray:) withObject:bannerImages];
    [self performSelectorOnMainThread:@selector(displayBannerImages:) withObject:bannerImages waitUntilDone:NO];
    
}

- (void)archiveBannerImagesArray: (NSArray *)bannerImages
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:bannerImages] forKey:@"cachedBannerImages"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"cachedBannerDate"];
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
    [self setCountdownWebView:nil];
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
