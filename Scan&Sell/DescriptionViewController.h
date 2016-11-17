//
//  DescriptionViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 10/12/15.
//  Copyright © 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionViewController : UIViewController

//properties
@property (nonatomic, strong) NSMutableDictionary *productDetails;


//iboutlets
@property (weak, nonatomic) IBOutlet UITextView *descpTextView;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;


//actions
- (IBAction)nextTapped:(id)sender;


@end
