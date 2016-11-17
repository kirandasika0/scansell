//
//  SellBookViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 25/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import "SellBookViewController.h"
#import "UITextView+Placeholder.h"

@implementation SellBookViewController


-(void)viewDidload{
    [super viewDidLoad];
    
    self.descriptionField.delegate = self;
    
    
    self.testArray = [NSArray arrayWithObjects:@"LOL", @"LOL", @"LOL", nil];
    
    [self.autoCompleteTableView setHidden:YES];
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //showing network indicator symbol
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.currentUser = [PFUser currentUser];
    
    self.descriptionField.placeholder = @"Book Description.";
    
    
    if (self.barcodeNumber != 0) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=C4A45497-B6D0-4238-BEBF-4133CEDB4C21&upc=%@", self.barcodeNumber]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            [self.activityInd startAnimating];
            if (data.length > 0 && connectionError == nil) {
                NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                
                //NSLog(@"%@", greeting);
                
                NSLog(@"Product Details: %@", greeting[@"0"]);
                
                self.bookNameField.text = greeting[@"0"][@"productname"];
            
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:greeting[@"0"][@"imageurl"]]];
                    self.bookCoverImageData = imageData;
                    if (imageData != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *productImage = [UIImage imageWithData:imageData];
                            self.bookCoverImageView.image = productImage;
                            if ([self.activityInd isAnimating]) {
                                [self.activityInd stopAnimating];
                                [self.activityInd setHidden:YES];
                            }
                            //hiding the network indicator
                            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        });
                    }
                    else{
                        if ([self.activityInd isAnimating]) {
                            [self.activityInd stopAnimating];
                            [self.activityInd setHidden:YES];
                        }
                    }
                });
            }
        }];
     
        //setting the book name to the barcode number
    }
    
    //keep the autocomplete table view hidden
    //[self.autoCompleteTableView setHidden:YES];
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}


#pragma mark - Table View Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.testArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    cell.textLabel.text = [self.testArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)sell:(id)sender {
    //Upload all required to parse database
    //Check if all the things are there.
    
    if (self.bookNameField.text.length > 0 && self.authorField.text.length > 0 && self.sellingPriceField.text.length > 0 && self.descriptionField.text.length > 0 && self.bookCoverImageView.image != nil) {
        
        NSString *fileName = @"book_cover.png";
        UIImage *coverImage = [UIImage imageWithData:self.bookCoverImageData];
        NSData *fileData = UIImagePNGRepresentation(coverImage);
            
        PFFile *bookCoverFile = [PFFile fileWithName:fileName data:fileData];
        
        [bookCoverFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", [error.userInfo objectForKey:@"error"]);
            }
        }];
        
        
        
        
        PFObject *bookObject = [PFObject objectWithClassName:@"books"];
        bookObject[@"seller_id"] = self.currentUser.objectId;
        bookObject[@"barcode_number"] = self.barcodeNumber;
        bookObject[@"book_name"] = [self.bookNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        bookObject[@"book_author"] = [self.authorField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        bookObject[@"selling_price"] = [self.sellingPriceField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        bookObject[@"book_description"] = [self.descriptionField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        bookObject[@"book_cover"] = bookCoverFile;
        
        [bookObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self.tabBarController setSelectedIndex:0];
            }
            else{
                NSLog(@"Error: %@", [error.userInfo objectForKey:@"error"]);
            }
        }];
        
        
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like you did not type in everything" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    
}
@end
