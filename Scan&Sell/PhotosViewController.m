//
//  PhotosViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 11/12/15.
//  Copyright © 2015 Burst. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoViewCell.h"
#import "SAMCache.h"
#import "UploadViewController.h"

@interface PhotosViewController ()

@end

@implementation PhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:NO];
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"%@", self.productDetails);
    self.tempSegueDictionary = [[NSDictionary alloc] init];
    
    
    
    
    //validating if an image for a certain key exsists every time the view loads
    
    //for front_cover
    if ([self.productDetails objectForKey:@"front_cover_image_key"] != nil) {
        //check if the image is there though samcache
        if ([[SAMCache sharedCache] imageForKey:self.productDetails[@"front_cover_image_key"]] == nil) {
            NSLog(@"The front cover image does't exist");
            //deleting the key from the product details
            [self.productDetails removeObjectForKey:@"front_cover_image_key"];
        }
    }
    
    //first_page
    if ([self.productDetails objectForKey:@"first_cover_image_key"] != nil) {
        //check if the image exists
        if (![[SAMCache sharedCache] imageExistsForKey:self.productDetails[@"first_cover_image_key"]]) {
            NSLog(@"The first page image doesn't exist. Gotta delete the key");
            //deleting the key and the null value
            [self.productDetails removeObjectForKey:@"first_cover_image_key"];
        }
    }
    
    //back_cover
    if ([self.productDetails objectForKey:@"back_cover_image_key"] != nil) {
        //check if the image exists
        if (![[SAMCache sharedCache] imageExistsForKey:self.productDetails[@"back_cover_image_key"]]) {
            NSLog(@"The back page image doesn't exist. Gotta delete the key and value");
            //deleting the key and the null value
            [self.productDetails removeObjectForKey:@"back_cover_image_key"];
        }
    }
    
    [[SAMCache sharedCache] removeObjectForKey:@"9D7A6A14-040D-4B56-AD71-BA118F2B5647-1793-0000017488ECB03B"];
    
    
    
    //logging the final product details for this session of display
    NSLog(@"%@", self.productDetails);
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.indexLabel.text = @"Front Cover Page.";
        //Set the front cover image if it's there
        if ([self.productDetails objectForKey:@"front_cover_image_key"] != nil) {
            //check if the image is there in cache
            if ([[SAMCache sharedCache] imageExistsForKey:self.productDetails[@"front_cover_image_key"]] == TRUE) {
                //setting the image to the image view
                cell.photoImageView.image = [[SAMCache sharedCache] imageForKey:[self.productDetails objectForKey:@"front_cover_image_key"]];
            }
        }
    }
    else if (indexPath.row == 1){
        cell.indexLabel.text = @"First Page.";
        //Setting the first page image if its there
        if ([self.productDetails objectForKey:@"first_cover_image_key"] != nil) {
            //check if the image is there
            if ([[SAMCache sharedCache] imageExistsForKey:self.productDetails[@"first_cover_image_key"]] == TRUE) {
                cell.photoImageView.image = [[SAMCache sharedCache] imageForKey:[self.productDetails objectForKey:@"first_cover_image_key"]];
            }
        }
    }
    else{
        cell.indexLabel.text = @"Back cover Page.";
        //setting the back cover if there
        if ([self.productDetails objectForKey:@"back_cover_image_key"] != nil) {
            if ([[SAMCache sharedCache] imageExistsForKey:self.productDetails[@"back_cover_image_key"]] == TRUE) {
                cell.photoImageView.image = [[SAMCache sharedCache] imageForKey:[self.productDetails objectForKey:@"back_cover_image_key"]];
            }
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row <= 3) {
        if (indexPath.row == 0) {
            //Set the temp segue dict to to the front cover and the unique if
            //should be set only once
            if ([self.productDetails objectForKey:@"front_cover_image_key"] == nil) {
                NSString *uniqueString = [NSProcessInfo processInfo].globallyUniqueString;
                self.tempSegueDictionary = @{@"purpose": @"Front Cover.", @"front_cover_image_key": uniqueString, @"purpose_s": @"front"};
                //updating the product details with the new details
                self.productDetails[@"front_cover_image_key"] = uniqueString;
            }
            //segue conditional
            if ([self.productDetails objectForKey:@"front_cover_image_key"] != nil) {
                //Getting the NSdata
                NSData *imageData = UIImageJPEGRepresentation([[SAMCache sharedCache] imageForKey:self.productDetails[@"front_cover_image_key"]], 0.7);
                NSLog(@"%@", imageData);
                
                if (imageData == nil) {
                    [self performSegueWithIdentifier:@"showTakePhotos" sender:nil];
                }
            }
        }
        else if (indexPath.row == 1){
            if ([self.productDetails objectForKey:@"first_cover_image_key"] == nil) {
                //creating the unique string
                NSString *uniqueString = [NSProcessInfo processInfo].globallyUniqueString;
                //setting the temp segue dict to the first page and the unique id
                self.tempSegueDictionary = @{@"purpose": @"First Page.", @"first_cover_image_key": uniqueString, @"purpose_s": @"first"};
                //updating the product details with the first page detail key
                self.productDetails[@"first_cover_image_key"] = uniqueString;
            }
            //segue conditional
            if ([self.productDetails objectForKey:@"first_cover_image_key"] != nil) {
                if (![[SAMCache sharedCache] imageExistsForKey:self.productDetails[@"first_cover_image_key"]]) {
                    [self performSegueWithIdentifier:@"showTakePhotos" sender:self];
                }
            }
        }
        else{
            if ([self.productDetails objectForKey:@"back_cover_image_key"] == nil) {
                //getting a new unique string for the back cover
                NSString *uniqueString = [NSProcessInfo processInfo].globallyUniqueString;
                self.tempSegueDictionary = @{@"purpose": @"Back Cover.", @"back_cover_image_key":uniqueString, @"purpose_s": @"back"};
                
                //updating the product details with the back cover details
                self.productDetails[@"back_cover_image_key"] = uniqueString;
            }
            
            //segue conditional
            if ([self.productDetails objectForKey:@"back_cover_image_key"] != nil) {
                if (![[SAMCache sharedCache] imageExistsForKey:self.productDetails[@"back_cover_image_key"]]) {
                    [self performSegueWithIdentifier:@"showTakePhotos" sender:self];
                }
            }
        }
    }
    else{
        NSLog(@"Looks like there is a problem with the indexpaths");
    }
}



#pragma mark - Upload View Navigation Clense
- (IBAction)nextTapped:(id)sender {
    //validate if all the information is there
    if ([self.productDetails objectForKey:@"front_cover_image_key"] != nil && [self.productDetails objectForKey:@"first_cover_image_key"] != nil && [self.productDetails objectForKey:@"back_cover_image_key"] != nil) {
        [self performSegueWithIdentifier:@"showUploadView" sender:self];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please take the images as it's a compulsary" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTakePhotos"]) {
        AAPLCameraViewController *viewController = (AAPLCameraViewController *)segue.destinationViewController;
        viewController.tempSegueDictionary = self.tempSegueDictionary;
    }
    
    if ([segue.identifier isEqualToString:@"showUploadView"]) {
        UploadViewController *viewController = (UploadViewController *)segue.destinationViewController;
        viewController.productDetails = self.productDetails;
    }
    
}
@end
