//
//  Play2Place.m
//  Play2
//
//  Created by Jun Kit Lee on 3/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Play2Place.h"

@implementation Play2Place
@synthesize coordinate;
@synthesize subtitle;
@synthesize title;

- (id)initWithCoordinate: (CLLocationCoordinate2D)aCoordinate title:(NSString *)aTitle subtitle:(NSString *)aSubtitle
{
    self = [super init];
    if (self)
    {
        coordinate = aCoordinate;
        subtitle = aSubtitle;
        title = aTitle;
        
    }
    
    return self;
}


@end
