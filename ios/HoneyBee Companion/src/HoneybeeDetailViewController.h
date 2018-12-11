//
//  DetailViewController.h
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 17.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HoneybeeBluetoothConnection;

@interface HoneybeeDetailViewController : UIViewController

@property (strong, nonatomic) HoneybeeBluetoothConnection *honeybee;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *wifiUpdateButton;
@property (weak, nonatomic) IBOutlet UIProgressView *wifiUpdateProgress;

- (IBAction) updateFirmwareAction:(id)sender;

@end

