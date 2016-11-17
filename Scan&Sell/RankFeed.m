//
//  RankFeed.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 29/05/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "RankFeed.h"
#import "RankFeedWrapper.h"

@implementation RankFeed

-(instancetype) initWithSaleId:(NSString *)saleIdIn{
    self = [super init];
    
    if (self) {
        self.saleId = saleIdIn;
    }
    
    return self;
}

-(int) getnHits{
    return self.nHits;
}

-(BOOL) setnHits:(int)nHitsIn{
    BOOL flag = false;
    self.nHits = nHitsIn;
    
    if (self.nHits == nHitsIn) {
        flag = true;
    }

    return flag;
}

-(BOOL) incrementHits{
    BOOL flag = false;
    int tempHits = self.nHits;
    self.nHits += 1;
    
    if (self.nHits > tempHits) {
        flag = true;
    }
    
    [RankFeedWrapper updateFeedHitsWithSaleId:self.saleId andHits:self.nHits];
    return flag;
}



@end
