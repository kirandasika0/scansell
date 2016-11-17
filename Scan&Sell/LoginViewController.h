//
//  LoginViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 25/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *backgoundView;

- (IBAction)login:(id)sender;

@end
