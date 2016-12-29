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
#import <pop/POP.h>

@implementation LoginViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    self.backgoundView.layer.cornerRadius = 15.0;
    [self drawGradient];
    //Registering to required notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginConfirmation:) name:kLoggedInConfirmation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailure:) name:kLoginFailure object:nil];
    
    self.passwordField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideLabel];
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
    [self hideLabel];
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([username length] > 0 && [password length] > 0) {
        NSLog(@"Login user.");
        [[User sharedInstance] loginUserWithUsername:username andPassword:password];
    }
    else{
        self.errorLabel.text = @"Type in all fields.";
        [self shakeButton];
        [self showLabel];
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
    self.errorLabel.text = userInfo[@"error"];
    [self shakeButton];
    [self showLabel];
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

-(void) hideLabel{
    POPBasicAnimation *layerScaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    layerScaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.5f, 0.5f)];
    [self.errorLabel.layer pop_addAnimation:layerScaleAnimation forKey:@"layerScaleAnimation"];
    self.errorLabel.layer.opacity = 0.0f;
    [self.errorLabel setHidden:YES];
}

-(void) showLabel{
    [self.errorLabel setHidden:NO];
    self.errorLabel.layer.opacity = 1.0f;
    POPSpringAnimation *layerScaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    layerScaleAnimation.springBounciness = 18;
    layerScaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    [self.errorLabel.layer pop_addAnimation:layerScaleAnimation forKey:@"labelScaleAnimation"];
    
}

-(void) shakeButton{
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleX];
    springAnimation.velocity = @150;
    springAnimation.springBounciness = 10;
    [springAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        self.loginButton.userInteractionEnabled = YES;
    }];
    [self.loginButton.layer pop_addAnimation:springAnimation forKey:@"loginButtonSpringAnimation"];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length >= 3) {
        [self recolorLoginButton];
    }
    else{
        [self redRecolorLoginButton];
    }
    return YES;
}

-(void)recolorLoginButton{
    self.loginButton.backgroundColor = [UIColor colorWithRed:(46.0f/255.0f) green:(204.0f/255.0f) blue:(113.0f/255.0f) alpha:1.0f];
}

-(void)redRecolorLoginButton{
    self.loginButton.backgroundColor = [UIColor colorWithRed:(255.0f/255.0f) green:(59.0f/255.0f) blue:(48.0f/255.0f) alpha:1.0f];
}
@end
