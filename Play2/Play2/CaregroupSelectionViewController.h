//
//  CaregroupSelectionViewController.h
//  Play2
//
//  Created by Jun Kit Lee on 23/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaregroupSelectionViewController : UITableViewController
{
    NSArray *caregroups;
    NSIndexPath *selectedRow;
}

-(IBAction)selectionDoneButtonPressed:(id)sender;

@end
