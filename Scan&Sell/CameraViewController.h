//
//  CameraViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 25/06/15.
//  Copyright (c) 2015 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (strong) AVCaptureSession *captureSession;
@property (strong, nonatomic) NSString *barcodeNumber;
@property (strong, nonatomic) UIImageView *focusImageView;
@property (weak, nonatomic) IBOutlet UILabel *helperLabel;

@end
