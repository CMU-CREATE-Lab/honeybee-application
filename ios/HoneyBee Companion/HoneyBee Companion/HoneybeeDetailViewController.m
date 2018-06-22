//
//  DetailViewController.m
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 17.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import "HoneybeeDetailViewController.h"

#include "HoneybeeBluetoothConnection.h"

@interface HoneybeeDetailViewController ()

@end

@implementation HoneybeeDetailViewController

- (void)configureView {
	// Update the user interface for the detail item.
	if (self.honeybee) {
	    self.detailDescriptionLabel.text = self.honeybee.name;
		self.title = self.honeybee.name;
	}
}


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

- (void)setHoneybee:(HoneybeeBluetoothConnection *)hb {
	if (_honeybee != hb) {
	    _honeybee = hb;
	    
	    // Update the view.
	    [self configureView];
	}
}

- (IBAction) updateFirmwareAction:(id)sender
{
	self.wifiUpdateProgress.progress = 0.0;
	self.wifiUpdateProgress.hidden = false;
	
	self.wifiUpdateButton.enabled = false;
	[self.wifiUpdateButton setTitle:[[NSBundle mainBundle] localizedStringForKey: @"honeybee.wifiUpdateButton.inProgressTitle" value: @"Wifi Updating ..." table: nil] forState: UIControlStateNormal];

	__weak HoneybeeDetailViewController* weakSelf = self;
	[self.honeybee updateWifiFirmware: ^(float progress, bool done, NSError *error) {
		HoneybeeDetailViewController* strongSelf = weakSelf;
		if (!strongSelf)
			return;
		
		strongSelf.wifiUpdateProgress.progress = progress;
		
		if (error)
		{
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Wifi Update Error" message: error.localizedDescription preferredStyle: UIAlertControllerStyleAlert];
			
			UIAlertAction* defaultAction = [UIAlertAction actionWithTitle: @"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
				
			}];
			
			[alert addAction: defaultAction];
			[self presentViewController:alert animated:YES completion:nil];
		}
		
		if (error || done)
		{
			self.wifiUpdateProgress.hidden = YES;
			self.wifiUpdateButton.enabled = true;
			[self.wifiUpdateButton setTitle:[[NSBundle mainBundle] localizedStringForKey: @"honeybee.wifiUpdateButton.title" value: @"Update Wifi Firmware" table: nil] forState: UIControlStateNormal];
		}
		
	}];
}



@end
