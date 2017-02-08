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
NSString * const kPlaceBidEndpoint = @"https://scansell.herokuapp.com/sale/place_bid/";
NSString * const kGetBidStatsEndpoint = @"https://scansell.herokuapp.com/sale/bid_stats/";
NSString * const kNewBidUpdate = @"new_bid_update";
NSString * const kNewBidReceived = @"new_bid_received";

@implementation Sale
{
    NSUserDefaults *userDefaults;
}
-(id)initWithUsername:(NSString *)username andUserId:(NSString *)userId{
    self = [super init];
    if (self) {
        self.sellerUsename = username;
        self.sellerId = userId;
        userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults objectForKey:[[User sharedInstance] bidStructureKey]] != nil) {
            self.bidStructure = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:[[User sharedInstance] bidStructureKey]]];
        }
        else{
            self.bidStructure = [[NSMutableDictionary alloc] init];
        }
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

-(void) setFirebaseReference:(FIRDatabaseReference *)databaseRefenece{
    self.ref = databaseRefenece;
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

-(void)placeBidWithBiddingPrice:(NSInteger)bidPrice andWithCompletionHandler:(void (^)(BOOL))completionHandler{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *requestPayload = @{@"sale_id": self.saleId,
                                     @"bid_price": [NSString stringWithFormat:@"%ld", (long)bidPrice],
                                     @"user_id": [[User sharedInstance] userId]};
    [manager POST:kPlaceBidEndpoint parameters:requestPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self updateBidStats];
        NSLog(@"bid places");
        completionHandler(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(false);
        NSLog(@"%@", operation.responseString);
    }];
                                     
}

-(BOOL) userHasBid{
    for (id key in self.bidStructure) {
        if (self.saleId == key) {
            return true;
        }
    }
    return false;
}

-(void)getBidStatsWithCompletionHandler:(void (^)(BOOL, NSDictionary *))completionHandler{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *requestPayload = @{@"sale_id": self.saleId
                                     };
    [manager POST:kGetBidStatsEndpoint parameters:requestPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"error"]) {
            completionHandler(false, nil);
        }
        NSDictionary * responseDictionary = [[NSDictionary alloc] initWithDictionary:responseObject];
        completionHandler(true, responseDictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(false, nil);
    }];
    
}


-(BOOL) updateBidStats{
    [self.bidStructure setObject:self.saleId forKey:[NSString stringWithFormat:@"%d", true]];
    //saving the hash table to the cache
    [userDefaults setObject:self.bidStructure forKey:[[User sharedInstance] bidStructureKey]];
    return true;
}

- (BOOL) listenForBidUpdates{
    NSString *bidCacheKey = [NSString stringWithFormat:@"%@_bid", self.saleId];
    FIRDatabaseReference *bidRef = [[self.ref child:@"bid"] child:bidCacheKey];
    [bidRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.bidData = snapshot.value;
        NSLog(@"%@", self.bidData);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewBidReceived object:nil userInfo:nil];
    }];
    return true;
}
@end
