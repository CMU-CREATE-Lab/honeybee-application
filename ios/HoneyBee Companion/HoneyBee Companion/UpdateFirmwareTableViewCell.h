//
//  UpdateFirmwareTableViewCell.h
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 22.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HoneybeeBluetoothConnection;

@interface UpdateFirmwareTableViewCell : UITableViewCell

@property(weak) UIButton* updateButton;
@property(weak) IBOutlet UIProgressView* progressView;

@property(weak) UIViewController* viewController;

@property(strong) HoneybeeBluetoothConnection* honeybee;
@property(strong) void (^firmwareUpdateBlock)(void);

@end
