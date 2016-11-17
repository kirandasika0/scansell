//
//  GeoFeed.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 29/05/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "GeoFeed.h"
#import "AFNetworking.h"
#import <Parse/Parse.h>

#define THUMBNAIL_ENDPOINT "http://burst.co.in/ss/thumbnails/80x80/"
#define FULL_SIZE_ENDPOINT "http://burst.co.in/ss/full_size/"
#define d2r (M_PI / 180.0)

@implementation GeoFeed

-(instancetype) initWithSaleId:(NSString *)saleId andSellerId:(NSString *)sellerId {
    self = [super init];
    
    if (self) {
        self.saleId = saleId;
        self.sellerId = sellerId;
        self.book = nil;
    }
    
    return self;
}


-(NSString *) getSaleId {
    return self.saleId;
}

-(Book*) getBook {
    return self.book;
}

+(void)getFeedFromServer:(void (^)(NSArray *, BOOL))completionHandler{
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"] [@"latitude"] doubleValue] == 0.0000) {
        completionHandler(nil, false);
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //Send request to the server
    NSDictionary *parameters = @{
                                 @"user_id": [[PFUser currentUser] objectId],
                                 @"lat": [[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"latitude"],
                                 @"long": [[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"longitude"]
                                };
    [manager GET:@"http://scansell.herokuapp.com/sale/geo_feed/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"%@", operation.request.URL.absoluteString);
        
        if ([responseObject count] == 0) {
            completionHandler(nil, false);
        }
        
        NSMutableArray *tempFeedArray = [[NSMutableArray alloc] init];
        for (NSDictionary* tempSale in responseObject) {
            GeoFeed *geoFeedSale = [[GeoFeed alloc] initWithSaleId:tempSale[@"pk"] andSellerId:tempSale[@"fields"][@"seller_id"]];
            geoFeedSale.serverModelType = tempSale[@"model"];
            geoFeedSale.locationString = tempSale[@"fields"][@"location"];
            geoFeedSale.price = tempSale[@"fields"][@"price"];
            geoFeedSale.sellerUsername = tempSale[@"fields"][@"seller_username"];
            geoFeedSale.saleDescription = tempSale[@"fields"][@"description"];
            geoFeedSale.createdAt = tempSale[@"fields"][@"created_at"];
            geoFeedSale.book = [[Book alloc] initWithResponseDictionary:tempSale[@"fields"][@"book"]];
            NSArray *coordinates = [tempSale[@"fields"][@"geo_point"] componentsSeparatedByString:@","];
            
            geoFeedSale.latitude = [[coordinates objectAtIndex:0] doubleValue];
            geoFeedSale.longitude = [[coordinates objectAtIndex:1] doubleValue];
            
            NSMutableArray *tempThumbailArray = [[NSMutableArray alloc] init];
            NSMutableArray *tempFullSizeArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary* image in tempSale[@"fields"][@"images"]) {
                NSString *imageUrl = [NSString stringWithFormat:@"%s%@", THUMBNAIL_ENDPOINT, image[@"fields"][@"image_name"]];
                NSString *fullSizeUrl = [NSString stringWithFormat:@"%s%@", FULL_SIZE_ENDPOINT, image[@"fields"][@"image_name"]];
                [tempThumbailArray addObject:imageUrl];
                [tempFullSizeArray addObject:fullSizeUrl];
            }
            
            geoFeedSale.thumbnailImageURL = tempThumbailArray;
            geoFeedSale.fullSizeImageURL = tempFullSizeArray;
            
            [tempFeedArray addObject:geoFeedSale];
        }
        NSArray *feedArray = [NSArray arrayWithArray:tempFeedArray];
        completionHandler(feedArray, true);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Looks like there is a problem getting the feed form the server.");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error." message:@"Looks like there is an error while getting data from the server. Please try later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        completionHandler(nil, false);
    }];
}



-(double)harversineKM{
    //Sale Coordinates
    double saleLat = self.latitude;
    double saleLong = self.longitude;
    
    //user coordinates
    double userLat = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"latitude"] doubleValue];
    double userLong = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"longitude"] doubleValue];
    
    double dLat = (userLat - saleLat) * d2r;
    double dLong = (userLong - saleLong) * d2r;
    
    double a = pow(sin(dLat / 2.0), 2) + cos(saleLat * d2r) * cos(userLat * d2r) * pow(sin(dLong / 2.0), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = 6367 * c;
    
    return d;
}
-(double)haversineMI{
    //Sale Coordinates
    double saleLat = self.latitude;
    double saleLong = self.longitude;
    
    //user coordinates
    double userLat = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"latitude"] doubleValue];
    double userLong = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"][@"longitude"] doubleValue];
    
    double dLat = (userLat - saleLat) * d2r;
    double dLong = (userLong - saleLong) * d2r;
    
    double a = pow(sin(dLat / 2.0), 2) + cos(saleLat * d2r) * cos(userLat * d2r) * pow(sin(dLong / 2.0), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = 3956 * c;
    
    return d;
}


+(void) setFeedType:(NSString *)feedType{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:feedType forKey:@"selected_feed"];
}
@end
