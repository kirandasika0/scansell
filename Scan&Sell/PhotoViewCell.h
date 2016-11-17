//
//  PhotoViewCell.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 14/12/15.
//  Copyright © 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end
