//
//  BookImageViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 11/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookImageViewController : UIViewController
@property (nonatomic, strong) NSArray *saleImages;


@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityInd;
@property (weak, nonatomic) IBOutlet UIImageView *saleImageView;
@end
