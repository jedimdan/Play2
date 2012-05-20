//
//  CountdownTimerController.h
//  Play2
//
//  Created by Jun Kit Lee on 3/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountdownTimerController : NSObject
{

}

@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) NSDate *eventDate;
@property (weak, nonatomic) UILabel *countdownTimerLabel;
@property (strong, nonatomic) NSTimer *timer;

- (id)initWithLabel:(UILabel *)aLabel;
- (NSString *)calculateRemainingTime;
- (void)updateLabel:(NSTimer*)theTimer;
@end
