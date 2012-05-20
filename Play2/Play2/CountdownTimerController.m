//
//  CountdownTimerController.m
//  Play2
//
//  Created by Jun Kit Lee on 3/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "CountdownTimerController.h"

@implementation CountdownTimerController
@synthesize view;
@synthesize eventDate;
@synthesize countdownTimerLabel;
@synthesize timer;

- (id)initWithLabel:(UILabel *)aLabel
{
    self = [super init];
    if (self)
    {
        self.countdownTimerLabel = aLabel;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.eventDate = [formatter dateFromString:@"2012-06-30 13:00"];
    }
    
   
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel:) userInfo:nil repeats:YES];
    [self.timer fire];
    return self;
}

- (NSString *)calculateRemainingTime
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval interval = [eventDate timeIntervalSinceDate:currentDate];
    
    int days = interval / 86400;
    int hours = (interval - 86400 * days) / 3600;
    int minutes = (interval - (86400 * days) - (3600 * hours)) / 60;
    int seconds = (interval - (86400 * days) - (3600 * hours) - (60 * minutes));
    
    return [NSString stringWithFormat:@"%02i days %02i hours %02i minutes %02i seconds", days, hours, minutes, seconds];
}

- (void)updateLabel:(NSTimer*)theTimer
{
    countdownTimerLabel.text = [self calculateRemainingTime];
}

@end
