//
//  Play2Photo.m
//  Play2
//
//  Created by Jun Kit Lee on 25/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Play2Photo.h"

@implementation Play2Photo
@synthesize URL;

- (id)initWithURL:(NSURL *)url
{
    self = [super initWithURL:url];
    if (self)
    {
        URL = url;
    }
    
    return self;
}

@end
