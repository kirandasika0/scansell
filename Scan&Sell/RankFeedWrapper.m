//
//  RankFeedWrapper.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 29/05/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "RankFeedWrapper.h"
#import "RankFeed.h"

@implementation RankFeedWrapper

+(NSArray*) sortFeedForRank:(NSMutableArray *)feedPostsIn{
    NSArray *sortedPosts;
    
    sortedPosts = [feedPostsIn sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger first = [(RankFeed*)obj1 nHits];
        NSInteger second = [(RankFeed*)obj2 nHits];
        
        if (first < second) {
            return NSOrderedAscending;
        }
        else if (first > second) {
            return NSOrderedDescending;
        }
        else{
            return NSOrderedSame;
        }
        
    }];
    
    return sortedPosts;
}

+(BOOL) syncStatsWithServer {
    __block BOOL flag = false;
    
    return flag;
}

+(void) setUpPersistenceStore{
    //This static function will set up the NSUserdefaults for the session of the app
    //creating the standard user defaults
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *standardStatsDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@{}, @"hits_stats", nil];
    
    [userDef setObject:standardStatsDict forKey:@"hits_stats"];
    
    [userDef synchronize];
}

+(NSMutableDictionary*) loadDataFromPersistenceStore{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dictFromStore = [userDefaults dictionaryForKey:@"hits_stats"];
    NSMutableDictionary *returnDict = [NSMutableDictionary dictionaryWithDictionary:dictFromStore];
    
    NSLog(@"%@", dictFromStore);
    
    return returnDict;
}

+(void) updateRankFeedHitsWithSaleId:(NSString*)saleId andHits:(int)nHits {
    //check for a certain rank feed object in the store and update it with the new value
    
    NSMutableDictionary *rankHits = [self loadDataFromPersistenceStore][@"hits_stats"];
    
    NSString *hits = [NSString stringWithFormat:@"%d", nHits];
    [rankHits setObject:hits forKey:saleId];
    
    [self saveDataToPersistenceStore:rankHits];
    
}

+(BOOL) saveDataToPersistenceStore:(NSMutableDictionary*)hitsDict{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *storeDict = @{@"hits_stats": hitsDict};
    [userDefaults setObject:storeDict forKey:@"hits_stats"];
    return [userDefaults synchronize];
}

+(void) uninstallPersisteneceStore{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hits_stats"];
}

@end