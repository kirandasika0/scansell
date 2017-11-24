//
//  HomeViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 25/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeTableViewCell.h"
#import "DetailProductViewController.h"
#import "AFNetworking.h"
#import "RankFeed.h"
#import "GeoFeed.h"
#import "Book.h"
#import "User.h"
#import "HottestDealViewController.h"
#import "DetailPresentingAnimator.h"
#import "DetailDismissingAnimator.h"
#import <pop/POP.h>
#import "NSDate+NVTimeAgo.h"
#import <StoreKit/StoreKit.h>
#import "Proto/Feed.pbobjc.h"

@implementation HomeViewController{
    UITableView *autoCompleteTableView;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:nil action:@selector(fetchProductFeed:) forControlEvents:UIControlEventValueChanged];
    
    if (![[User sharedInstance] isActive]) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    else{
        NSLog(@"%@", [[User sharedInstance] username]);
        //[self fetchProductFeed];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchSliderFeed:) name:kInitialLocationConfirmation object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchProductFeed:) name:kInitialLocationConfirmation object:nil];
    }
    
    
    //setting the separator to none and then to line
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.ref = [[FIRDatabase database] reference];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:kNewBidReceived object:nil];
    [self askForReview];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 400.0;
    
    [self.tabBarController setHidesBottomBarWhenPushed:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.feedProducts count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Sale *sale = [self.feedProducts objectAtIndex:indexPath.row];
    cell.productNameLabel.text = sale.bookDetails[@"fields"][@"uniform_title"];
    
    NSString *distanceLabelString = [NSString stringWithFormat:@"🚕 %.2f mi",[sale haversineMI]];
    NSString *desciptionString;
    
    if (sale.bidData != nil) {
        desciptionString = [NSString stringWithFormat:@"Price: $%@\n\n%@\n\nCommon Locations: %@\n\n%@",
            sale.price,
            sale.saleDescription,
            sale.extraInfo,
            distanceLabelString
            ];
    }
    else{
        desciptionString = [NSString stringWithFormat:@"Price: $%@\n\n%@\n\nCommon Locations: %@\n\n%@", sale.price, sale.saleDescription,sale.extraInfo, distanceLabelString];
    }
    
    NSMutableAttributedString *attibutedDescriptionString = [[NSMutableAttributedString alloc] initWithString:desciptionString];
    NSString *boldString = @"Price: ";
    NSString *bolsString2 = @"Common Locations: ";
    NSRange boldRange = [desciptionString rangeOfString:boldString];
    NSRange boldRange2 = [desciptionString rangeOfString:bolsString2];
    NSRange boldRange3 = [desciptionString rangeOfString:distanceLabelString];
    [attibutedDescriptionString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15.0] range:boldRange];
    [attibutedDescriptionString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:boldRange2];
    [attibutedDescriptionString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:boldRange3];
    [cell.descriptionLabel setAttributedText:attibutedDescriptionString];
    
    
    return  cell;
    
}

-(NSArray *)leftUtility{
    NSMutableArray *leftUtilities = [NSMutableArray new];
    
    [leftUtilities sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"bid"]];
    
    return leftUtilities;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    FeedType selectedFeedType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selected_feed"] integerValue];
    
    switch (selectedFeedType) {
        case NormalFeed:
        {
            NSLog(@"sdfsd");
            Sale *sale = [self.feedProducts objectAtIndex:indexPath.row];
            self.tappedSale = sale;
            DetailProductViewController *detailProductViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailBookView"];
            detailProductViewController.transitioningDelegate = self;
            detailProductViewController.modalPresentationStyle = UIModalPresentationCustom;
            detailProductViewController.sale = self.tappedSale;
            [self.navigationController presentViewController:detailProductViewController animated:YES completion:nil];
        }
            break;
        case NearbyFeed:
            NSLog(@"fd");
            break;
    }
    
}



#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [DetailPresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DetailDismissingAnimator new];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    
    if ([segue.identifier isEqualToString:@"showDetailProduct"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        DetailProductViewController *viewController = (DetailProductViewController *)segue.destinationViewController;
        viewController.sale = self.tappedSale;
    }
}

-(void)fetchProductFeed:(NSNotification *)notification{
    //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"]);
    if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
        //Show the network indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    self.navigationItem.title = @"Loading...";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"user_id": [[User sharedInstance] userId]};
    [manager GET:@"https://scansell.herokuapp.com/sale/get_feed/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        NSMutableArray *salesArray = [[NSMutableArray alloc] init];
        //parse the json data here
        for (NSDictionary *product in responseObject[@"response"]) {
            //we are getting each individual product
            Sale *sale = [[Sale alloc] initWithUsername:product[@"seller_username"] andUserId:product[@"seller_id"]];
            [sale setFirebaseReference:self.ref];
            sale.sellerId = product[@"seller_id"];
            sale.sellerUsename = product[@"seller_username"];
            sale.saleId = product[@"id"];
            sale.extraInfo = product[@"extra_info"];
            sale.saleDescription = product[@"description"];
            sale.locationString = product[@"location"];
            sale.price = product[@"price"];
            sale.bidData = nil;
            
            //getting latitude and longitude
            double latitude = [product[@"latitude"] doubleValue];
            double longitude = [product[@"longitude"] doubleValue];
            
            //Setting the sale location
            sale.saleLocation = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
            
            //Setting book information
            sale.bookDetails = product[@"book"];
            
            //Getting all the images
            NSMutableArray *imageNames = [[NSMutableArray alloc]  init];
            for (NSDictionary *image in product[@"images"]) {
                [imageNames addObject:image[@"fields"][@"image_name"]];
            }
            sale.imagesNames = imageNames;
            [sale listenForBidUpdates];
            [salesArray addObject:sale];
        }
        //NSLog(@"%@", salesArray);
        //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"]);
        
        if ([salesArray count] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Yikes..." message:@"Looks like there are no books for sale in your area right now, this is a chance for you to sell your book or please come back and try again.\n-Team Scan&Sell" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        
        NSUserDefaults *forUserLocation = [NSUserDefaults standardUserDefaults];
        BOOL isUserCurrentPointExists = [forUserLocation objectForKey:@"user_current_point"] != nil ? TRUE : FALSE;
        
        if (isUserCurrentPointExists == TRUE) {
            //NSLog(@"%@", salesArray);
            NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"]);
            if ([salesArray count] != 0) {
                //set the array to the feedProducts
                //reload the table view
                self.feedProducts = salesArray;
                [self.tableView reloadData];
            }
        }
        else{
            [NSThread sleepForTimeInterval:1.0f];
            NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user_current_point"]);
            if (salesArray != 0) {
                self.feedProducts = salesArray;
                [self.tableView reloadData];
            }
        }
        
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
        if ([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            //Hide the network indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
        //Setting the navigation bar title back to Feed
        self.navigationItem.title = @"Feed";
        
        //Cheking the see the if app versions match from json data and local bundle version.
        if (![responseObject[@"current_app_version"] isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"has_seen_update_alert"] == nil) {
                //Show the alert view saying that they have to update the app
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Available" message:[NSString stringWithFormat:@"New version %@ available. Please update the app for smooth service.", responseObject[@"current_app_version"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                //cache this so that the app does not show this every time the user updates the app
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:@{@"has_seen_update_alert": @1} forKey:@"has_seen_update_alert"];
                [userDefaults synchronize];
            }
        }
        
        if ([responseObject[@"user_notifications_number"] integerValue] != 0) {
            [[[[[self tabBarController] tabBar] items]
              objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%@", responseObject[@"user_notifications_number"]]];
        }
        else{
            [[[[[self tabBarController] tabBar] items]
              objectAtIndex:2] setBadgeValue:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem with the network" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

-(void)fetchProtoFeed:(NSNotification *)notification {
    // New feed processing for protobufs
}

-(void) updateTableView{
    [self.tableView reloadData];
}

#pragma mark - Sales sort methods
-(void) sortSalesWithLeft:(int)left andRight:(int)right andSales:(NSArray *)sales{
    if (right <= left) {
        return;
    }
    int mid = (left + right) / 2;
    
    [self sortSalesWithLeft:left andRight:mid andSales:sales];
    
    [self sortSalesWithLeft:(mid + 1) andRight:right andSales:sales];
    
    
}



- (void) askForReview {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *today = [NSDate date];
    if ([userDefaults objectForKey:@"com.quicksell.extra.askForReview"] != nil) {
        if ([today compare:[userDefaults objectForKey:@"com.quicksell.extra.askForReview"]] == NSOrderedSame) {
            return;
        }
        else {
            //Ask for product review
            [userDefaults setObject:[NSDate date] forKey:@"com.quicksell.extra.askForReview"];
            [userDefaults synchronize];
        }
    }
    else {
        //ask for product review
        [userDefaults setObject:[NSDate date] forKey:@"com.quicksell.extra.askForReview"];
        [userDefaults synchronize];
        [SKStoreReviewController requestReview];
    }
}

- (IBAction)logout:(id)sender {
    //we are logging out the user
    [[User sharedInstance] logout];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
    
}
@end
