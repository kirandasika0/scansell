//
//  SignupViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 26/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SignupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumberField;
- (IBAction)signup:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
