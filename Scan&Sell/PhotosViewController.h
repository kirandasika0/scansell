//
//  PhotosViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 11/12/15.
//  Copyright © 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAPLCameraViewController.h"

@interface PhotosViewController : UITableViewController
//properties
@property (nonatomic, strong) NSMutableDictionary *productDetails;
@property (nonatomic) NSInteger *selectedIndexPath;
@property (nonatomic, strong) AAPLCameraViewController *takePhotosView;
@property (nonatomic, strong) NSDictionary *tempSegueDictionary;

- (IBAction)nextTapped:(id)sender;

@end
