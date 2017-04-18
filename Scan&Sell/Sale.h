//
//  Sale.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 03/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
@import Firebase;

@interface Sale : NSObject
//Properties
@property (nonatomic, strong) NSString *saleId;
@property (nonatomic, strong) NSString *sellerId;
@property (nonatomic, strong) NSString *sellerUsename;
@property (nonatomic, strong) NSString *saleDescription;
@property (nonatomic, strong) PFGeoPoint *saleLocation;
@property (nonatomic, strong) NSString *extraInfo;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *locationString;
@property (nonatomic, strong) NSDictionary *bookDetails;
@property (nonatomic, strong) NSArray *imagesNames;
@property (nonatomic, strong) NSMutableDictionary *bidStructure;
@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (nonatomic, strong) NSDictionary *bidData;

//Methods
-(id)initWithUsername:(NSString *)username andUserId:(NSString*)userId;
-(double)harversineKM;
-(double)haversineMI;
-(BOOL) userHasBid;
-(BOOL) compareTo:(Sale *)that;
-(instancetype)initSaleWithObjectId:(NSString *)objectId;
-(void) placeBidWithBiddingPrice:(NSInteger)bidPrice andWithCompletionHandler:(void(^)(BOOL success))completionHandler;
-(void) getBidStatsWithCompletionHandler:(void(^)(BOOL success,NSDictionary *responseDictionary))completionHandler;
-(void) setFirebaseReference:(FIRDatabaseReference *)databaseRefenece;
- (BOOL) listenForBidUpdates;
- (void) getProductsAlikeFromServer:(void(^)(BOOL success, NSDictionary* responseDictionary))completionHandler;

//Class Methods
+(void) getSaleImagesWithId:(NSString *)saleIdIn andWithCompletionHandler:(void(^)(NSArray *images, BOOL success))completionHandler;

// CONSTANTS
extern NSString * const kGetSaleDetailsEndpoint;
extern NSString * const kGetSaleImagesEndpoint;
extern NSString * const kPlaceBidEndpoint;
extern NSString * const kGetBidStatsEndpoint;
extern NSString * const kNewBidUpdate;
extern NSString * const kNewBidReceived;
extern NSString * const kGetAlikeProducts;
@end
