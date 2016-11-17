//
//  RankFeed.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 29/05/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface RankFeed : NSObject

@property (nonatomic, strong) NSString *saleId;
@property (nonatomic, strong) NSString *sellerId;
@property (nonatomic, strong) NSString *sellerUsename;
@property (nonatomic, strong) NSString *saleDescription;
//@property (nonatomic, strong) PFGeoPoint *saleLocation;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *locationString;
@property (nonatomic) NSInteger bookId;
@property (nonatomic) int nHits;


//Instance methods
-(int) getnHits;
-(BOOL) setnHits:(int)nHitesIn;
-(instancetype) initWithSaleId:(NSString*)saleIdIn;
-(BOOL)incrementHits;
@end
