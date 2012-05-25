//
//  PhotoGridViewController.h
//  Play2
//
//  Created by Jun Kit Lee on 24/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <KKGridView/KKGridViewController.h>
#import "MWPhotoBrowser.h"

@interface PhotoGridViewController : KKGridViewController <MWPhotoBrowserDelegate> {
    NSArray *images;
    MWPhotoBrowser *photoBrowser;
}

@end
