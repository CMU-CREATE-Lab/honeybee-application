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
	    self.detailDescriptionLabel.text = [self.honeybee description];
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

- (void)setHoneybee:(HoneybeeBluetoothConnection *)newDetailItem {
	if (_honeybee != newDetailItem) {
	    _honeybee = newDetailItem;
	    
	    // Update the view.
	    [self configureView];
	}
}

- (IBAction) updateFirmwareAction:(id)sender
{
	[self.honeybee updateWifiFirmware];
}



@end
