//
//  User.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 13/10/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "User.h"
#import "AFNetworking.h"

//Constants
NSString * const kLoginEndpoint = @"http://scansell.herokuapp.com/users_b/login/";
NSString * const kLoginFailure = @"loginFailure";
NSString * const kLoggedInConfirmation = @"loggedInConfirmation";
NSString * const kSignUpEndpoint = @"http://scansell.herokuapp.com/users_b/create_user/";
NSString * const kSignUpSuccess = @"signUpSuccess";
NSString * const kSignUpFailure = @"signUpFailure";
NSString * const kInitialLocationConfirmation = @"initialLocationLocationConfirmation";
NSString * const kSliderFeedEndpoint = @"http://scansell.herokuapp.com/sale/slider_feed/";
NSString * const kHottestDealsEndpoint = @"https://scansell.herokuapp.com/sale/hot_deals/";
NSString * const kGetMySalesEndpoint = @"http://scansell.herokuapp.com/users_b/my_sales/";

@implementation User
-(instancetype)initWithPropertyList:(NSString *)pListPath {
    self = [super init];
    if (self) {
        NSMutableDictionary *savedData = [NSMutableDictionary dictionaryWithContentsOfFile:pListPath];
        if ([savedData count] != 0) {
            //User data found
            userId = savedData[@"userId"];
            username = savedData[@"username"];
            mobileNumber = savedData[@"mobileNumber"];
            redisKey = savedData[@"redisKey"];
            currentLocale = savedData[@"locale"];
            active = true;
        }
        else {
            //User data not found
            active = false;
        }
    }
    return self;
}




+(User *) sharedInstance {
    static User *sharedInstance = nil;
    if (sharedInstance == nil) {
        static dispatch_once_t once;
        _dispatch_once(&once, ^{
            sharedInstance = [[[self class] alloc] initWithPropertyList:[User returnUserDataFilePath]];
        });
    }
    return sharedInstance;
}


-(NSString *)userId {
    return userId;
}


-(NSString *)username{
    return username;
}

-(NSString *)mobileNumber {
    return mobileNumber;
}


-(NSString *)email {
    return email;
}


-(NSString *)redisKey {
    return redisKey;
}


-(NSString *)currentLocale {
    return currentLocale;
}


-(CLLocationCoordinate2D)geoPoint {
    return geoPoint;
}

-(NSString *)bidStructureKey{
    NSString *StructureKey = [NSString stringWithFormat:@"%@_bidStructure", self.userId];
    return StructureKey;
}

-(BOOL) isActive {
    return active;
}


-(BOOL) setGeoPoint:(CLLocationCoordinate2D)geoPointIn {
    geoPoint = geoPointIn;
    return true;
}


-(BOOL) saveData {
    BOOL flag = false;
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:[User returnUserDataFilePath]];
    [data setObject:userId forKey:@"userId"];
    [data setObject:username forKey:@"username"];
    [data setObject:mobileNumber forKey:@"mobileNumber"];
    [data setObject:email forKey:@"email"];
    [data setObject:redisKey forKey:@"redisKey"];
    [data setObject:currentLocale forKey:@"locale"];
    
    flag = [data writeToFile:[User returnUserDataFilePath] atomically:YES];
    
    return flag;
}

+(NSString *) returnUserDataFilePath {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"UserData.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    if (![fileManager fileExistsAtPath:path]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"UserData" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath:path error:&error];
    }
    return path;
}

/**
 * Method logs a user in with a username and password. Then, sends a notification to
 "loggedInConfirmation" or if failure then sends notification "loginFailure".
 */
-(void) loginUserWithUsername:(NSString *)usernameIn andPassword:(NSString *)passwordIn {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *requestPayload = @{@"username": usernameIn,
                                     @"password": passwordIn
                                     };
    [manager POST:kLoginEndpoint parameters:requestPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Send notification to appropriate notification
        if (responseObject[@"error"]) {
            //Invalid credentials
            NSDictionary *userInfo = @{@"error": responseObject[@"error"]};
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailure object:nil userInfo:userInfo];
            return;
        }
        
        
        
        //Setting responseObject to responseObject[@"fields"] for all db fields
        responseObject = responseObject[@"fields"];
        userId = responseObject[@"user_id"];
        username = responseObject[@"username"];
        mobileNumber = responseObject[@"mobile_number"];
        email = responseObject[@"email"];
        redisKey = responseObject[@"redis_key"];
        currentLocale = responseObject[@"locale"];
        //setting active to true to complete login
        
        [self saveData];
        
        
        
        
        //Posting to confirmation notification
        NSDictionary *userInfo = @{@"response": @true};
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInConfirmation object:nil userInfo:userInfo];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //Send notification to failure notification
        NSLog(@"%@", operation.responseString);
    }];
}

-(void) signUpUserWithPayload:(NSDictionary *)requestPayload {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:kSignUpEndpoint parameters:requestPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"error"]) {
            NSDictionary *userInfo = @{@"error": responseObject[@"error"]};
            [[NSNotificationCenter defaultCenter] postNotificationName:kSignUpFailure object:nil userInfo:userInfo];
            return;
        }
        
        responseObject = responseObject[@"fields"];
        userId = responseObject[@"user_id"];
        username = responseObject[@"username"];
        mobileNumber = responseObject[@"mobile_number"];
        email = responseObject[@"email"];
        redisKey = responseObject[@"redis_key"];
        currentLocale = responseObject[@"locale"];
        active = true;
        
        //Saving coodinate for this session
        
        [self saveData];
        
        
        

        
        //Post success notification
        NSDictionary *userInfo = @{@"response": @true};
        [[NSNotificationCenter defaultCenter] postNotificationName:kSignUpSuccess object:nil userInfo:userInfo];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //Failure
    }];
}

-(BOOL) logout {
    NSMutableDictionary *savedData = [NSMutableDictionary dictionaryWithContentsOfFile:[User returnUserDataFilePath]];
    [savedData removeAllObjects];
    return [savedData writeToFile:[User returnUserDataFilePath] atomically:YES];
}


-(void)getHottestDealWithCompletionHandler:(void (^)(Sale *, BOOL))completionHandler{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *requestPayload = @{@"user_id": userId};
    [manager POST:kHottestDealsEndpoint parameters:requestPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Sale *hottestSale = [[Sale alloc] init];
        hottestSale.saleId = responseObject[@"pk"];
        
        responseObject = responseObject[@"fields"];
        hottestSale.sellerUsename = responseObject[@"seller_username"];
        hottestSale.sellerId = responseObject[@"seller_id"];
        hottestSale.price = responseObject[@"price"];
        hottestSale.locationString = responseObject[@"location"];
        hottestSale.saleDescription = responseObject[@"description"];
        completionHandler(hottestSale, true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", operation.responseString);
        completionHandler(nil, false);
    }];
}

-(void) getMySalesWithCompletionHandler:(void (^)(BOOL, NSArray *))completionHandler{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *requestPayload = @{@"user_id": userId
                                     };
    
    [manager POST:kGetMySalesEndpoint parameters:requestPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"error"]){
            completionHandler(false, nil);
        }
        
        
        NSMutableArray *mySales = [[NSMutableArray alloc] init];
        
        for (NSDictionary *sale in responseObject) {
            Sale *mySale = [[Sale alloc] initSaleWithObjectId:sale[@"pk"]];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error");
        completionHandler(false, nil);
    }];
    
}
@end
