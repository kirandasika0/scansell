//
//  NotificationViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 03/07/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationCell.h"
#import "AFNetworking.h"
#import "TypeOneViewController.h"
#import "TypeTwoViewController.h"

@interface NotificationViewController ()
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //not doing anything in the view did load method so that views updates when ever
    //view appears on the screen.
    self.notifications = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //never hide the tab bar
    self.tabBarController.tabBar.hidden = NO;
    //setting the current user
    self.currentUser = [PFUser currentUser];
    
    //fething all notifications
    [self fetchNotification];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
    
    //nice ease in animation has to be placed here to make sure the loading is smooth.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.notifications count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Notification *notification = [self.notifications objectAtIndex:indexPath.row];
    
    cell.notifTextLabel.text = notification.notifData[@"notification_string"];
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Notification *selectedNotification = [self.notifications objectAtIndex:indexPath.row];
    switch (selectedNotification.notificationType) {
        case NotificationType1:
            self.selectedNotification = selectedNotification;
            [self performSegueWithIdentifier:@"showNotType1" sender:nil];
            break;
        case NotificationType2:
            self.selectedNotification = selectedNotification;
            [self performSegueWithIdentifier:@"showNotType2" sender:nil];
            break;
        default:
            NSLog(@"Invalid notification type");
            break;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Notification *notification = [self.notifications objectAtIndex:indexPath.row];
    switch (notification.notificationType) {
        case NotificationType1:
            return NO;
            break;
        case NotificationType2:
            return YES;
            break;
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    Notification *notification = [self.notifications objectAtIndex:indexPath.row];
    if ([notification.notifType intValue] == 2) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self.notifications removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self deleteNotificationWithId:notification.notificationId];
        }
        else{
            NSLog(@"Unhandled edit style");
        }
    }
}

-(void)fetchNotification{
    PFUser *currentUser = [PFUser currentUser];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"user_id": currentUser.objectId};
    
    [manager GET:@"https://scansell.herokuapp.com/sale/get_notifications/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //If no notifications are there this alert view will be displayed
        if (responseObject[@"response"] == nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoa!" message:@"Looks like you have no notifications pending that have to be viewed. Please come back here later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        NSMutableArray *feedProductArray = [[NSMutableArray alloc] init];
        for (NSDictionary *notification in responseObject[@"response"]) {
            Notification *notificationObj = [[Notification alloc] initWithNotificationId:notification[@"id"]];
            notificationObj.sellerId = notification[@"user_id"];
            notificationObj.sellerUsername = notification[@"username"];
            notificationObj.saleId= notification[@"sale_id"];
            notificationObj.notifType = notification[@"notif_type"];
            NotificationType notificationType = [notification[@"notif_type"] intValue];
            notificationObj.notificationType = notificationType;
            notificationObj.notifData = notification[@"data"];
            
            [feedProductArray addObject:notificationObj];
        }
        self.notifications = feedProductArray;
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showNotType1"]) {
        TypeOneViewController *viewController = (TypeOneViewController *)segue.destinationViewController;
        viewController.notification = self.selectedNotification;
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    if ([segue.identifier isEqualToString:@"showNotType2"]) {
        TypeTwoViewController *viewController = (TypeTwoViewController *)segue.destinationViewController;
        viewController.notification = self.selectedNotification;
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
}

-(void)deleteNotificationWithId:(NSString *)notificationId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"notification_id": notificationId};
    NSLog(@"%@", parameters);
    [manager POST:@"https://scansell.herokuapp.com/sale/delete_notification/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
    }];
}
@end
