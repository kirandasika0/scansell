//
//  AppDelegate.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 25/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import "AppDelegate.h"
#import "Book.hpp"
#import "RankFeedWrapper.h"
#import "INTULocationManager.h"
#import "AFNetworking.h"
#import "User.h"
@import Firebase;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self customInterface];
    
    //[GeoFeed setFeedType:@"1"];
    
    //Configuring firebase
    [FIRApp configure];
    
    //Get the user's cuurent location
    //[self getLocation];
    
    //setting up persistence store for hits
    //[RankFeedWrapper setUpPersistenceStore];
    
    //checking if the app was opened through quick action
//    UIApplicationShortcutItem *shortCutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
//    if (shortCutItem) {
//        //was opened through short cut action
//        [self handleShortcutAppOpen:shortCutItem];
//    }
    
    if ([[User sharedInstance] isActive]) {
        INTULocationManager *locMgr = [INTULocationManager sharedInstance];
        [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
            if (status == INTULocationStatusSuccess) {
                // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                // currentLocation contains the device's current location.
                [[User sharedInstance] setGeoPoint:currentLocation.coordinate];
                [[NSNotificationCenter defaultCenter] postNotificationName:kInitialLocationConfirmation object:nil];
            }
            else if (status == INTULocationStatusTimedOut) {
                // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                // However, currentLocation contains the best location available (if any) as of right now,
                // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                NSLog(@"time out");
            }
            else {
                // An error occurred, more info is available by looking at the specific status returned.
                NSLog(@"there was an error you're fucked");
            }
        }];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    //[userDefs removeObjectForKey:@"user_current_point"];
    [userDefs removeObjectForKey:@"saw_scan_barcode_dialog"];
    [userDefs removeObjectForKey:@"saw_book_image_view_dialog"];
    [userDefs removeObjectForKey:@"user_current_location"];
    [userDefs removeObjectForKey:@"has_seen_update_alert"];
    [userDefs synchronize];
    NSLog(@"%@", [userDefs objectForKey:@"user_current_location"]);
    NSLog(@"App entered background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"foreground");
    //[self getLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"active");
    //[self getLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    NSLog(@"Termination");
//    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
//    [userDefs removeObjectForKey:@"user_current_point"];
//    [userDefs synchronize];
//    NSLog(@"%@", [userDefs objectForKey:@"user_current_point"]);
    [RankFeedWrapper uninstallPersisteneceStore];
}

-(void)getLocation{
    //Get the user's cuurent location
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint * _Nullable geoPoint, NSError * _Nullable error) {
        if (geoPoint) {
            NSDictionary *userCurrentLocation = @{@"latitude": [NSString stringWithFormat:@"%f",geoPoint.latitude], @"longitude": [NSString stringWithFormat:@"%f", geoPoint.longitude]};
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:userCurrentLocation forKey:@"user_current_point"];
            [prefs synchronize];
            dispatch_semaphore_signal(semaphore);
            //NSLog(@"%@", geoPoint);
        }
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW);
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)customInterface{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBarBackground"] forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
}

-(void)handleShortcutAppOpen:(UIApplicationShortcutItem *)shortcutItem{
    //Getting instance of the tab bar controller
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    if ([shortcutItem.type isEqualToString:@"com.scanandsell.ss.scan_book"]) {
        [tabBarController setSelectedIndex:1];
    }
}
-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    if ([shortcutItem.type isEqualToString:@"com.scanandsell.ss.scan_book"]) {
        [tabBarController setSelectedIndex:1];
    }
}
-(void) updateLocationToServer {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *geoPoint = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_current_point"];
    NSLog(@"%@", geoPoint);
    NSDictionary *parameters = @{@"latitude": geoPoint[@"latitude"],
                                 @"longitude": geoPoint[@"longitude"],
                                 @"user_id": [[PFUser currentUser] objectId],
                                 @"memcache_key": [NSString stringWithFormat:@"%@_locationtrack", [[PFUser currentUser] objectId]]};
    NSLog(@"%@", parameters);
    [manager POST:@"https://scansell.herokuapp.com/users_b/update_location/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}
@end
