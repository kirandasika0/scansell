//
//  HottestDealViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 04/11/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "HottestDealViewController.h"


@interface HottestDealViewController ()
@property (weak, nonatomic) IBOutlet UILabel *saleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *saleImageView;

@end

@implementation HottestDealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.hottestSale.sellerUsename != nil) {
        self.saleNameLabel.text = self.hottestSale.sellerUsename;
        NSString *descriptionString = [NSString stringWithFormat:@"%@\n\nPrice: %@", self.hottestSale.saleDescription, self.hottestSale.price];
        self.descriptionLabel.text = descriptionString;
}
    
    [Sale getSaleImagesWithId:_hottestSale.saleId andWithCompletionHandler:^(NSArray *images, BOOL success) {
        if (success) {
            NSURL *imageNSURL = [NSURL URLWithString:images[0]];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                NSData *imageData = [NSData dataWithContentsOfURL:imageNSURL];
                if (imageData != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.saleImageView.image = [UIImage imageWithData:imageData];
                    });
                }
            });
        }
    }];
    
    
    
    //Set up a timer for 10 seconds
    [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(closeWindow) userInfo:nil repeats:NO];
}
     
-(void) closeWindow{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
