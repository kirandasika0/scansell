//
//  Notification.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 11/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NotificationType1 = 1,
    NotificationType2
} NotificationType;

@interface Notification : NSObject
@property (nonatomic, strong) NSString *notificationId;
@property (nonatomic, strong) NSString *sellerId;
@property (nonatomic, strong) NSString *sellerUsername;
@property (nonatomic, strong) NSString *saleId;
@property (nonatomic, strong) NSString *notifType;
@property (nonatomic, strong) NSDictionary *notifData;
@property (nonatomic, assign) NotificationType notificationType;

-(id)initWithNotificationId:(NSString *)notificationId;
@end
