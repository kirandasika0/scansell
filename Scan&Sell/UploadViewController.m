//
//  UploadViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 18/12/15.
//  Copyright © 2015 Burst. All rights reserved.
//

#import "UploadViewController.h"
#import "AFNetworking.h"
#import "SAMCache.h"
#import "INTULocationManager.h"

@interface UploadViewController ()

@end

NSString * const kNewSaleEnpoint = @"https://scansell.herokuapp.com/sale/new_sale/";

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    //logging the product details
    NSLog(@"Product Details: %@", self.productDetails);
    
    self.productNameLabel.text = self.productDetails[@"product_name"];
    NSString *descpText = [NSString stringWithFormat:@"Price: $%@\n%@", self.productDetails[@"price"], self.productDetails[@"descp"]];
    self.descpLabel.text = descpText;
    
    UIImage *frontCoverImage = [UIImage imageWithData:[self createThumbnailForImage:[[SAMCache sharedCache] imageForKey:self.productDetails[@"front_cover_image_key"]] andForSize:@"60"]];
    self.frontCoverImageView.image = frontCoverImage;
    
    UIImage *firstCoverImage = [UIImage imageWithData:[self createThumbnailForImage:[[SAMCache sharedCache] imageForKey:self.productDetails[@"first_cover_image_key"]] andForSize:@"60"]];
    self.firstCoverImageView.image = firstCoverImage;
    
    UIImage *backCoverImage = [UIImage imageWithData:[self createThumbnailForImage:[[SAMCache sharedCache] imageForKey:self.productDetails[@"back_cover_image_key"]] andForSize:@"60"]];
    self.backCoverImageView.image = backCoverImage;
    
    if (![self.statusInfoLabel isHidden]) {
        [self.statusInfoLabel setHidden:YES];
    }
    
    //hide the activity ind
    if (![self.uploadActivityInd isHidden]) {
        [self.uploadActivityInd setHidden:YES];
    }
}

- (IBAction)upload:(id)sender {
    //Upload everything to the servers
    //Getting the GEO Location
    [UIView animateWithDuration:1.5 animations:^{
        if ([self.statusInfoLabel isHidden]) {
            [self.statusInfoLabel setHidden:NO];
        }
        self.statusInfoLabel.text = @"Locating you...";
        [self.uploadButton setEnabled:NO];
    }];
    
    [UIView animateWithDuration:3.5 animations:^{
        if (![self.uploadButton isHidden]) {
            [self.uploadButton setHidden:YES];
        }
    }];
    
    INTULocationManager *locManager = [INTULocationManager sharedInstance];
    [locManager requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        //Getting the latitude
        NSString *latitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
        //Getting the logitude
        NSString *longitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
        
        //Starting the data upload script
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //getting the location
        NSDictionary *locationParameters = @{@"latitude": latitude, @"longitude": longitude};
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [manager POST:@"https://scansell.herokuapp.com/sale/create_locale/" parameters:locationParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Your Live at: %@", responseObject[@"response"]);
            
            NSString *location = responseObject[@"response"];
            
            
            
            //picture file names
            NSString *frontCoverImageFileName = [NSString stringWithFormat:@"%@.jpg", self.productDetails[@"front_cover_image_key"]];
            NSString *firstCoverImageFileName = [NSString stringWithFormat:@"%@.jpg", self.productDetails[@"first_cover_image_key"]];
            NSString *backCoverImageFileName = [NSString stringWithFormat:@"%@.jpg", self.productDetails[@"back_cover_image_key"]];
            
            
            
            NSDictionary *parameters = @{@"seller_id": [[User sharedInstance] userId], @"seller_username": [[User sharedInstance] username],
                                         @"book_id": @0, @"description": self.productDetails[@"descp"], @"price":self.productDetails[@"price"],
                                         @"barcode_number": self.productDetails[@"barcode_number"],
                                         @"location": location, @"front_cover_image": frontCoverImageFileName,
                                         @"first_cover_image": firstCoverImageFileName, @"back_cover_image": backCoverImageFileName,
                                         @"full_title": self.productDetails[@"product_name"],
                                         @"uniform_title": self.productDetails[@"product_name"],
                                         @"selected_categories": self.productDetails[@"selected_categories"],
                                         @"latitude": latitude,
                                         @"longitude": longitude};
            
            
            NSLog(@"Main upload dictionary: %@", parameters);
            self.statusInfoLabel.text = @"Uploading Data...";
            [self uploadDataWithPayload:parameters andCompletionHandler:^(BOOL success) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }];
            
            
            
            
            
            [[SAMCache sharedCache] removeObjectForKey:self.productDetails[@"front_cover_image_key"]];
            [[SAMCache sharedCache] removeObjectForKey:self.productDetails[@"first_cover_image_key"]];
            [[SAMCache sharedCache] removeObjectForKey:self.productDetails[@"back_cover_image_key"]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];

    }];
    
}

-(NSData *)createThumbnailForImage:(UIImage *)originalImage andForSize:(NSString *)size{
    CGSize destinationSize;
    if ([size isEqualToString:@"30"]) {
        //30x30
        destinationSize = CGSizeMake(30.0f, 30.0f);
    }
    if ([size isEqualToString:@"60"]) {
        destinationSize = CGSizeMake(60.0f, 60.f);
    }
    if ([size isEqualToString:@"80"]) {
        destinationSize = CGSizeMake(80.0f, 80.f);
    }
    
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImageJPEGRepresentation(thumbnail, 1.0f);
}
-(void)uploadImageAndReturnValue:(NSDictionary *)images{
    for (NSString *key in images.allKeys) {
        if ([key isEqualToString:@"full_size"]) {
           //this is the upload script for the full_size image of any of it
            
        }
    }
}


-(void)uploadPictureForGivenResolution:(NSString *)size{
    //picture file name
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if ([size isEqualToString:@"front"]) {
        NSData *imageData = UIImageJPEGRepresentation([[SAMCache sharedCache] imageForKey:self.productDetails[@"front_cover_image_key"]], 1.0);
        NSDictionary *parDict = @{@"front_cover_image_name": self.productDetails[@"front_cover_image_key"]};
        AFHTTPRequestOperation *op = [manager POST:@"http://burst.co.in/ss/new_upload_pictures.php" parameters:parDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"front_cover_image" fileName:@"front_cover_image.jpg" mimeType:@"image/jpg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [op start];
    }
    
    if ([size isEqualToString:@"first"]) {
        NSData *imageData = UIImageJPEGRepresentation([[SAMCache sharedCache] imageForKey:self.productDetails[@"first_cover_image_key"]], 1.0);
        NSDictionary *params = @{@"first_cover_image_name": self.productDetails[@"first_cover_image_key"]};
        AFHTTPRequestOperation *op = [manager POST:@"http://burst.co.in/ss/new_upload_pictures.php" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"first_cover_image" fileName:@"first_cover_image.jpg" mimeType:@"imgae/jpg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [op start];
    }
    
    if ([size isEqualToString:@"back"]) {
        NSData *imageData = UIImageJPEGRepresentation([[SAMCache sharedCache] imageForKey:self.productDetails[@"back_cover_image_key"]], 1.0);
        NSDictionary *params = @{@"back_cover_image_name": self.productDetails[@"back_cover_image_key"]};
        AFHTTPRequestOperation *op = [manager POST:@"http://burst.co.in/ss/new_upload_pictures.php" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"back_cover_image" fileName:@"back_cover_image.jpg" mimeType:@"image/jpg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [op start];
    }
}


-(void)uploadPhotos{
    //show the upload activity ind
    [UIView animateWithDuration:1.5 animations:^{
        if ([self.uploadActivityInd isHidden]) {
            [self.uploadActivityInd setHidden:NO];
        }
    }];
    //large upload script as we are uploading the full quality images of all the images
    //initing the upload manager
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //Main upload picture method
    //Getting the image data of all the images
    NSData *frontCoverImageData = UIImageJPEGRepresentation([[SAMCache sharedCache] imageForKey:self.productDetails[@"front_cover_image_key"]], 1.0);
    NSData *firstCoverImageData = UIImageJPEGRepresentation([[SAMCache sharedCache] imageForKey:self.productDetails[@"first_cover_image_key"]], 1.0);
    NSData *backCoverImageData = UIImageJPEGRepresentation([[SAMCache sharedCache] imageForKey:self.productDetails[@"back_cover_image_key"]], 1.0);
    
    //picture upload request parameters
    NSString *frontCoverImageName = [NSString stringWithFormat:@"%@.jpg", self.productDetails[@"front_cover_image_key"]];
    NSString *firstCoverImageName = [NSString stringWithFormat:@"%@.jpg", self.productDetails[@"first_cover_image_key"]];
    NSString *backCoverImageName = [NSString stringWithFormat:@"%@.jpg", self.productDetails[@"back_cover_image_key"]];
    
    //showing the network indicator if its not there
    if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    //start the activity ind
    if (![self.uploadActivityInd isAnimating]) {
        [self.uploadActivityInd startAnimating];
    }
    AFHTTPRequestOperation *operation = [manager POST:@"http://burst.co.in/ss/new_upload_pictures.php" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //appending front cover image
        [formData appendPartWithFileData:frontCoverImageData name:@"front_cover_image" fileName:frontCoverImageName mimeType:@"image/jpg"];
        //appending first cover image
        [formData appendPartWithFileData:firstCoverImageData name:@"first_cover_image" fileName:firstCoverImageName mimeType:@"image/jpg"];
        //appending back cover image
        [formData appendPartWithFileData:backCoverImageData name:@"back_cover_image" fileName:backCoverImageName mimeType:@"image/jpg"];
        
        NSLog(@"Uploading");
        self.statusInfoLabel.text = @"Uploading Images...";
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Full Size Sucess: %@", responseObject);
        //hiding the network indicator if its visible
        if ([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        if ([self.uploadActivityInd isAnimating]) {
            [self.uploadActivityInd stopAnimating];
        }
        //go back to the main view
        [self.tabBarController setSelectedIndex:0];
        [self.navigationController popToRootViewControllerAnimated:YES];
        //NSLog(@"%@", operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"%@", operation.responseString);
        //hiding the network indicator
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.tabBarController setSelectedIndex:0];
    }];
    
    //starting operation
    [operation start];
}


-(void)uploadThumbnails{
    //Upload manager
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //Creating thumbnails
    NSData *frontCoverImageThumb = [self createThumbnailForImage:[[SAMCache sharedCache] imageForKey:self.productDetails[@"front_cover_image_key"]] andForSize:@"80"];
    NSData *firstCoverImageThumb = [self createThumbnailForImage:[[SAMCache sharedCache] imageForKey:self.productDetails[@"first_cover_image_key"]] andForSize:@"80"];
    NSData *backCoverImageThumb = [self createThumbnailForImage:[[SAMCache sharedCache] imageForKey:self.productDetails[@"back_cover_image_key"]] andForSize:@"80"];
    
    //thumbmails name string format
    NSString *frontCoverImageThumbName = [NSString stringWithFormat:@"%@.jpg", self.productDetails[@"front_cover_image_key"]];
    NSString *firstCoverImageThumbName = [NSString stringWithFormat:@"%@.jpg", self.productDetails[@"first_cover_image_key"]];
    NSString *backCoverImageThumbName = [NSString stringWithFormat:@"%@.jpg", self.productDetails[@"back_cover_image_key"]];
    
    
    if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
        //show the network indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    AFHTTPRequestOperation *thumbNailUploadOperation = [manager POST:@"http://burst.co.in/ss/upload_thumbnails.php" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //appending front cover image thumbnail
        [formData appendPartWithFileData:frontCoverImageThumb name:@"front_cover_image" fileName:frontCoverImageThumbName mimeType:@"image/jpg"];
        //appending first cover image thumbnail
        [formData appendPartWithFileData:firstCoverImageThumb name:@"first_cover_image" fileName:firstCoverImageThumbName mimeType:@"image/jpg"];
        //appending back cover image thumbnail
        [formData appendPartWithFileData:backCoverImageThumb name:@"back_cover_image" fileName:backCoverImageThumbName mimeType:@"image/jpg"];
        self.statusInfoLabel.text = @"Uploading Thumbnails...";
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        //NSLog(@"%@", operation.responseString);
        if ([responseObject[@"response"] isEqualToString:@"true"]) {
            NSLog(@"Thumbnail is uploaded");
            if ([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
                //hide network indicator
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
            if ([responseObject[@"response"] isEqualToString:@"true"]) {
                //all images have been uploaded
                self.statusInfoLabel.text = @"Book Published.";
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"%@", operation.responseString);
    }];
    //start operation
    [thumbNailUploadOperation start];
}



-(void) uploadDataWithPayload:(NSDictionary *)requestPayload andCompletionHandler:(void(^)(BOOL success))completionHandler{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:kNewSaleEnpoint parameters:requestPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
        //upload pictures
        //using the upload pictures method
        [self uploadPhotos];
        [self uploadThumbnails];
        completionHandler(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
        [self uploadPhotos];
        [self uploadThumbnails];
        completionHandler(false);
    }];
}
@end
