//
//  DareGroup.m
//  Play2
//
//  Created by Jun Kit Lee on 4/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "DareGroup.h"

@implementation DareGroup
@synthesize dareGroupName;
@synthesize photoCount;

- (id)initWithName:(NSString *)aName photoCount:(int)aPhotoCount
{
    self = [super init];
    if (self)
    {
        self.dareGroupName = aName;
        self.photoCount = [NSNumber numberWithInt:aPhotoCount];
    }
    
    return self;
}

@end
