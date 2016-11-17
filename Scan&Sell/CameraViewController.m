//
//  CameraViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 25/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import "CameraViewController.h"
#import "SellBookViewController.h"
#import "AFNetworking.h"

@implementation CameraViewController



-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *vedioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:vedioCaptureDevice error:&error];
    
    if (videoInput) {
        [self.captureSession addInput:videoInput];
    }
    else{
        NSLog(@"Error: %@", error);
    }
    
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:metadataOutput];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code]];
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    previewLayer.frame = self.view.layer.bounds;
    [self.view.layer addSublayer:previewLayer];
    
    [self.captureSession startRunning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
     self.tabBarController.tabBar.hidden = YES;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (self.captureSession == NO) {
        [self.captureSession startRunning];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"saw_scan_barcode_dialog"] == NULL) {
        NSString *messageString = @"Scan a BOOK'S barcode to get started with your sale or Swipe up for more options.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tip" message:messageString delegate:nil cancelButtonTitle:@"I, Understand." otherButtonTitles: nil];
        [alertView show];
        [userDefaults setObject:@{@"saw": @1} forKey:@"saw_scan_barcode_dialog"];
        [userDefaults synchronize];
    }
    
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showTabBar)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:upSwipe];
}

-(void)showTabBar{
    [UIView animateWithDuration:2.5 animations:^{
        if ([self.tabBarController.tabBar isHidden]) {
            [self.tabBarController.tabBar setHidden:NO];
        }
        else{
            [self.tabBarController.tabBar setHidden:YES];
        }
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
}

#pragma mark AVCaptureMetadataOuputObjectsDelegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    [self.captureSession stopRunning];
    
    for(AVMetadataObject *metadataObject in metadataObjects)
    {
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
        if([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSLog(@"QR Code = %@", readableObject.stringValue);
        }
        else if ([metadataObject.type isEqualToString:AVMetadataObjectTypeEAN13Code])
        {
            NSLog(@"EAN 13 = %@", readableObject.stringValue);
            if (readableObject.stringValue.length > 0) {
                self.barcodeNumber = readableObject.stringValue;
                //perform segue to the sell book view controller
                [self performSegueWithIdentifier:@"showSellBook" sender:self];
                
                }
            else
                NSLog(@"There was a problem.");
        }
    }
    
    
}


#pragma mark - Navigation Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showSellBook"]) {
        SellBookViewController *viewController = (SellBookViewController *)segue.destinationViewController;
        viewController.barcodeNumber = self.barcodeNumber;
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
}

#pragma - Touch Delegates
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    NSLog(@"x: %f, y: %f", location.x, location.y);
    
    //set the focus image here
    UIImage *focusImage = [UIImage imageNamed:@"focus"];
    self.focusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(location.x, location.y, focusImage.size.width, focusImage.size.height)];
    self.focusImageView.image = focusImage;
    [self.view addSubview:self.focusImageView];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(removeFocusImageViewFromSuperView) userInfo:nil repeats:NO];
}

-(void)removeFocusImageViewFromSuperView{
    [self.focusImageView removeFromSuperview];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
