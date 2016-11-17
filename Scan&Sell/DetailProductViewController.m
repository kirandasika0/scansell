//
//  DetailProductViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 26/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import "DetailProductViewController.h"
#import "AFNetworking.h"
#import "BookImageViewController.h"

@implementation DetailProductViewController
-(void)viewDidLoad{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //current user
    self.currentUser = [PFUser currentUser];
    //Set the product name
    self.productNameLabel.text = self.sale.bookDetails[@"fields"][@"uniform_title"];
    //setting the description
    self.descriptionLabel.text = self.sale.saleDescription;
    //load the image
    NSURL *coverImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://burst.co.in/ss/full_size/%@", self.sale.imagesNames[0]]];
    //animate the activity indicator
    if (![self.activtityInd isAnimating]) {
        [self.activtityInd startAnimating];
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *coverImageData = [NSData dataWithContentsOfURL:coverImageURL];
        if (coverImageData != nil) {
           dispatch_async(dispatch_get_main_queue(), ^{
               self.bookCoverImageView.image = [UIImage imageWithData:coverImageData];
               if ([self.activtityInd isAnimating]) {
                   [self.activtityInd stopAnimating];
               }
               if (![self.activtityInd isHidden]) {
                   [self.activtityInd setHidden:YES];
               }
           });
        }
    });
    
    [self.buyButton setTitle:[NSString stringWithFormat:@"Buy Now for $%@", self.sale.price] forState:UIControlStateNormal];
}
- (IBAction)buy:(id)sender {
    //disable the button
    if ([self.buyButton isEnabled]) {
        [self.buyButton setEnabled:NO];
    }
    NSDictionary *notifDict = @{@"notif_type": @1, @"seller_id": self.sale.sellerId, @"seller_username": self.sale.sellerUsename,
                                @"buyer_id":self.currentUser.objectId, @"buyer_username": self.currentUser.username,
                                @"sale_id":self.sale.saleId};
    //creating manager
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"https://scansell.herokuapp.com/sale/sale_notification/" parameters:notifDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"response"] isEqualToString:@"true"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Yay!" message:@"The seller has been notified about your internest in his book. Seller's contact information will be available once he accpets your interest in his book" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Yikes." message:@"Looks like there was a problem please come back later and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
    }];
}

- (IBAction)showBookImages:(id)sender {
    [self performSegueWithIdentifier:@"showBookImage" sender:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showBookImage"]) {
        BookImageViewController *viewController = (BookImageViewController *)segue.destinationViewController;
        viewController.saleImages = self.sale.imagesNames;
    }
}
@end
