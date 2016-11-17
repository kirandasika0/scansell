//
//  Sale.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 03/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "Sale.h"
#import "User.h"
#import "AFNetworking.h"

#define d2r (M_PI / 180.0)

NSString * const kGetSaleDetailsEndpoint = @"https://scansell.herokuapp.com/sale/get_sale_details/";
NSString * const kGetSaleImagesEndpoint = @"https://scansell.herokuapp.com/sale/get_sale_images/";

@implementation Sale
-(id)initWithUsername:(NSString *)username andUserId:(NSString *)userId{
    self = [super init];
    if (self) {
        self.sellerUsename = username;
        self.sellerId = userId;
    }
    
    return self;
}

-(instancetype)initSaleWithObjectId:(NSString *)objectId{
    self = [super init];
    if (self){
        self.saleId = objectId;
    }
    
    return self;
}

-(NSString *)debugDescription{
    return [NSString stringWithFormat:@"Sale: Username:%@ UserId:%@", self.sellerUsename, self.sellerId];
}

-(double)harversineKM{
    //Sale Coordinates
    double saleLat = self.saleLocation.latitude;
    double saleLong = self.saleLocation.longitude;
    
    //user coordinates
//    double userLat = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"latitude"] doubleValue];
//    double userLong = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"longitude"] doubleValue];
    
    double userLat = [[User sharedInstance] geoPoint].latitude;
    double userLong = [[User sharedInstance] geoPoint].longitude;
    
    double dLat = (userLat - saleLat) * d2r;
    double dLong = (userLong - saleLong) * d2r;
    
    double a = pow(sin(dLat / 2.0), 2) + cos(saleLat * d2r) * cos(userLat * d2r) * pow(sin(dLong / 2.0), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = 6367 * c;
    
    return d;
}
-(double)haversineMI{
    //Sale Coordinates
    double saleLat = self.saleLocation.latitude;
    double saleLong = self.saleLocation.longitude;
    
    //user coordinates
//    double userLat = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"latitude"] doubleValue];
//    double userLong = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"longitude"] doubleValue];
    
    double userLat = [[User sharedInstance] geoPoint].latitude;
    double userLong = [[User sharedInstance] geoPoint].longitude;
    
    double dLat = (userLat - saleLat) * d2r;
    double dLong = (userLong - saleLong) * d2r;
    
    double a = pow(sin(dLat / 2.0), 2) + cos(saleLat * d2r) * cos(userLat * d2r) * pow(sin(dLong / 2.0), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = 3956 * c;
    
    return d;
}


-(BOOL) compareTo:(Sale *)that{
    return [self haversineMI] > [that haversineMI];
}

-(void) getSaleData{
    // This method is only called when the initSaleWithObjectId constructor is called
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *requestPayload = @{@"id": self.saleId};
    [manager POST:kGetSaleDetailsEndpoint parameters:requestPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseObject = responseObject[@"fields"];
        self.sellerId = responseObject[@"seller_id"];
        self.sellerUsename = responseObject[@"seller_username"];
        self.saleDescription = responseObject[@"description"];
        self.price = responseObject[@"price"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
    }];
}

+(void) getSaleImagesWithId:(NSString *)saleIdIn andWithCompletionHandler:(void (^)(NSArray *, BOOL))completionHandler{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *requestPayload = @{@"sale_id": saleIdIn};
    [manager POST:kGetSaleImagesEndpoint parameters:requestPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSDictionary *image in responseObject) {
            NSString *imageURL = [NSString stringWithFormat:@"http://burst.co.in/ss/full_size/%@", image[@"fields"][@"image_name"]];
            [images addObject:imageURL];
        }
        completionHandler(images, true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(nil, false);
    }];
}
@end
