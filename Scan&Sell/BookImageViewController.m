//
//  BookImageViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 11/01/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "BookImageViewController.h"
#import "AFNetworking.h"

@interface BookImageViewController ()

@end

@implementation BookImageViewController{
    int image_index;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    if (![self.activityInd isHidden]) {
        [self.activityInd setHidden:YES];
    }
    
    //Showing the alertview if user didn't see it
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"saw_book_image_view_dialog"] == NULL) {
        NSString *mesageString = @"Swipe left or right to view images and double tap on the screen to exit.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tip" message:mesageString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [userDefaults setObject:@{@"saw": @1} forKey:@"saw_book_image_view_dialog"];
        [userDefaults synchronize];
    }
    
    UITapGestureRecognizer *doubleTapToExit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBookImageView)];
    doubleTapToExit.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapToExit];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextImage)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousImage)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    
    [self getAndSetImageForIndex:0];
    image_index = 0;
    self.indexLabel.text = [NSString stringWithFormat:@"%d/3", image_index + 1];
}

-(void)previousImage{
    NSLog(@"previous");
    int temp_index = image_index - 1;
    if (temp_index >= 0) {
        [self getAndSetImageForIndex:temp_index];
        image_index = temp_index;
        self.indexLabel.text = [NSString stringWithFormat:@"%d/3", image_index + 1];
    }
    else{
        NSLog(@"not there");
    }
}

-(void)nextImage{
    NSLog(@"next");
    int temp_index = image_index + 1;
    if (temp_index < [self.saleImages count]) {
        [self getAndSetImageForIndex:temp_index];
        image_index = temp_index;
        self.indexLabel.text = [NSString stringWithFormat:@"%d/3", image_index + 1];
    }
    else{
        NSLog(@"not there");
    }
}

-(void)getAndSetImageForIndex:(int)index{
    if ([self.activityInd isHidden]) {
        [self.activityInd setHidden:NO];
    }
    if (![self.activityInd isAnimating]) {
        [self.activityInd startAnimating];
    }
    self.saleImageView.image = nil;
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://burst.co.in/ss/full_size/%@", self.saleImages[index]]];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        if (imageData != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.saleImageView.image = [UIImage imageWithData:imageData];
                if ([self.activityInd isAnimating]) {
                    [self.activityInd stopAnimating];
                }
                if (![self.activityInd isHidden]) {
                    [self.activityInd setHidden:YES];
                }
            });
        }
    });
}

-(void)closeBookImageView{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
@end
