//
//  HoneyBeeBluetoothConnection.h
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 18.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

extern NSString* bleBeedanceServiceUUIDString;
extern NSString* bleBeedanceTxCharUUIDString;
extern NSString* bleBeedanceRxCharUUIDString;


@interface HoneybeeBluetoothConnection : NSObject  <CBPeripheralDelegate>

- (instancetype) initWithPeripheral: (CBPeripheral*) peripheral;


@property(strong) NSString* name;
@property(strong) NSString* wifiMacAddress;
@property(strong) NSString* bleMacAddress;
@property(strong) NSString* appVersion;
@property(strong) NSString* wifiVersion;
@property(strong) NSString* hardwareVersion;
@property(strong) NSString* serialNumber;

- (void) updateWifiFirmware: (void (^)(float progress, bool done, NSError* error)) progressBlock;

@end
