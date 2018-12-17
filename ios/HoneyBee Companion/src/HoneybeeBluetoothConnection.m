//
//  HoneyBeeBluetoothConnection.m
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 18.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import "HoneybeeBluetoothConnection.h"

#include "beedance_honeybee.h"
#include "NSData+BeeDance.h"
#include "NSDictionary+BeeDance.h"
#include "msgpack.h"
#include "hb_bootloader.h"

#import <zlib.h>

/*
 HoneyBee/BeeDance
 service	"58040001-39C8-4304-97E1-EA175C7C295E"
 tx			"58040002-39C8-4304-97E1-EA175C7C295E"
 rx			"58040003-39C8-4304-97E1-EA175C7C295E"
 */
//NSString* bleBeedanceServiceUUIDString        = @"58040001-39c8-4304-97e1-ea175c7c295e";
//NSString* bleBeedanceTxCharUUIDString         = @"58040002-39c8-4304-97e1-ea175c7c295e";
//NSString* bleBeedanceRxCharUUIDString         = @"58040003-39C8-4304-97E1-EA175C7C295E";

// WD 41690001-7276-697A-5761-746368646F67
NSString* bleBeedanceServiceUUIDString      = @"41690001-7276-697A-5761-746368646F67";
NSString* bleBeedanceTxCharUUIDString       = @"41690002-7276-697A-5761-746368646F67";
NSString* bleBeedanceRxCharUUIDString       = @"41690003-7276-697A-5761-746368646F67";


@implementation HoneybeeBluetoothConnection
{
	NSMutableData* partialResponseData;
	
	CBPeripheral* peripheral;
	__weak CBCharacteristic* txChar;
	__weak CBCharacteristic* rxChar;
	
	NSTimer* ackTimer;
	NSData* firmwareBeingUpdated;
	size_t firmwareDataSent;
	void (^firmwareProgressBlock)(float progress, bool done, NSError* error);
    
    void (^networkStatusCallback)(NSDictionary* statusDict, NSError* error);
    void (^wifiScanCallback)(NSDictionary* network, NSError* error);
}

- (CBPeripheral*) peripheral
{
	return peripheral;
}

- (void) encodingTest
{
	
	{
		uint8_t src0[2][5] = {
			{1, 2, 3, 4, 5},
			{1, 2, 3, 4, 0}
		};
		
		for (size_t i = 0; i < 2; ++i)
		{
			uint8_t dst[7] = {};
			ptrdiff_t len = beedance_encodePacket(dst, 7, src0[i], 5);
			
			NSData* srcData = [NSData dataWithBytes: src0[i] length: 5];
			NSData* dstData = [NSData dataWithBytes: dst length: len];
			NSLog(@"src (%lu) = %@", srcData.length, srcData);
			NSLog(@"dst (%lu) = %@", dstData.length, dstData);
		}
		
	}
	
	
	
// original packet
//	2018-06-20 13:52:22.182187-0400 HoneyBee Companion[863:153554] data (137) = <2f840109 809b01d1 89697bc7 70f6b3dc 1274db7b 5d4b56d3 96bf1577 a1b0f4a2 25f2af1c 926718e5 f40604ef 90b9e459 e4dd3ab5 19ff02ba f43ceee0 8beb378b ecf4d7ac f2f6f03d afdd7591 33191d1c 40cb7424 192193d9 14feac2a 52c78fd5 0449e48d 6347883c 6983cbfe 47bd2b7e 4fc595ae 0e9dd4d1 43c06773 e314087e e53f9f73 b8330a35 00>
// b64 decoded message
//	2018-06-20 13:50:03.468865-0400 HoneyBee Companion[863:153554] data (131) = <809b01d1 89697bc7 70f6b3dc 1274db7b 5d4b56d3 96bf1577 a1b0f4a2 25f2af1c 926718e5 f40604ef 90b9e400 e4dd3ab5 19ff02ba f43ceee0 8beb378b ecf4d7ac f2f6f03d afdd7591 33191d1c 40cb7424 192193d9 14feac2a 52c78fd5 0449e48d 6347883c 6983cbfe 47bd2b7e 4fc595ae 0e9dd4d1 43c06773 e314087e e53f9f73 b8330a>
	
// messageDataLen = 131 -> sel+msg = 132 -> sel+msg+chksum = 134
//	-> len+msg+checksum = 136 -> len+msg+checksum+term = 137
//    2				 3		134	  136	   137
//	| 2            | 1    | 131 | 2      | 1 |
//	| 0x8401 (132) | 0x09 | ... | 0xXXXX | 0 |

//    NSString* b64 = @"gJsB0Ylpe8dw9rPcEnTbe11LVtOWvxV3obD0oiXyrxySZxjl9AYE75C55ADk3Tq1Gf8CuvQ87uCL6zeL7PTXrPL28D2v3XWRMxkdHEDLdCQZIZPZFP6sKlLHj9UESeSNY0eIPGmDy/5HvSt+T8WVrg6d1NFDwGdz4xQIfuU/n3O4Mwo=";
//
//    NSData* srcMsgData = [[NSData alloc] initWithBase64EncodedString: b64 options: 0];
//
//    NSData* packetData = [srcMsgData encodeBeedanceMessageWithSelector: BEEDANCE_MSG_FILE_CHUNK_WRITE];
//
//
//    NSLog(@"messageData (%lu) = %@", srcMsgData.length, srcMsgData);
//    NSLog(@"packetData (%lu)  = %@", packetData.length, packetData);
//
//    [packetData processBeedanceMessage: ^(NSInteger msgSelector, NSData *msgData) {
//        NSLog(@"decodedData (%lu) = %@", msgData.length, msgData);
//
//    }];
//
//
	
}

- (instancetype) initWithPeripheral: (CBPeripheral*) _peripheral;
{
	if (!(self = [super init]))
		return nil;
	
	peripheral = _peripheral;
	peripheral.delegate = self;
	
	self.name = peripheral.name;
	
	[peripheral discoverServices: nil];
//	[peripheral discoverServices:  @[[CBUUID UUIDWithString: bleBeedanceServiceUUIDString]]];
	
	[self encodingTest];

	return self;
}

- (void) sendBeedanceMessageWithSelector: (size_t) msgSelector data: (NSData*) msgData
{
//    NSString* b64 = [msgData base64EncodedStringWithOptions: 0];
//    NSLog(@"b64 \"%@\"", b64);

	beedance_sendMessageWithBlock(msgSelector, msgData, ^ptrdiff_t(NSData *data) {
//        NSLog(@"data (%lu) = %@", data.length, data);
//
//        [data processBeedanceMessage: ^(NSInteger msgSelector, NSData *msgData) {
//            NSLog(@"decodedData (%lu) = %@", msgData.length, msgData);
//
//        }];
		
		[self writeBleUart: data];
		return 0;
	});

}

- (void) getNetworkStatus: (void (^)(NSDictionary* statusDict, NSError* error)) responseCallback
{
    networkStatusCallback = responseCallback;
    
    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_NETWORK_COMMAND_REQ data: [NSData dataWithLeb128EncodedInt: 0]];
}

- (void) requestWifiScan: (void (^)(NSDictionary* network, NSError* error)) responseCallback
{
    wifiScanCallback = responseCallback;
    
//    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_WIFI_CREDENTIALS_READ data: nil];

    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_NETWORK_COMMAND_REQ data: [NSData dataWithLeb128EncodedInt: 1]];
}

- (void) joinNetwork: (NSDictionary*) network
{

    // send wifi credentials
    NSMutableDictionary* netDict = [network dictionaryWithValuesForKeys: @[@"SSID", @"security", @"key"]].mutableCopy;
    
    netDict[@"usage"] = @"update";
    
    NSData* netData = [netDict encodeAsMsgpack];
    
    NSLog(@"netDict = %@", netDict);
    NSLog(@"netData = %@", netData);

    // stop scan
//    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_NETWORK_COMMAND_REQ data: [NSMutableData dataWithLeb128EncodedInt: 2]];

	
    // write new network credentials
//    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_WIFI_CREDENTIALS_WRITE data: netData];
	[NSTimer scheduledTimerWithTimeInterval: 0.3 repeats: NO block:^(NSTimer * _Nonnull timer) {
		[self sendBeedanceMessageWithSelector: BEEDANCE_MSG_WIFI_CREDENTIALS_WRITE data: netData];
		[NSTimer scheduledTimerWithTimeInterval: 0.3 repeats: NO block:^(NSTimer * _Nonnull timer) {
			[self sendBeedanceMessageWithSelector: BEEDANCE_MSG_NETWORK_COMMAND_REQ data: [NSMutableData dataWithLeb128EncodedInt: 3]];
			[NSTimer scheduledTimerWithTimeInterval: 0.3 repeats: NO block:^(NSTimer * _Nonnull timer) {
				[self sendBeedanceMessageWithSelector: BEEDANCE_MSG_WIFI_CREDENTIALS_READ data: nil];
			}];
		}];
	}];

//    // connect
//    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_NETWORK_COMMAND_REQ data: [NSMutableData dataWithLeb128EncodedInt: 3]];
//
//    // request back credentials for debugging purposes
//    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_WIFI_CREDENTIALS_READ data: nil];

    
}

- (void) requestDeviceInfo
{
	NSLog(@"-requestDeviceInfo");
    
    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_DEVICE_INFO_READ data: [NSData dataWithLeb128EncodedInt: BEEDANCE_HONEYBEE_VERSION_SERNO]];
//    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_DEVICE_INFO_READ data: [NSData dataWithLeb128EncodedInt: BEEDANCE_HONEYBEE_VERSION_WIFI_MAC]];
//    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_DEVICE_INFO_READ data: [NSData dataWithLeb128EncodedInt: BEEDANCE_HONEYBEE_VERSION_BLE_MAC]];
//    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_DEVICE_INFO_READ data: [NSData dataWithLeb128EncodedInt: BEEDANCE_HONEYBEE_VERSION_HARDWARE]];

//    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_REQ_INFO data: nil];
}

- (void) requestDeviceHandshake
{
    NSLog(@"-requestDeviceHandshake");
    
    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_DEVICE_INFO_READ data: [NSData dataWithLeb128EncodedInt: BEEDANCE_HONEYBEE_VERSION_BEEDANCE]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
//    NSLog(@"didDiscoverServices: %@", error);
	for (CBService* service in peripheral.services)
	{
//        NSLog(@"service: %@", service.UUID);
//        NSLog(@"included servs: %@", service.includedServices);
		
		[peripheral discoverCharacteristics: nil forService: service];
		[peripheral discoverIncludedServices: nil forService: service];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error;
{
	NSLog(@"service: %@", service.UUID);
	NSLog(@"included servs: %@", service.includedServices);
	
}

- (size_t) decodeLeb128: (NSData*) data
{
	size_t value = 0;
	beedance_decodeLeb128(&value, data.bytes, data.length);
	
	return value;
}

- (void) sendNextFirmwareChunk
{
	NSMutableData* msgData = [NSMutableData data];
	
	NSMutableData* blankData = [NSMutableData dataWithLength: 128];
	memset(blankData.mutableBytes, 0xFF, blankData.length);
	
	while (firmwareDataSent < firmwareBeingUpdated.length)
	{
		size_t len = MIN(128, firmwareBeingUpdated.length - firmwareDataSent);
		
		// optimization: skip over chunks that are all 0xFF, as that's the default state after erase
		NSData* chunk = [firmwareBeingUpdated subdataWithRange: NSMakeRange( firmwareDataSent, len)];
		if (0 == memcmp(chunk.bytes, blankData.bytes, chunk.length))
		{
			NSLog(@"skipping 0x%08zX - 0x%08zX", firmwareDataSent, firmwareDataSent + len);
			firmwareDataSent += len;
			continue;
		}
		
		
		[self encodeLeb128: firmwareDataSent inData: msgData];
		[msgData appendData: chunk];
		
		NSLog(@"sending 0x%08zX - 0x%08zX", firmwareDataSent, firmwareDataSent + len);
//		NSLog(@"msgData (%lu) = %@", msgData.length, msgData);

		[self sendBeedanceMessageWithSelector: BEEDANCE_MSG_FILE_CHUNK_WRITE data: msgData];
		
		__weak HoneybeeBluetoothConnection* weakSelf = self;
		
		ackTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0 repeats: NO block:^(NSTimer * _Nonnull timer) {
			HoneybeeBluetoothConnection* blockSelf = weakSelf;
			assert(blockSelf);
			NSLog(@"timed out for 0x%08zX - 0x%08zX, re-sending", blockSelf->firmwareDataSent, blockSelf->firmwareDataSent + len);
			
			[blockSelf sendNextFirmwareChunk];
			
		}];
		
		
		break;
	}

}

- (void) sendFirmwareSignature
{
	NSMutableData* msgData = [NSMutableData data];
	
	[self encodeLeb128: BEEDANCE_FILE_SIG_CRC32 inData: msgData];
	
	uint32_t signature = (uint32_t)crc32(0, firmwareBeingUpdated.bytes, (uint32_t)firmwareBeingUpdated.length);
	
	[msgData appendBytes: &signature length: sizeof(signature)];
	
	[self sendBeedanceMessageWithSelector: BEEDANCE_MSG_FILE_SIGNATURE_WRITE data: msgData];
	
}


- (void) receiveBeeDanceMessageWithSelector: (NSInteger) msgSelector data: (NSData*) msgData
{
//	NSLog(@"receiveBeeDanceMessageWithSelector: %ld", msgSelector);
	const uint8_t* bytes = msgData.bytes;
	size_t responseStatus = 0;
	NSLog(@"got message 0x%zX (%zu)", msgSelector, msgData.length);
	
	float progress = firmwareDataSent/(double)firmwareBeingUpdated.length;

    switch (msgSelector)
    {
        case BEEDANCE_MSG_DBG:
        {
            size_t dbgId = 0;
            size_t offs = beedance_decodeLeb128(&dbgId, bytes, msgData.length);
            NSString* dbgString = [[NSString alloc] initWithData: [msgData subdataWithRange: NSMakeRange(offs, msgData.length - offs)] encoding: NSUTF8StringEncoding];
            NSLog(@"BD-DBG (%zu): %@", dbgId, dbgString);
            break;
        }
        case BEEDANCE_MSG_FILE_SETUP_RESP:
        {
            beedance_decodeLeb128(&responseStatus, bytes, msgData.length);
            if (responseStatus == 0)
            {
                NSLog(@"File Setup acknowledged");
                
                [self sendNextFirmwareChunk];
            }
            else
            {
                NSLog(@"File Setup not accepted, abort upate");
                
                firmwareDataSent = 0;
                firmwareBeingUpdated = nil;
                
                NSError* error = [NSError errorWithDomain: @"honeybee.dfu.wifi.error" code: -1 userInfo: @{NSLocalizedDescriptionKey:[[NSBundle mainBundle] localizedStringForKey: @"honeybee.dfu.wifi.setupError.description" value: @"Device rejected update attempt." table: nil]}];
                
                if (firmwareProgressBlock)
                    firmwareProgressBlock(progress, NO, error);
            }
            break;
        }
        case BEEDANCE_MSG_FILE_CHUNK_RESP:
        {
            beedance_decodeLeb128(&responseStatus, bytes, msgData.length);
            if (responseStatus == 0)
            {
                [ackTimer invalidate];
                size_t len = MIN(128, firmwareBeingUpdated.length - firmwareDataSent);
                
                firmwareDataSent += len;
                
                if (firmwareDataSent < firmwareBeingUpdated.length)
                    [self sendNextFirmwareChunk];
                else if (firmwareBeingUpdated)
                    [self sendFirmwareSignature];
                
                if (firmwareProgressBlock)
                    firmwareProgressBlock(progress, NO, nil);
            }
            else
            {
                [ackTimer invalidate];
                NSLog(@"File Chunk not accepted, abort upate");
                
                firmwareDataSent = 0;
                firmwareBeingUpdated = nil;
                
                NSError* error = [NSError errorWithDomain: @"honeybee.dfu.wifi.error" code: -2 userInfo: @{NSLocalizedDescriptionKey:[[NSBundle mainBundle] localizedStringForKey: @"honeybee.dfu.wifi.chunkError.description" value: @"Device rejected data transfer." table: nil]}];
                
                if (firmwareProgressBlock)
                    firmwareProgressBlock(progress, NO, error);
            }
            break;
        }
        case BEEDANCE_MSG_FILE_SIGNATURE_RESP:
        {
            beedance_decodeLeb128(&responseStatus, bytes, msgData.length);
            if (responseStatus == 0)
            {
            NSLog(@"firmware accepted");
            firmwareDataSent = 0;
            firmwareBeingUpdated = nil;
            
            // reset MCU to commiting updates
            // TODO: add mode request data, change in BDv0.3.0
            [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_MODE_REQ data: nil];
            
            if (firmwareProgressBlock)
                firmwareProgressBlock(progress, YES, nil);
            }
            else
            {
                NSLog(@"File signature not accepted, abort upate");
                
                firmwareDataSent = 0;
                firmwareBeingUpdated = nil;
                
                NSError* error = [NSError errorWithDomain: @"honeybee.dfu.wifi.error" code: -2 userInfo: @{NSLocalizedDescriptionKey:[[NSBundle mainBundle] localizedStringForKey: @"honeybee.dfu.wifi.signatureError.description" value: @"Device rejected signature." table: nil]}];
                
                if (firmwareProgressBlock)
                    firmwareProgressBlock(progress, NO, error);
            }
            break;
        }
        case BEEDANCE_MSG_DEVICE_INFO_READ:
        {
            size_t offs = 0;
            size_t infoId = 0;
            offs += beedance_decodeLeb128(&infoId, bytes + offs, msgData.length - offs);
            
            NSMutableData* infoData = [NSMutableData dataWithLeb128EncodedInt: infoId];

            switch ((beedance_version_info_t)infoId)
            {
                case BEEDANCE_HONEYBEE_VERSION_BEEDANCE:
                {
                    [infoData appendData: [[NSString stringWithFormat: @"%u.%u.%u", (BEEDANCE_PROTOCOL_VERSION & 0xFF0000) >> 16, (BEEDANCE_PROTOCOL_VERSION & 0xFF00) >> 8, BEEDANCE_PROTOCOL_VERSION & 0xFF] dataUsingEncoding: NSUTF8StringEncoding]];
                    [self sendBeedanceMessageWithSelector: BEEDANCE_MSG_DEVICE_INFO_RESP data: infoData];
                    break;
                }
                default:
                {
                    NSLog(@"Can't answer info request for %zu", infoId);
                    break;
                }
            }
            
            
            break;
        }
        case BEEDANCE_MSG_DEVICE_INFO_RESP:
        {
            size_t offs = 0;
            size_t infoId = 0;
            offs += beedance_decodeLeb128(&infoId, bytes + offs, msgData.length - offs);
            
            NSData* infoData = [msgData subdataWithRange: NSMakeRange( offs, msgData.length - offs)];
            
            NSString* infoString = [[NSString alloc] initWithData: infoData encoding: NSUTF8StringEncoding];
            
            // if not a valid decoding
            if (!infoString)
            {
                uint8_t buf[infoData.length];
                
                msgpack_readString(buf, infoData.length, infoData.bytes, infoData.length);
                infoString = [[NSString alloc] initWithBytes: buf length: strlen((void*)buf) encoding:NSUTF8StringEncoding];
            }

            NSLog(@"msgData %@", msgData);
            NSLog(@"infoData %@", infoData);
            NSLog(@"Received Version Info %zu: %@", infoId, infoString);

            switch ((beedance_version_info_t)infoId)
            {
                case BEEDANCE_HONEYBEE_VERSION_BEEDANCE:
                {
                    NSLog(@"Received HB Protocol Version: %@", infoString);
                    break;
                }
                case BEEDANCE_HONEYBEE_VERSION_HOST_SBL:
                {
                    self.sblVersion = infoString;
                    break;
                }
                case BEEDANCE_HONEYBEE_VERSION_HOST_APP:
                {
                    self.appVersion = infoString;
                    break;
                }
                case BEEDANCE_HONEYBEE_VERSION_WIFI_PLATFORM:
                {
                    self.wifiVersion = infoString;
                    break;
                }
                case BEEDANCE_HONEYBEE_VERSION_HARDWARE:
                {
                    self.hardwareVersion = infoString;
                    break;
                }
                case BEEDANCE_HONEYBEE_VERSION_SERNO:
                {
                    self.serialNumber = infoString;
                    break;
                }
                case BEEDANCE_HONEYBEE_VERSION_BLE_MAC:
                {
                    self.bleMacAddress = infoString;
                    break;
                }
                case BEEDANCE_HONEYBEE_VERSION_WIFI_MAC:
                {
                    self.wifiMacAddress = infoString;
                    break;
                }
                default:
                {
                    NSLog(@"Received Invalid Version Info %zu: %@", infoId, infoString);
                    break;
                }
            }
            break;
        }
        case BEEDANCE_MSG_NETWORK_STATUS_RESP:
        {
//            NSString* msgStructure = [msgData parseMsgpack];
//            NSLog(@"Received Network Status Structure:\n%@", msgStructure);

            NSDictionary* unpackedDict = [msgData decodeMsgpack];
            
            NSLog(@"Received Network Status: %@", unpackedDict);
            if (networkStatusCallback)
            {
                networkStatusCallback(unpackedDict, nil);
            }
            break;
        }
        case BEEDANCE_MSG_WIFI_CREDENTIALS_RESP:
        {
//            NSString* msgStructure = [msgData parseMsgpack];
//            NSLog(@"Received Wifi Structure:\n%@", msgStructure);
            
            NSDictionary* unpackedDict = [msgData decodeMsgpack];
            
            NSLog(@"Received Wifi Status: %@", unpackedDict);
            if (wifiScanCallback)
            {
                wifiScanCallback(unpackedDict, nil);
            }
            break;
        }
    }

}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
//    NSLog(@"didUpdateValueForCharacteristic %@", characteristic.UUID);
	if ([characteristic isEqual: rxChar])
	{
		NSData* data = characteristic.value;
//		NSLog(@"RX=\"%@\"", [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
		
		if (!partialResponseData)
		{
			partialResponseData = [NSMutableData data];
		}
		
		assert(partialResponseData);
		
		if (data)
			[partialResponseData appendData: data];
		else
		{
			NSLog(@"no data!");
			partialResponseData = [NSMutableData data]; // null data means reset, something's iffy
		}
		
//		NSLog(@"got %@ data (%ld)!", data, data.length);

		NSData* remainingData = [partialResponseData processBeedanceMessage: ^(NSInteger msgSelector, NSData *msgData) {
//			NSLog(@"got sel = %ld, msgData = %@!", msgSelector, msgData);
			[self receiveBeeDanceMessageWithSelector: msgSelector data: msgData];
		}];
		
		partialResponseData = remainingData.mutableCopy;
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
	NSLog(@"didDiscoverCharacteristicsForService %@", service.UUID);
	if ([service.UUID isEqual: [CBUUID UUIDWithString: bleBeedanceServiceUUIDString]])
	{
		
		for (CBCharacteristic* ch in service.characteristics)
		{
			if ([ch.UUID isEqual: [CBUUID UUIDWithString: bleBeedanceTxCharUUIDString]])
			{
				NSLog(@"didDiscoverCharacteristicsForService tx %@", ch.UUID);
				txChar = ch;
			}
			else if ([ch.UUID isEqual: [CBUUID UUIDWithString: bleBeedanceRxCharUUIDString]])
			{
				NSLog(@"didDiscoverCharacteristicsForService rx %@", ch.UUID);
				rxChar = ch;
				[peripheral setNotifyValue: YES forCharacteristic: ch];
			}
		}
		
		assert(rxChar);
		assert(txChar);
		
        [self requestDeviceHandshake];
        [self requestDeviceInfo];
	}
}

- (void) writeBleUart:(NSData *)d
{
	//assert(self.bleUart);
	if (peripheral)
	{
        if (peripheral.state != CBPeripheralStateConnected)
        {
            NSLog(@"peripheral no longer connected, cannot send data");
            return;
        }
        
        assert(txChar);
		for (size_t k = 0; k < (d.length+19)/20; ++k)
		{
			[peripheral writeValue: [d subdataWithRange: NSMakeRange(k*20,  MIN(20, d.length - 20*k))] forCharacteristic: txChar type: CBCharacteristicWriteWithoutResponse];
		}
	}
}

- (void) encodeLeb128: (size_t) value inData: (NSMutableData*) data
{
	size_t len = beedance_encodeLeb128(NULL, SIZE_MAX, value);
	size_t offs = data.length;
	data.length += len;
	beedance_encodeLeb128(data.mutableBytes + offs, len, value);
	
}

- (void) cancelFirmwareUpdate
{
	firmwareBeingUpdated = nil;
	firmwareDataSent = 0;
	firmwareProgressBlock = 0;
}



- (void) uploadFirmware: (NSData*) binData forDestination: (size_t) fwDestination progess: (void (^)(float progress, bool done, NSError* error)) progressBlock
{
	firmwareProgressBlock = progressBlock;
	
	NSLog(@"Honeybee firmware image with length %ld", binData.length);
	
	assert(binData.length);
	
	NSMutableData* msgData = [NSMutableData dataWithLength: 0];
	
	[self encodeLeb128: fwDestination inData: msgData];
	[self encodeLeb128: binData.length inData: msgData];
	
	firmwareBeingUpdated = binData;
	
	[self sendBeedanceMessageWithSelector: BEEDANCE_MSG_FILE_SETUP_REQ data: msgData];
	
}

//- (void) updateWifiFirmware: (void (^)(float progress, bool done, NSError* error)) progressBlock
//{
//	firmwareProgressBlock = progressBlock;
//	
//	NSData* fwImageData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"winc1500_m2m_aio_3a0_19.5.4" ofType: @"bin"]];
//	
//	
//	
//	NSLog(@"Wifi firmware image with length %ld", fwImageData.length);
//	
//	assert(fwImageData.length);
//	
//	NSMutableData* msgData = [NSMutableData dataWithLength: 0];
//	
//	[self encodeLeb128: BEEDANCE_FILE_DST_FW_WIFI inData: msgData];
//	[self encodeLeb128: fwImageData.length inData: msgData];
//	
//	firmwareBeingUpdated = fwImageData;
//	
//	[self sendBeedanceMessageWithSelector: BEEDANCE_MSG_FILE_SETUP data: msgData];
//	
//}


@end
