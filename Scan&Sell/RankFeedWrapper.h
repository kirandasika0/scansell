//
//  RankFeedWrapper.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 29/05/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RankFeed.h"

@interface RankFeedWrapper : NSObject
+(NSArray*) sortFeedForRank:(NSMutableArray*)feedPostsIn;
+(BOOL) syncStatsWithServer;
+(void) setUpPersistenceStore;
+(void) updateFeedHitsWithSaleId:(NSString*)saleId andHits:(int)nHits;
+(void) uninstallPersisteneceStore;
@end
