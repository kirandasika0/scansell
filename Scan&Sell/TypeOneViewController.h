//
//  TypeOneViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 12/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"
#import <Parse/Parse.h>

@interface TypeOneViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@property (nonatomic, strong) Notification *notification;

//Buttons Outlets and  actions
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
- (IBAction)confirm:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
- (IBAction)reject:(id)sender;

@end
