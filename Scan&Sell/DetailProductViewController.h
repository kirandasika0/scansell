//
//  DetailProductViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 26/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Sale.h"

@interface DetailProductViewController : UIViewController

@property (nonatomic, strong) PFObject *productDetails;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) Sale *sale;
@property (nonatomic, strong) PFUser *currentUser;

//Iboutlets
@property (weak, nonatomic) IBOutlet UIImageView *bookCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activtityInd;

- (IBAction)buy:(id)sender;
- (IBAction)showBookImages:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@end
