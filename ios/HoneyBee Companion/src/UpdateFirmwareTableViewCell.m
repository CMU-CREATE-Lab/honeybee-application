//
//  UpdateFirmwareTableViewCell.m
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 22.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import "UpdateFirmwareTableViewCell.h"
#import "HoneybeeBluetoothConnection.h"

@implementation UpdateFirmwareTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
	
	
	UIButton* updateButton = [UIButton buttonWithType: UIButtonTypeSystem];
	
	[updateButton setTitle: [[NSBundle mainBundle] localizedStringForKey: @"honeybee.dfu.updateButton.title" value: @"Update" table: nil] forState: UIControlStateNormal];
	[updateButton sizeToFit];
	
	assert(updateButton);

	self.updateButton = updateButton;
	self.accessoryView = self.updateButton;
	
	[updateButton addTarget: self action: @selector(updateFirmwareAction:) forControlEvents:UIControlEventPrimaryActionTriggered];
	
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction) updateFirmwareAction:(id)sender
{
	if (self.firmwareUpdateBlock)
		self.firmwareUpdateBlock();
}

//- (IBAction) updateHoneyBeeFirmwareAction:(id)sender
//{
//	if (!_honeybee)
//		return;
//	
//	
//	UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"HoneyBee Update in Progress…" message: @"0.0 %" preferredStyle: UIAlertControllerStyleAlert];
//	
//	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
//		[self.honeybee cancelFirmwareUpdate];
//	}];
//	
//	[alert addAction: defaultAction];
//	
//	[self.viewController presentViewController:alert animated:YES completion:nil];
//	
//	[self.updateButton sizeToFit];
//	
//	
//	__weak UpdateFirmwareTableViewCell* weakSelf = self;
//	[self.honeybee updateHoneybeeFirmware: ^(float progress, bool done, NSError *error) {
//		UpdateFirmwareTableViewCell* strongSelf = weakSelf;
//		if (!strongSelf)
//			return;
//		
//		
//		[alert setMessage: [NSString stringWithFormat: @"%.1f %%", 100.0*progress]];
//		
//		if (error)
//		{
//			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Honeybee Update Error" message: error.localizedDescription preferredStyle: UIAlertControllerStyleAlert];
//			
//			UIAlertAction* defaultAction = [UIAlertAction actionWithTitle: @"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//				
//			}];
//			
//			[alert addAction: defaultAction];
//			[self.viewController presentViewController: alert animated:YES completion:nil];
//		}
//		
//		if (error || done)
//		{
//			self.progressView.hidden = YES;
//			self.updateButton.enabled = true;
//			[self.updateButton setTitle:[[NSBundle mainBundle] localizedStringForKey: @"honeybee.dfu.updateButton.title" value: @"Update" table: nil] forState: UIControlStateNormal];
//			[self.updateButton sizeToFit];
//			
//			[alert dismissViewControllerAnimated: YES completion: nil];
//			
//		}
//		
//	}];
//}

//- (IBAction) updateWifiFirmwareAction:(id)sender
//{
//	if (!_honeybee)
//		return;
//
//
//	UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Wifi Update in Progress…" message: @"0.0 %" preferredStyle: UIAlertControllerStyleAlert];
//
//	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
//		[self.honeybee cancelFirmwareUpdate];
//	}];
//
//	[alert addAction: defaultAction];
//
////	UIProgressView* progressBar = [[UIProgressView alloc] initWithProgressViewStyle: UIProgressViewStyleDefault];
//
////	[alert addChildViewController: alert];
//
////	progressBar.progress = 0.0;
//	NSLog(@"Alert subviews %@", alert.view.subviews[0].subviews);
//
//	[self.viewController presentViewController:alert animated:YES completion:nil];
//
////	return;
//
////	self.progressView.progress = 0.0;
////	self.progressView.hidden = false;
//
////	self.updateButton.enabled = false;
////	[self.updateButton setTitle:[[NSBundle mainBundle] localizedStringForKey: @"honeybee.dfu.updateButton.inProgressTitle" value: @"Updating…" table: nil] forState: UIControlStateNormal];
//	[self.updateButton sizeToFit];
//
//
//	__weak UpdateFirmwareTableViewCell* weakSelf = self;
//	[self.honeybee updateWifiFirmware: ^(float progress, bool done, NSError *error) {
//		UpdateFirmwareTableViewCell* strongSelf = weakSelf;
//		if (!strongSelf)
//			return;
//
////		strongSelf.progressView.progress = progress;
//
//		[alert setMessage: [NSString stringWithFormat: @"%.1f %%", 100.0*progress]];
//
//		if (error)
//		{
//			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Wifi Update Error" message: error.localizedDescription preferredStyle: UIAlertControllerStyleAlert];
//
//			UIAlertAction* defaultAction = [UIAlertAction actionWithTitle: @"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//
//			}];
//
//			[alert addAction: defaultAction];
//			[self.viewController presentViewController: alert animated:YES completion:nil];
//		}
//
//		if (error || done)
//		{
//			self.progressView.hidden = YES;
//			self.updateButton.enabled = true;
//			[self.updateButton setTitle:[[NSBundle mainBundle] localizedStringForKey: @"honeybee.dfu.updateButton.title" value: @"Update" table: nil] forState: UIControlStateNormal];
//			[self.updateButton sizeToFit];
//
//			[alert dismissViewControllerAnimated: YES completion: nil];
//
//		}
//
//	}];
//}

@end
