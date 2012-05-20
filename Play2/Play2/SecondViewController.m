//
//  SecondViewController.m
//  Play2
//
//  Created by Jun Kit Lee on 3/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "SecondViewController.h"
#import "Play2Place.h"

@implementation SecondViewController
@synthesize beachMapView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    beachMapView.delegate = self;
    
    MKCoordinateRegion tanjongBeach = MKCoordinateRegionMake(CLLocationCoordinate2DMake(1.244989, 103.825366), MKCoordinateSpanMake(0.004, 0.004));
	beachMapView.region = tanjongBeach;
    
    [self performSelectorInBackground:@selector(displayCachedAnnotations) withObject:nil];
}

- (void)displayCachedAnnotations
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *cachedAnnotations = [currentDefaults objectForKey:@"cachedAnnotations"];
    NSDate *cachedDate = (NSDate *)[currentDefaults objectForKey:@"cachedAnnotationsDate"];
    
    if ((cachedAnnotations) && ([[NSDate date] timeIntervalSinceDate:cachedDate] < 3600))
    {
        NSLog(@"INFO: Cache present, and still fresh. Using cached annotations.");
        NSArray *oldAnnotationsDict = [NSKeyedUnarchiver unarchiveObjectWithData:cachedAnnotations];
        [self loadAnnotations:oldAnnotationsDict];
    }
    

    else
    {
        NSLog(@"INFO: Cache not present, or stale. Redownloading annotations.");
        [self downloadAnnotations];
    }
}

- (void)downloadAnnotations
{
    serverURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Play2ServerURL"];
    queue = [[NSOperationQueue alloc] init];
    
    NSError *error;
    NSString *jsonURI = [serverURL stringByAppendingPathComponent:@"annotations"];
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:jsonURI]];
    
    NSArray *annotationsDict = (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonResponse options:0 error:&error];
    
    if (error)
    {
        //handle it
        NSLog(@"Error: %@", error);
    }
    
    [self loadAnnotations:annotationsDict];
    
    //cache the annotations
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:annotationsDict] forKey:@"cachedAnnotations"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"cachedAnnotationsDate"];
}

- (void)loadAnnotations: (NSArray *)annotationsDict
{
    __block NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[annotationsDict count]];
    [annotationsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *annotationDict = (NSDictionary *)obj;
        NSDictionary *coords = [annotationDict objectForKey:@"coords"];
        Play2Place *annotation = [[Play2Place alloc] initWithCoordinate:CLLocationCoordinate2DMake([[coords objectForKey:@"lat"] doubleValue], [[coords objectForKey:@"lon"] doubleValue])
                                                                  title:[annotationDict objectForKey:@"title"]
                                                               subtitle:[annotationDict objectForKey:@"subtitle"]];
        
        [annotations addObject:annotation];
    }];
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [beachMapView addAnnotations:annotations];
    }];
    
    [mainQueue addOperation:op];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // try to dequeue an existing pin view first
    static NSString* BridgeAnnotationIdentifier = @"MapAnnotation";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[beachMapView dequeueReusableAnnotationViewWithIdentifier:BridgeAnnotationIdentifier];
    
    if (pinView)
    {
        pinView.annotation = annotation;
    }
    
    else
    {
        //we need to create a new MKAnnotationView
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapAnnotation"];
        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
    }
    
    return pinView;
}

- (void)viewDidUnload
{
    [self setBeachMapView:nil];
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
