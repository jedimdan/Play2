//
//  PhotoDareGroupListViewController.h
//  Play2
//
//  Created by Jun Kit Lee on 4/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDareGroupListViewController : UITableViewController <UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSArray *dareGroups;
- (IBAction)photoButtonPressed:(id)sender;

@end
