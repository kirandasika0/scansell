//
//  DescriptionViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 10/12/15.
//  Copyright © 2015 Burst. All rights reserved.
//

#import "DescriptionViewController.h"
#import "PhotosViewController.h"
#import "UITextView+Placeholder.h"
#import "ChooseCategoryViewController.h"

@interface DescriptionViewController ()

@end

@implementation DescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //hiding the back button
    self.navigationItem.hidesBackButton = NO;
    
    //hiding the descp view and price field for animation
    self.descpTextView.hidden = YES;
    self.priceField.hidden = YES;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //showing the descp and the price field through animation
    [UIView animateWithDuration:0.5 animations:^{
        if ([self.descpTextView isHidden] && [self.priceField isHidden]) {
            //looks like they are hidden show them on the view
            self.descpTextView.hidden = NO;
            self.priceField.hidden = NO;
        }
    }];
    self.descpTextView.placeholder = @"Book Description.";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)nextTapped:(id)sender {
    //check if the price and the description
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *description = [self.descpTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *price = [self.priceField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *selectedCategories = [userDefaults objectForKey:@"selected_categories"];
    if ([description length] > 10 && [price length] > 0 && [selectedCategories count] >= 1) {
        //we can move to the next view of clicking photos
        self.productDetails[@"descp"] = description;
        self.productDetails[@"price"] = price;
        self.productDetails[@"selected_categories"] = selectedCategories;
        [userDefaults removeObjectForKey:@"selected_categories"];
        [userDefaults synchronize];
        [self performSegueWithIdentifier:@"showPhotosView" sender:nil];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops." message:@"Looks like either did not type a description or did not set a price or select the book's category." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)chooseCategories:(id)sender {
    [self performSegueWithIdentifier:@"showChooseCategories" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"showPhotosView"]) {
        PhotosViewController *viewController = (PhotosViewController *)segue.destinationViewController;
        viewController.productDetails = self.productDetails;
    }
    
    if ([segue.identifier isEqualToString:@"showChooseCategories"]) {
        
    }
    
}
@end
