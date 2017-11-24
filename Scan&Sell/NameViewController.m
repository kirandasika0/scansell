//
//  NameViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 08/12/15.
//  Copyright © 2015 Burst. All rights reserved.
//

#import "NameViewController.h"
#import "AFNetworking.h"
#import "DescriptionViewController.h"
#import "UITextView+Placeholder.h"

@interface NameViewController ()

@end

@implementation NameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //when the view loads then make sure that we are setting the back button hidden as we dont want the
    //user to go back
    self.productNameField.hidden = YES;
    
    //hide the back button so that user cannot quit uploading the product
    self.navigationItem.hidesBackButton = YES;
    
    self.productDetails = [[NSMutableDictionary alloc] init];
    
    //[self drawGradient];
}

-(void)drawGradient{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.bounds;
    
    gradientLayer.colors = @[(id)[UIColor purpleColor].CGColor, (id)[UIColor whiteColor].CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //show the product name field
    
    self.productNameField.placeholder = @"Book Name.";
    
    [UIView animateWithDuration:0.5 animations:^{
        if ([self.productNameField isHidden]) {
            //looks like productNameField is hidden show it on the screen with some animation
            self.productNameField.hidden = NO;
        }
    }];
    
    
    
    //sending reques to search upc to get the product details if available.
    
    NSString *upcUrl = [NSString stringWithFormat:@"http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=C4A45497-B6D0-4238-BEBF-4133CEDB4C21&upc=%@", self.barcodeNumber];
    
    NSURLRequest *upcRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:upcUrl]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [NSURLConnection sendAsynchronousRequest:upcRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data.length > 0) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSLog(@"%@", response);
            if ([response[@"0"][@"productname"] isEqualToString:@" "]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We're sorry." message:@"Looks like this barcode isn't registered on our servers. So please type in the book's name as it appears on the front cover." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
            if (!self.productDetails[@"product_name"]) {
                //self.productNameField.text = response[@"0"][@"productname"];
                //BOOL hasProductName = [response[@"0"][@"productname"] isEqualToString:@" "] == FALSE ? TRUE : FALSE;
                BOOL hasProductName = [response[@"0"][@"productname"] length] < 2 ? TRUE : FALSE;
                if (hasProductName) {
                    self.productNameField.text = response[@"0"][@"productname"];
                }
            }
            else{
                self.productNameField.text = self.productDetails[@"product_name"];
            }
            
            //hiding the network indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }
        else{
            NSLog(@"Looks like response did not come back.");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapNext:(id)sender {
    //next button has been tapped.
    //next view controller is the description and price view controller.
    //checking if the length of the text is greater than zero
    NSString *productName = [self.productNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([productName length] > 0) {
        //looks like the user has typed shit into the text field
        //we can pass this data to the next view controller
        self.productDetails[@"product_name"] = productName;
        self.productDetails[@"barcode_number"] = self.barcodeNumber;
        
        NSLog(@"%@", self.productDetails);
        
        [self performSegueWithIdentifier:@"showDescpView" sender:nil];
    }
    else{
        //sending alert for the user to type something into the box
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops." message:@"Looks like you did not type the product name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"showDescpView"]) {
        DescriptionViewController *destionationViewController = (DescriptionViewController *)segue.destinationViewController;
        destionationViewController.productDetails = self.productDetails;
    }
    
}

@end
