//
//  TypeOneViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 12/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "TypeOneViewController.h"
#import "AFNetworking.h"

@interface TypeOneViewController ()

@end

@implementation TypeOneViewController{
    PFUser *currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mainLabel.numberOfLines = 0;
}

-(void)viewWillAppear:(BOOL)animated{
    NSString *mainLabelString = [NSString stringWithFormat:@"%@\n\nBy Clicking comfirm in the below. You will exchange contact information with the buyer(like phone number, your name) for him to contact you.", self.notification.notifData[@"notification_string"]];
    self.mainLabel.text = mainLabelString;
    
    currentUser = [PFUser currentUser];
}

-(void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
    if (message) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}
//confirm ib action
- (IBAction)confirm:(id)sender {
    //looks like the seller wants to proceed with the sale.
    //creating notif type 2
    NSDictionary *notifType2Dict = @{@"notif_type": @2, @"seller_id":  currentUser.objectId, @"seller_username": currentUser.username, @"buyer_id": self.notification.notifData[@"buyer_id"], @"buyer_username": self.notification.notifData[@"buyer_username"], @"notif_1_id": self.notification.notificationId, @"sale_id": self.notification.saleId};
    NSLog(@"%@", notifType2Dict);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"https://scansell.herokuapp.com/sale/sale_notification/" parameters:notifType2Dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"response"] isEqualToString:@"true"]) {
            [self showAlertViewWithTitle:@"Success" andMessage:@"You have considerd the buyer's interest in your sale. You have now exchanged contact information and can contact the buyer from now on."];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
    }];
    
    
}
//reject ib action
- (IBAction)reject:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"notification_id": self.notification.notificationId};
    NSLog(@"%@", parameters);
    [manager POST:@"https://scansell.herokuapp.com/sale/delete_notification/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
    }];
}
@end
