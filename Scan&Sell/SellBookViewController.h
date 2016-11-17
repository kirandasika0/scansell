//
//  SellBookViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 25/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SellBookViewController : UIViewController<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *barcodeNumber;
@property (weak, nonatomic) IBOutlet UITextView *bookNameField;
@property (weak, nonatomic) IBOutlet UIImageView *bookCoverImageView;
@property (weak, nonatomic) IBOutlet UITextField *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionField;
@property (weak, nonatomic) IBOutlet UITextField *authorField;
@property (weak, nonatomic) IBOutlet UITextField *sellingPriceField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityInd;

@property (nonatomic, strong) NSData *bookCoverImageData;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) IBOutlet UITableView *autoCompleteTableView;
@property (nonatomic, strong) NSArray *testArray;

- (IBAction)sell:(id)sender;

@end
