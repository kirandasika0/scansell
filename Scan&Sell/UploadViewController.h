//
//  UploadViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 18/12/15.
//  Copyright © 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UploadViewController : UIViewController
@property (nonatomic, strong) NSMutableDictionary *productDetails;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, strong) NSString *locationString;

- (IBAction)upload:(id)sender;

//IB Outlets
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descpLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uploadActivityInd;

//thumbnail image views
@property (weak, nonatomic) IBOutlet UIImageView *frontCoverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstCoverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backCoverImageView;


//Constants
extern NSString * const kNewSaleEndpoint;
@end
