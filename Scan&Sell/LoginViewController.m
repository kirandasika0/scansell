//
//  LoginViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 25/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "INTULocationManager.h"

@implementation LoginViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    self.backgoundView.layer.cornerRadius = 15.0;
    [self drawGradient];
    //Registering to required notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginConfirmation:) name:kLoggedInConfirmation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailure:) name:kLoginFailure object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"cached_username"] != NULL) {
        self.usernameField.text = [userDefaults objectForKey:@"cached_username"][@"cached_username"];
    }
    //Hiding navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)drawGradient{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.bounds;
    
    gradientLayer.colors = @[(id)[UIColor greenColor].CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

- (IBAction)login:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([username length] > 0 && [password length] > 0) {
        NSLog(@"Login user.");
        [[User sharedInstance] loginUserWithUsername:username andPassword:password];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like you did not type all fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}


-(void) loginConfirmation:(NSNotification *)notification {
    //NSDictionary *userInfo = [notification userInfo];
//    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"Login confirmation");
    //Gather user location
    INTULocationManager *locManager = [INTULocationManager sharedInstance];
    [locManager requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        NSLog(@"%ld", (long)status);
        if (status == INTULocationStatusSuccess) {
            NSLog(@"got location");
            [[User sharedInstance] setGeoPoint:currentLocation.coordinate];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
        [[User sharedInstance] setGeoPoint:currentLocation.coordinate];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}


-(void) loginFailure:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    [self shakescreen];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:userInfo[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


//shake screen animation method
-(void)shakescreen
{
    //Shake screen
    CGFloat t = 5.0;
    CGAffineTransform translateRight = CGAffineTransformTranslate(CGAffineTransformIdentity, t, t);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, -t);
    
    self.view.transform = translateLeft;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^
     {
         [UIView setAnimationRepeatCount:2.0];
         self.view.transform = translateRight;
     } completion:^(BOOL finished)
     
     {
         if (finished)
         {
             [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
              {
                  self.view.transform = CGAffineTransformIdentity;
              }
                              completion:NULL];
         }
     }];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
