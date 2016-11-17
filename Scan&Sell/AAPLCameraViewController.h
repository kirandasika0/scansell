/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
View controller for camera interface.
*/

@import UIKit;


@interface AAPLCameraViewController : UIViewController

@property (nonatomic, strong) NSDictionary *tempSegueDictionary;
@property (nonatomic, strong) NSString *uniqueKey;
@property (weak, nonatomic) IBOutlet UILabel *purposeLabel;
- (IBAction)closeTakePhoto:(id)sender;
@end
