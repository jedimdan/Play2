//
//  FirstViewController.h
//  Play2
//
//  Created by Jun Kit Lee on 3/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CountdownTimerController;

@interface FirstViewController : UIViewController <UIScrollViewDelegate>
{
    NSOperationQueue *queue;
    NSString *serverURL;
}
@property (weak, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *bannerPageControl;
@property (weak, nonatomic) IBOutlet UILabel *countdownTimerLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (weak, nonatomic) IBOutlet UIWebView *countdownWebView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

- (void)determineDisplayCachedImagesOrNot;
- (void)downloadBannerImages;
@end
