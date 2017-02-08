//
//  HomeTableViewCell.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 26/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>

@interface HomeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bookcoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
