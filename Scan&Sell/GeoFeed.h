//
//  GeoFeed.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 29/05/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

@interface GeoFeed : NSObject
@property (nonatomic, strong) NSString *saleId;
@property (nonatomic, strong) NSString *serverModelType;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *sellerId;
@property (nonatomic, strong) NSString *locationString;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *sellerUsername;
@property (nonatomic, strong) NSString *saleDescription;
@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSArray *thumbnailImageURL;
@property (nonatomic, strong) NSArray *fullSizeImageURL;
@property (nonatomic, strong) NSDate *createdAt;

-(instancetype) initWithSaleId:(NSString *)saleId andSellerId:(NSString *)sellerId;
+(void)getFeedFromServer: (void (^)(NSArray* feed, BOOL success))completionHandler;
-(NSString *) getSaleId;
-(Book*) getBook;
-(double)harversineKM;
-(double)haversineMI;
+(void) setFeedType:(NSString *)feedType;
@end
