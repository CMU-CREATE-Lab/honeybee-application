//
//  DeviceListViewController.h
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 17.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

//#import <UIKit/UIKit.h>

@import UIKit;
@import CoreBluetooth;

@class HoneybeeDetailViewController;

@interface DeviceListViewController : UITableViewController <CBCentralManagerDelegate>

@property (strong, nonatomic) HoneybeeDetailViewController *detailViewController;


@end

