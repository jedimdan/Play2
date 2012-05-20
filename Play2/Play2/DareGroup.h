//
//  DareGroup.h
//  Play2
//
//  Created by Jun Kit Lee on 4/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DareGroup : NSObject

@property (strong, nonatomic) NSString *dareGroupName;
@property (strong, nonatomic) NSNumber *photoCount;

- (id)initWithName:(NSString *)aName photoCount:(int)aPhotoCount;

@end
