//
//  NameViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 08/12/15.
//  Copyright © 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NameViewController : UIViewController

//properties
//main property of product details that the user is going to type
@property (nonatomic, strong) NSMutableDictionary *productDetails;
@property (nonatomic, strong) NSString *barcodeNumber;

//IB Outlets
//@property (weak, nonatomic) IBOutlet UITextField *productNameField;
@property (weak, nonatomic) IBOutlet UITextView *productNameField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


//Actions
- (IBAction)tapNext:(id)sender;

@end
