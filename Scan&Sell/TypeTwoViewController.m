//
//  TypeTwoViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 13/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "TypeTwoViewController.h"
#import "ChatViewController.h"

@interface TypeTwoViewController ()

@end

@implementation TypeTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *fullDescriptionString = [NSString stringWithFormat:@"%@\n\nUser Details\n\nUsername:%@\n\nEmail:%@\n\nPhone:%@\n\nPlease mention that you have found this book on Scan&Sell when you contact the seller about the book.\nThe app has already copied a default message to send to the buyer or seller when you want to message them. All you have to do is paste the message and send it.",self.notification.notifData[@"notification_string"],self.notification.notifData[@"user_data"][@"fields"][@"username"], self.notification.notifData[@"user_data"][@"fields"][@"email"],self.notification.notifData[@"user_data"][@"fields"][@"mobile_number"]];
    
    NSMutableAttributedString *descriptionAttributedString = [[NSMutableAttributedString alloc] initWithString:fullDescriptionString];
    
    [descriptionAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15.0f] range:[fullDescriptionString rangeOfString:self.notification.notifData[@"user_data"][@"fields"][@"username"]]];
    
    [descriptionAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15.0f] range:[fullDescriptionString rangeOfString:self.notification.notifData[@"user_data"][@"fields"][@"email"]]];
    
    [descriptionAttributedString addAttribute:NSLinkAttributeName value:[NSURL URLWithString:@"http://google.com"] range:[fullDescriptionString rangeOfString:self.notification.notifData[@"user_data"][@"fields"][@"mobile_number"]]];
    [self.notificationLabel setAttributedText:descriptionAttributedString];
}


- (IBAction)callBarButton:(id)sender {
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.notification.notifData[@"user_data"][@"fields"][@"mobile_number"]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    
}

- (IBAction)sendMessage:(id)sender {
    //Pushing new chat view controller
    [self performSegueWithIdentifier:@"showChatView" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showChatView"]) {
        ChatViewController *chatVC = (ChatViewController *)segue.destinationViewController;
        chatVC.notification = self.notification;
    }
}
@end
