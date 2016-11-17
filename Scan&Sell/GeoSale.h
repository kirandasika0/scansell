//
//  GeoSale.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 24/05/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "Sale.h"

@interface GeoSale : Sale
@property (nonatomic) double geoFenceRadius;

-(instancetype)initWithProductName:(NSString *)productName withProductId:(NSInteger)productId;
@end
