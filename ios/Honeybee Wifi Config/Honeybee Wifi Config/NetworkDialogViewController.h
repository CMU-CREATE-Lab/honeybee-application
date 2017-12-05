//
//  NetworkDialogViewController.h
//  Honeybee Wifi Config
//
//  Created by Dömötör Gulyás on 05.10.2017.
//  Copyright © 2017 CMU Create Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkDialogViewController : UIViewController

@property IBOutlet UITextField* ssidField;
@property IBOutlet UISegmentedControl* securitySegments;
@property IBOutlet UITextField* passwordField;

@property NSString* networkName;
@property NSInteger securityType;

- (IBAction) dismiss:(id)sender;
- (IBAction) connectHoneybee:(id)sender;

@end
