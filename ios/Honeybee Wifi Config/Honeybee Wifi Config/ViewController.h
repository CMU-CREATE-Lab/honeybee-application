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

@end

