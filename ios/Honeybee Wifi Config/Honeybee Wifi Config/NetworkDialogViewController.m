//
//  NetworkDialogViewController.m
//  Honeybee Wifi Config
//
//  Created by Dömötör Gulyás on 05.10.2017.
//  Copyright © 2017 CMU Create Lab. All rights reserved.
//

#import "NetworkDialogViewController.h"
#import "ViewController.h"

@interface NetworkDialogViewController ()

@end

@implementation NetworkDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.ssidField.text = self.networkName;
	self.passwordField.enabled = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) selectSecurityType:(UISegmentedControl*)sender
{
	self.passwordField.enabled = (sender.selectedSegmentIndex > 0);
}

- (IBAction) dismiss:(id)sender
{
	[self.navigationController dismissViewControllerAnimated: YES completion: nil];
//	ViewController* vc = self.navigationController.parentViewController;
	
}

- (IBAction) connectHoneybee:(id)sender
{
//	[self.navigationController dismissViewControllerAnimated: YES completion: nil];
	ViewController* vc = (id)self.navigationController.presentingViewController;
	assert(vc);
	vc.networkName = self.ssidField.text;
	vc.securityType = @(self.securitySegments.selectedSegmentIndex+1);
	vc.password = self.passwordField.text;
	
	[self.navigationController dismissViewControllerAnimated: YES completion: nil];

	[vc connect: self];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSLog(@"segue!");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
