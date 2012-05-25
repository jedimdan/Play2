//
//  MatrixViewController.h
//  Play2
//
//  Created by Jun Kit Lee on 24/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface MatrixViewController : UIViewController <MWPhotoBrowserDelegate> {
    NSMutableArray *photos;
}

@end
