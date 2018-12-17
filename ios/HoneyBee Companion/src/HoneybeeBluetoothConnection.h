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
@property(strong) NSString* sblVersion;
@property(strong) NSString* wifiVersion;
@property(strong) NSString* hardwareVersion;
@property(strong) NSString* serialNumber;

@property(nonatomic, readonly) CBPeripheral* peripheral;


- (void) getNetworkStatus: (void (^)(NSDictionary* statusDict, NSError* error)) responseCallback;
- (void) requestWifiScan: (void (^)(NSDictionary* network, NSError* error)) responseCallback;
- (void) joinNetwork: (NSDictionary*) network;

- (void) cancelFirmwareUpdate;
//- (void) updateWifiFirmware: (void (^)(float progress, bool done, NSError* error)) progressBlock;

- (void) uploadFirmware: (NSData*) binData forDestination: (size_t) fwDestination progess: (void (^)(float progress, bool done, NSError* error)) progressBlock;

//- (NSString*) honeyBeeApplImageVersion;

@end
