//
//  ViewController.m
//  Honeybee Wifi Config
//
//  Created by Dömötör Gulyás on 05.10.2017.
//  Copyright © 2017 CMU Create Lab. All rights reserved.
//

#import "ViewController.h"
#import "NetworkDialogViewController.h"
@import CoreBluetooth;

#include <SystemConfiguration/CaptiveNetwork.h>
#include <NetworkExtension/NEHotspotHelper.h>


/*
 service	"6e400001-b5a3-f393-e0a9-e50e24dcca9e");
 tx			"6e400002-b5a3-f393-e0a9-e50e24dcca9e");
 rx			"6e400003-b5a3-f393-e0a9-e50e24dcca9e");
 GATT descriptor 00002902-0000-1000-8000-00805f9b34fb
 */


//NSString* bleSerialUUID = @"0B87F717-9105-0C87-EA1D-EF6922DE26AF";
NSString* bleUartServiceUUID = @"6e400001-b5a3-f393-e0a9-e50e24dcca9e";

#define BLE_DEVICE_SERVICE_UUID			"6e400001-b5a3-f393-e0a9-e50e24dcca9e"

//#define BLE_DEVICE_VENDOR_NAME_UUID		"713D0001-503E-4C75-BA94-3148F18D941E"

#define BLE_DEVICE_RX_UUID				"6e400003-b5a3-f393-e0a9-e50e24dcca9e"
#define BLE_DEVICE_RX_READ_LEN			20

#define BLE_DEVICE_TX_UUID				"6e400002-b5a3-f393-e0a9-e50e24dcca9e"
#define BLE_DEVICE_TX_WRITE_LEN			20

//#define BLE_DEVICE_RESET_RX_UUID		"713D0004-503E-4C75-BA94-3148F18D941E"

//#define BLE_DEVICE_LIB_VERSION_UUID		"713D0005-503E-4C75-BA94-3148F18D941E"

@interface CBUUID (Private)

- (NSString*) toString;

@end


@implementation CBUUID (Private)

- (NSString*) toString
{
	return CFBridgingRelease(CFUUIDCreateString(NULL, (CFUUIDRef) self));
	
}


@end


@interface ViewController ()

@property(strong, nonatomic) CBPeripheral* bleUart;

-(void) writeBleUart:(NSData *)d;

@end

@implementation ViewController
{
	CBCentralManager*	bleManager;
	
	NSMutableArray*		bleDevices;
	NSMutableData* 		partialResponseData;
	
	NSDictionary* deviceInfo;
	

}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	
	NSURL *url = [[NSBundle mainBundle] URLForResource: @"web/index" withExtension: @"html"];
	NSLog(@"Loading URL: %@", url);
	[self.webView loadRequest: [NSURLRequest requestWithURL: url]];
	
	NSLog(@"initiating BLE");

	bleManager = [[CBCentralManager alloc] initWithDelegate: self queue: dispatch_get_main_queue() options: nil];
	
	assert(bleManager);

}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
	NSLog(@"BLE centralManagerDidUpdateState: %ld", (long)central.state);
	if (central.state == CBCentralManagerStatePoweredOn)
	{
		NSLog(@"BLE Powered On, scanning...");
		[bleManager scanForPeripheralsWithServices: @[[CBUUID UUIDWithString: bleUartServiceUUID]] options:nil];
		//[bleManager scanForPeripheralsWithServices: nil options:nil];
	}
	
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSLog(@"discovered %@", peripheral.debugDescription);
	NSLog(@"ad %@", advertisementData.debugDescription);
	NSLog(@"rssi %@", RSSI);
	
	if ([[peripheral.name substringToIndex: 2] isEqualToString: @"HB"])
	{
		[bleDevices addObject: peripheral];
		
		long i = 0;
		NSMutableArray* jsons = [NSMutableArray arrayWithCapacity: bleDevices.count];
		
		for (CBPeripheral* device in bleDevices)
		{
			[jsons addObject: [NSString stringWithFormat: @"{name: \"%@\", mac_address: \"\%@\", device_id: %ld}", device.name, device.identifier, i++]];
		}
		
		NSString* json = [NSString stringWithFormat: @"[%@]", [jsons componentsJoinedByString:@","]];
		
		[self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"Page1A.setScanning(false)"]];
		[self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"Page1A.notifyDeviceListChanged(%@)", json]];

		self.statusLabel.text = @"discovered peripheral";
	}
	
//	if (self.bleUart != peripheral)
//	{
//		assert(!self.bleUart);
//		self.bleUart = peripheral;
//		[central connectPeripheral: peripheral options: nil];
//	}
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	peripheral.delegate = self;
	
	self.bleUart = peripheral;
	
	NSString* json = [NSString stringWithFormat: @"{name: \"%@\", mac_address: \"\%@\"}", peripheral.name, peripheral.identifier];
	
	[self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"Page1A.onDeviceConnected(%@)", json]];

	
	[peripheral discoverServices: nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	if (peripheral == self.bleUart)
	{
//		self.bleUart = nil;
		
		[bleManager connectPeripheral: self.bleUart options: nil];
		
		if (central.state == CBCentralManagerStatePoweredOn)
		{
			[bleManager scanForPeripheralsWithServices: @[[CBUUID UUIDWithString: bleUartServiceUUID]] options:nil];
			//[bleManager scanForPeripheralsWithServices: nil options:nil];
		}
	}
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	for (CBService* service in peripheral.services)
	{
		NSLog(@"service: %@", service.UUID);
		NSLog(@"servs: %@", service.includedServices);
		
		[peripheral discoverCharacteristics: nil forService: service];
		[peripheral discoverIncludedServices: nil forService: service];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error;
{
	NSLog(@"service: %@", service.UUID);
	NSLog(@"servs: %@", service.includedServices);
	
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
	NSData* data = characteristic.value;
	NSLog(@"RX=%@", [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
	
	if (data)
		[partialResponseData appendData: data];
	else
	{
		NSLog(@"no data!");
		partialResponseData = [NSMutableData data]; // null data means reset, something's iffy
	}
	
	NSString* responseString = [[NSString alloc] initWithData: partialResponseData encoding: NSUTF8StringEncoding];

	const char* str = [responseString cStringUsingEncoding: NSUTF8StringEncoding];
	
	if (!str)
	{
		NSLog(@"iffy data: %@", data);
		// discard data if its not a valid string
		partialResponseData = [NSMutableData data];
		str = "";
	}
	
	// remove newlines from beginning
	size_t newlines = strspn(str, "\r\n");

	size_t nonNewlines = strcspn(str + newlines, "\r\n");
	if (nonNewlines > 0 && (newlines + nonNewlines < strlen(str)))
	{
		NSString* dataString = [[NSString alloc] initWithBytes: str + newlines length: nonNewlines encoding: NSUTF8StringEncoding];
		partialResponseData = [partialResponseData subdataWithRange: NSMakeRange( newlines + nonNewlines, partialResponseData.length - newlines - nonNewlines)].mutableCopy;
		
		NSLog(@"full RX=%@", dataString);
		
		// I,protocol,hwVersion,fwVersion,deviceName,serialNumber,feedKeyEN,feedKey
		NSArray* items = [dataString componentsSeparatedByString: @","];
		
		if ([items[0] isEqualToString: @"I"])
		{
			NSMutableDictionary* infoDict = [NSMutableDictionary dictionary];
			for (size_t i = 0; i < items.count; ++i)
			{
				switch (i)
				{
					case 1:
					infoDict[@"protocol"] = items[i];
					break;
					case 2:
					infoDict[@"hwVersion"] = items[i];
					break;
					case 3:
					infoDict[@"fwVersion"] = items[i];
					break;
					case 4:
					infoDict[@"deviceName"] = items[i];
					break;
					case 5:
					infoDict[@"serialNumber"] = items[i];
					break;
					case 6:
					infoDict[@"feedKeyEN"] = items[i];
					break;
					case 7:
					infoDict[@"feedKey"] = items[i];
					break;
				}
			}
			
			deviceInfo = infoDict;
			
			[self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"Page1B.populateDeviceInfo(\"%@\",\"%@\",\"%@\",\"%@\")", infoDict[@"deviceName"], infoDict[@"hwVersion"], infoDict[@"fwVersion"], infoDict[@"serialNumber"]]];
		}
		else if ([items[0] isEqualToString: @"W"])
		{
			NSMutableDictionary* infoDict = [NSMutableDictionary dictionary];
			// W,status,macAddress,ipAddress,networkSaved,securityType,ssid
//			NSLog(@"W items = %@", items);
			NSString* conStatus = @"disconnected";
			for (size_t i = 0; i < items.count; ++i)
			{
				switch (i)
				{
					case 1:
						infoDict[@"status"] = items[i];
						if ([infoDict[@"status"] isEqual: @"1"])
						{
							conStatus = @"no network";
						}
						else if ([infoDict[@"status"] isEqual: @"2"])
						{
							conStatus = @"join failed";
						}
						else if ([infoDict[@"status"] isEqual: @"3"])
						{
							conStatus = @"authentication failed";
						}
						else if ([infoDict[@"status"] isEqual: @"4"])
						{
							conStatus = @"association failed";
						}
						else if ([infoDict[@"status"] isEqual: @"5"])
						{
							conStatus = @"joining";
						}
						else if ([infoDict[@"status"] isEqual: @"6"])
						{
							conStatus = @"connected";
						}
						else
						{
							conStatus = infoDict[@"status"];
						}
						break;
					case 2:
						infoDict[@"macAddress"] = items[i];
						break;
					case 3:
						infoDict[@"ipAddress"] = items[i];
						break;
					case 4:
						infoDict[@"networkSaved"] = items[i];
						break;
					case 5:
						infoDict[@"securityType"] = items[i];
						break;
					case 6:
						infoDict[@"ssid"] = items[i];
						break;
				}
			}
			
			if (infoDict[@"ssid"])
				self.networkName = infoDict[@"ssid"];
			else
				self.networkName = @"<unknown>";
			
			NSString* webStr = [NSString stringWithFormat: @"Page2B.populateNetworkInfo(\"%@\",\"%@\",\"%@\",\"%@\")", self.networkName, conStatus, infoDict[@"ipAddress"], infoDict[@"macAddress"]];
			
//			NSLog(@"webStr = %@", webStr);
			
			[self.webView stringByEvaluatingJavaScriptFromString: webStr];
			
			if ([infoDict[@"status"] integerValue] != 6)
			{
				// if not connected, ask info again
				[NSTimer scheduledTimerWithTimeInterval: 1.0 repeats: NO block:^(NSTimer * _Nonnull timer) {
					NSString* cmd = [NSString stringWithFormat: @"W\r\n"];
					[self writeBleUart: [cmd dataUsingEncoding: NSUTF8StringEncoding]];
				}];

				
			}
		}
        else if ([items[0] isEqualToString: @"R"])
        {
            // after removing network, go back to scan page
            [self.webView stringByEvaluatingJavaScriptFromString: @"App.goToPage(\"page2a\")"];
        }
		else
		{
			if ([items[0] isEqualToString: @"S"])
			{
				if (self.wifiTimer && (items.count > 2) && ([items[1] integerValue] > 0))
				{
					// got some networks
					[self.wifiTimer invalidate];
					self.wifiTimer = nil;
					
					NSInteger numNets = [items[1] integerValue];
					
					self.networks = [NSMutableDictionary dictionary];
					
					for (NSInteger i = 0; i < numNets; ++i)
					{
						NSString* cmd = [NSString stringWithFormat: @"S,%ld\r\n", i];
						
						[self writeBleUart: [cmd dataUsingEncoding: NSUTF8StringEncoding]];
					}
					
				}
				else if (items.count >= 5)
				{
					self.networks[items[1]] = @{@"security_type" : items[2], @"ssid" : items[3]};

					// update networks
					
					NSMutableString* json = [NSMutableString stringWithFormat: @"["];
					for(id key in [self.networks.allKeys sortedArrayUsingComparator: ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
						return [obj1 compare: obj2];
					}])
					{
//						NSInteger idx = [key intValue];
						NSDictionary* net = self.networks[key];
						[json appendFormat: @"{ssid: \"%@\", security_type: %@},", net[@"ssid"], net[@"security_type"]];
						
					}
					[json appendFormat: @"]"];
					
					[self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"Page2A.notifyNetworkListChanged(%@)", json]];
					[self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"Page2A.setScanning(false)"]];

				}
				


			}
		}

	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	NSLog(@"service: %@", service.UUID);
	for (CBCharacteristic* characteristic in service.characteristics)
	{
		
		NSLog(@"char: %@", characteristic.UUID);
	
		if ([characteristic.UUID isEqual: [CBUUID UUIDWithString: @BLE_DEVICE_RX_UUID]])
		{
			// subscribe to RX characteristic
			NSLog(@"RX properties: 0x%08lX", (unsigned long)characteristic.properties);
			NSLog(@"Subscribing to RX");
			assert(CBCharacteristicPropertyNotify & characteristic.properties);
			[peripheral setNotifyValue: YES forCharacteristic: characteristic];

		}
		if ([characteristic.UUID isEqual: [CBUUID UUIDWithString: @BLE_DEVICE_TX_UUID]])
		{
			// subscribe to RX characteristic
			NSLog(@"TX properties: 0x%08lX", (unsigned long)characteristic.properties);
			assert(CBCharacteristicPropertyWriteWithoutResponse & characteristic.properties);
			assert(CBCharacteristicPropertyWrite & characteristic.properties);

		}
	}
	

	
//	[self enableWrite];
//	[self writeBleUart: [@"hi" dataUsingEncoding: NSASCIIStringEncoding]];
	
}

-(void) writeBleUart:(NSData *)d
{
	CBUUID *uuid_service = [CBUUID UUIDWithString:@BLE_DEVICE_SERVICE_UUID];
	CBUUID *uuid_char = [CBUUID UUIDWithString:@BLE_DEVICE_TX_UUID];
	
	//assert(self.bleUart);
	if (self.bleUart)
	{
		for (size_t k = 0; k < (d.length+19)/20; ++k)
		{
			[self writeValue:uuid_service characteristicUUID:uuid_char p: self.bleUart data:
			 	[d subdataWithRange: NSMakeRange(k*20,  MIN(20, d.length - 20*k))]
			];
		}
	}
}

//
//-(void) enableWrite
//{
//	CBUUID *uuid_service = [CBUUID UUIDWithString:@BLE_DEVICE_SERVICE_UUID];
//	CBUUID *uuid_char = [CBUUID UUIDWithString:@BLE_DEVICE_RESET_RX_UUID];
//	unsigned char bytes[] = {0x01};
//	NSData *d = [[NSData alloc] initWithBytes:bytes length:1];
//	[self writeValue:uuid_service characteristicUUID:uuid_char p: biscuit data:d];
//}
//

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2
{
	if (memcmp(UUID1.data.bytes, UUID2.data.bytes, MIN(UUID1.data.length, UUID2.data.length)) == 0)
		return 1;
	else
		return 0;
}

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
	for(int i = 0; i < p.services.count; i++)
	{
		CBService *s = [p.services objectAtIndex:i];
		if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
	}
	
	return nil; //Service not found on this peripheral
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service
{
	for(int i=0; i < service.characteristics.count; i++)
	{
		CBCharacteristic *c = [service.characteristics objectAtIndex:i];
		if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
	}
	
	return nil; //Characteristic not found on this service
}


-(void) writeValue:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data
{
	CBService *service = [self findServiceFromUUID:serviceUUID p:p];
	
	if (!service)
	{
		NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@", serviceUUID, p.identifier);
		return;
	}
	
	CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
	
	if (!characteristic)
	{
		NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",characteristicUUID, serviceUUID, p.identifier);
		return;
	}
	
	[p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (NSString *) getCurrentWifiHotSpotName
{
	NSString *wifiName = nil;
	NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
	for (NSString *ifnam in ifs) {
		NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
		if (info[ (__bridge id)kCNNetworkInfoKeySSID]) {
			wifiName = info[ (__bridge id)kCNNetworkInfoKeySSID];
		}
	}
//	kCNNetworkInfoKeySSID;
	return wifiName;
}

- (IBAction) connect:(id)sender
{
	NSString* cmd = [NSString stringWithFormat: @"J,%@,%@,%@\r\n", self.securityType, self.networkName, self.password];
	
	NSLog(@"join network: %@", cmd);

	[self writeBleUart: [cmd dataUsingEncoding: NSUTF8StringEncoding]];
	
	[NSTimer scheduledTimerWithTimeInterval: 0.5 repeats: false block:^(NSTimer * _Nonnull timer) {
		[self.webView stringByEvaluatingJavaScriptFromString: @"App.goToPage(\"page2b\")"];
	}];
	
	
	
}

- (BOOL) handleLocalRequest: (NSURLRequest *)request
{
	NSLog(@"handleLocalRequest: %@", request.URL);
	NSURL *url = request.URL;
	
	
	if ([url.scheme isEqualToString: @"schema"])
	{
		if ([url.host isEqualToString: @"bleScan"])
		{
			if ([url.path isEqualToString: @"/true"])
			{
				NSLog(@"handleLocalRequest: scanning for BLE");
				bleDevices = [NSMutableArray array];
				[bleManager scanForPeripheralsWithServices: @[[CBUUID UUIDWithString: bleUartServiceUUID]] options:nil];
				[self.wifiTimer invalidate];
				self.wifiTimer = nil;
				if (self.bleUart)
					[bleManager cancelPeripheralConnection: self.bleUart];
				self.bleUart = nil;
			}
			else
			{
				[bleManager stopScan];
			}
		}
		else if ([url.host isEqualToString: @"connectDevice"])
		{
			NSInteger deviceIndex = [url.pathComponents[0] integerValue];
			NSLog(@"handleLocalRequest: connect to device %ld", deviceIndex);
			self.statusLabel.text = [NSString stringWithFormat: @"connectToDevice"];
			
			[bleManager connectPeripheral: bleDevices[deviceIndex] options: nil];

		}
		else if ([url.host isEqualToString: @"requestDeviceInfo"])
		{
			NSLog(@"handleLocalRequest: requestDeviceInfo");
			partialResponseData = [NSMutableData data];
			[self writeBleUart: [@"I\r\n" dataUsingEncoding: NSUTF8StringEncoding]];

		}
		else if ([url.host isEqualToString: @"wifiScan"])
		{
			NSLog(@"handleLocalRequest: wifiScan");
			
			[self writeBleUart: [@"S,start\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
			
			// setup periodic polling for scan results
			self.wifiTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0 repeats: YES block:^(NSTimer * _Nonnull timer) {
				[self writeBleUart: [@"S,count\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
			}];

			
//			NSString* wifiName = [self getCurrentWifiHotSpotName];
//
//			NSString* json = [NSString stringWithFormat: @"[{ssid: \"%@\", security_type: \"?\"}]", wifiName];
//
//			[self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"Page2A.notifyNetworkListChanged(%@)", json]];
//
//			[self.webView stringByEvaluatingJavaScriptFromString: @"Page2A.setScanning(false)"];

		}
		else if ([url.host isEqualToString: @"addNetwork"])
		{
			NSLog(@"handleLocalRequest: addNetwork");
			
			self.networkName = @"";
			self.password = @"";
			self.securityType = @(1);
			
			[self performSegueWithIdentifier: @"ShowNetworkLoginSegue" sender: self];

			
			// display dialog adding custom wifi network

		}
		else if ([url.host isEqualToString: @"joinNetwork"])
		{
			self.networkName = [url.pathComponents[1] stringByRemovingPercentEncoding];
			self.securityType = @([[url.pathComponents[2] stringByRemovingPercentEncoding] integerValue]);
//
//			NSArray* netDict = self.networks.allValues[ [self.networks.allValues indexOfObjectPassingTest:^BOOL(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//				return [obj[@"ssid"] isEqual: self.networkName];
//			}] ];
//
//			self.securityType = self.networks
			
			// ShowNetworkLoginSegue
			
			[self performSegueWithIdentifier: @"ShowNetworkLoginSegue" sender: self];

			NSLog(@"handleLocalRequest: joinNetwork");

		}
		else if ([url.host isEqualToString: @"requestNetworkInfo"])
		{
			[self writeBleUart: [@"W\r\n" dataUsingEncoding: NSUTF8StringEncoding]];

			NSLog(@"handleLocalRequest: requestNetworkInfo");

		}
		else if ([url.host isEqualToString: @"removeNetwork"])
		{
			[self writeBleUart: [@"R\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
			NSLog(@"handleLocalRequest: removeNetwork");

		}
		else if ([url.host isEqualToString: @"setFeedKey"])
		{
			NSLog(@"handleLocalRequest: setFeedKey");
		
		}
		else if ([url.host isEqualToString: @"displayDialog"])
		{
			NSLog(@"handleLocalRequest: displayDialog");
		}
		else if ([url.host isEqualToString: @"removeFeedKey"])
		{
			[self writeBleUart: [@"K,0\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
			NSLog(@"handleLocalRequest: removeFeedKey");
		}
	}
	
	return NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString: @"ShowNetworkLoginSegue"])
	{
		NetworkDialogViewController* vc = (id)[(UINavigationController*)segue.destinationViewController topViewController];
		assert(vc);
		vc.networkName = self.networkName;
        vc.securityType = [[self.securityType description] integerValue] - 1;
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSLog(@"webView request: %@", request);
	// Determine if we want the system to handle it.
	NSURL *url = request.URL;
	if ([url.scheme isEqualToString: @"schema"])
	{
		return [self handleLocalRequest: request];
	}
	else if ([url.scheme isEqualToString: @"http"] || [url.scheme isEqualToString: @"https"])
	{
		[[UIApplication sharedApplication] openURL: url];
		return NO;
	}
	else
	{
	}
//	else if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"])
//	{
//		if ([[UIApplication sharedApplication]canOpenURL:url]) {
//			[[UIApplication sharedApplication]openURL:url];
//			return NO;
//		}
//	}
	return YES;
}



@end
