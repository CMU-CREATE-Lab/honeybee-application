//
//  ViewController.h
//  Honeybee Wifi Config
//
//  Created by Dömötör Gulyás on 05.10.2017.
//  Copyright © 2017 CMU Create Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, UIWebViewDelegate>

@property(weak) IBOutlet UIWebView* webView;
@property(weak) IBOutlet UILabel* statusLabel;

@property NSString* networkName;
@property NSValue* securityType;
@property NSString* password;
@property NSString* feedKey;

@property NSTimer* wifiTimer;

@property NSMutableDictionary* networks;

- (IBAction) connect:(id)sender;

@end

