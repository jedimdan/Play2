//
//  SecondViewController.h
//  Play2
//
//  Created by Jun Kit Lee on 3/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SecondViewController : UIViewController <MKMapViewDelegate>
{
    NSString *serverURL;
    NSOperationQueue *queue;
}
@property (weak, nonatomic) IBOutlet MKMapView *beachMapView;

@end
