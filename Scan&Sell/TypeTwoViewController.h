//
//  TypeTwoViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 13/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"
#import "User.h"

@interface TypeTwoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (nonatomic, strong) Notification *notification;
- (IBAction)callBarButton:(id)sender;
- (IBAction)sendMessage:(id)sender;

@end
