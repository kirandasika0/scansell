//
//  SignupViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 26/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import "SignupViewController.h"
#import "AFNetworking.h"
#import "User.h"
#import "INTULocationManager.h"

@implementation SignupViewController{
    NSMutableDictionary *requestPayload;
    CLLocationCoordinate2D tempLocation;
}


/**
 NSString *userRedisKey = [NSString stringWithFormat:@"%@_feed", newUser.objectId];
 NSDictionary *userParameters = @{@"user_id": newUser.objectId, @"username": newUser.username,
 @"email": email, @"mobile_number": mobileNumber,
 @"locale": userLocale, @"redis_key": userRedisKey};
 */

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signUpSuccess:) name:kSignUpSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signUpFailure:) name:kSignUpFailure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationSuccess:) name:@"locationSuccess" object:nil];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.locationLabel setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}





- (IBAction)signup:(id)sender {
    [UIView animateWithDuration:2.5 animations:^{
        if ([self.locationLabel isHidden]) {
            [self.locationLabel setHidden:NO];
        }
    }];
    if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *mobileNumber = [self.mobileNumberField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (username.length > 0 && password.length > 0 && email.length > 0 && mobileNumber.length > 0) {
        requestPayload = [[NSMutableDictionary alloc] init];
        requestPayload[@"username"] = username;
        requestPayload[@"password"] = password;
        requestPayload[@"email"] = email;
        requestPayload[@"mobile_number"] = mobileNumber;
        
        self.locationLabel.text = @"locating you...";
        INTULocationManager *locManager = [INTULocationManager sharedInstance];
        [locManager requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
            if (status == INTULocationStatusSuccess) {
                //Location accuracy achieved
                requestPayload[@"latitude"] = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
                requestPayload[@"longitude"] = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
                
                NSLog(@"%@", requestPayload);
                
                tempLocation = currentLocation.coordinate;
                
                //Send a notification
                [[NSNotificationCenter defaultCenter] postNotificationName:@"locationSuccess" object:nil userInfo:nil];
            }
            else if (status == INTULocationStatusTimedOut) {
                NSLog(@"timed out.");
            }
        }];
        self.locationLabel.text = @"done";
    }
}



-(void) signUpSuccess:(NSNotification *)notification {
    if ([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    [[User sharedInstance] setGeoPoint:tempLocation];

    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void) locationSuccess:(NSNotification *)notification {
    //Signup the user
    NSLog(@"Location success");
    [[User sharedInstance] signUpUserWithPayload:requestPayload];
}

-(void) signUpFailure:(NSNotification *)notification {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:notification.userInfo[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}
@end
