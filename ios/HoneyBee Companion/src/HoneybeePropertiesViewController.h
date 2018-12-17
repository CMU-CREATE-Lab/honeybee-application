//
//  HoneybeePropertiesViewControllerTableViewController.h
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 22.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HoneybeeBluetoothConnection;

@interface HoneybeePropertiesViewController : UITableViewController

@property(nonatomic, strong) HoneybeeBluetoothConnection* honeybee;

@end

