//
//  NotificationViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 03/07/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Notification.h"

@interface NotificationViewController : UITableViewController


@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) Notification *selectedNotification;

@end
