//
//  HBNetworkSetupViewController.h
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 12/11/18.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HoneybeeBluetoothConnection;

@interface HBNetworkSetupViewController : UITableViewController

@property(nonatomic, strong) HoneybeeBluetoothConnection* honeybee;
@property(nonatomic, strong) NSString* currentNetworkName;
@property(nonatomic, strong) NSDictionary* scannedNetworks;

@end

NS_ASSUME_NONNULL_END
