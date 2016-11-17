//
//  Notification.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 11/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "Notification.h"

@implementation Notification

-(id)initWithNotificationId:(NSString *)notificationId{
    self = [super init];
    if (self) {
        self.notificationId = notificationId;
    }
    
    return self;
}
@end
