//
//  User.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 13/10/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Sale.h"

@interface User : NSObject{
    @private
    NSString *userId;
    NSString *username;
    NSString *mobileNumber;
    NSString *email;
    NSString *redisKey;
    NSString *currentLocale;
    CLLocationCoordinate2D geoPoint;
    BOOL active;
}

//Constants
extern NSString * const kLoginFailure;
extern NSString * const kLoggedInConfirmation;
extern NSString * const kLogInEndpoint;
extern NSString * const kSignUpEndpoint;
extern NSString * const kSignUpSuccess;
extern NSString * const kSignUpFailure;
extern NSString * const kInitialLocationConfirmation;
extern NSString * const kSliderFeedEndpoint;
extern NSString * const kHottestDealsEndpoint;
extern NSString * const kGetMySalesEndpoint;

//Getters
-(NSString *)userId;
-(NSString *)username;
-(NSString *)mobileNumber;
-(NSString *)email;
-(NSString *)redisKey;
-(NSString *)currentLocale;
-(CLLocationCoordinate2D)geoPoint;
-(NSString *)bidStructureKey;
-(BOOL) isActive;

//Setter
-(BOOL) setGeoPoint:(CLLocationCoordinate2D)geoPointIn;

//Methods
+(User *) sharedInstance;
-(void) loginUserWithUsername:(NSString *)usernameIn andPassword:(NSString *)passwordIn;
-(void) signUpUserWithPayload:(NSDictionary *)requestPayload;
-(BOOL) logout;
-(void) getHottestDealWithCompletionHandler:(void(^)(Sale *hottestSale, BOOL success))completionHandler;
-(void) getMySalesWithCompletionHandler:(void(^)(BOOL success, NSArray *sales))completionHandler;
@end
