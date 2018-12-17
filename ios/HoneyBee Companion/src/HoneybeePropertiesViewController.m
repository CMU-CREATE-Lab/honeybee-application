//
//  HoneybeePropertiesViewControllerTableViewController.m
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 22.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import "HoneybeePropertiesViewController.h"

#import "HoneybeeBluetoothConnection.h"
#import "UpdateFirmwareTableViewCell.h"

#import "hb_bootloader.h"
#import "beedance.h"

NSString* HBHardwareVersionKey = @"HoneybeeHardwareVersion";
NSString* HBWifiVersionKey = @"HoneybeeWifiVersion";
NSString* HBSamAppVersionKey = @"HoneybeeSamAppVersion";
NSString* HBSamSblVersionKey = @"HoneybeeSamSblVersion";
NSString* HBSerialNumberKey = @"HoneybeeSerialNumber";
NSString* HBSetupKey = @"HoneybeeSetup";


NSString* honeybeeApplImageName = @"honeybee_app.img";
NSString* honeybeeBootImageName = @"honeybee_boot.img";
NSString* honeybeeWifiImageName = @"winc1500_m2m_aio_3a0_19.5.4";


@interface HoneybeePropertiesViewController ()

@end

@implementation HoneybeePropertiesViewController
{
	NSArray* honeybeePropertyKeys;
	
	UIAlertController* updateProgressAlert;
	UIAlertController* updateErrorAlert;
	UIAlertController* updateSuccessAlert;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	honeybeePropertyKeys = @[HBSamAppVersionKey, HBSamSblVersionKey, HBWifiVersionKey, HBHardwareVersionKey, HBSerialNumberKey, HBSetupKey];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	

}

- (void) setHoneybee:(HoneybeeBluetoothConnection *)honeybee
{
	if (honeybee != _honeybee)
	{
		_honeybee = honeybee;
		[self.tableView reloadData];
		self.navigationItem.title = honeybee.name;
	}
}

- (void) createAlertControllers
{
	updateProgressAlert = [UIAlertController alertControllerWithTitle: @"Update in Progress…" message: @"0.0 %" preferredStyle: UIAlertControllerStyleAlert];
	
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
		[self.honeybee cancelFirmwareUpdate];
	}];
	[updateProgressAlert addAction: cancelAction];
	
	updateSuccessAlert = [UIAlertController alertControllerWithTitle:@"Upload Done" message: @"" preferredStyle: UIAlertControllerStyleAlert];
	
	[updateSuccessAlert addAction: [UIAlertAction actionWithTitle: @"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
	}]];
	
	updateErrorAlert = [UIAlertController alertControllerWithTitle: @"Update Error" message: @"" preferredStyle: UIAlertControllerStyleAlert];
	[updateErrorAlert addAction: [UIAlertAction actionWithTitle: @"OK" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
		
	}]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch(section)
	{
		case 0:
		{
			size_t nrows = honeybeePropertyKeys.count;
			return nrows;
		}
		default:
			return 0;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	id key = honeybeePropertyKeys[indexPath.row];
	
	UIButton* updateButton = [UIButton buttonWithType: UIButtonTypeSystem];
	
	[updateButton setTitle: [[NSBundle mainBundle] localizedStringForKey: @"honeybee.dfu.updateButton.title" value: @"Update" table: nil] forState: UIControlStateNormal];
	[updateButton sizeToFit];
	
	

	if ([key isEqual: HBSetupKey])
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: HBSetupKey forIndexPath: indexPath];
		
		cell.textLabel.text = [NSString stringWithFormat: @"Network"];
		
		return cell;

	}
    else if ([key isEqual: HBHardwareVersionKey])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: HBHardwareVersionKey forIndexPath: indexPath];
        
        cell.textLabel.text = [NSString stringWithFormat: @"Hardware Version %@", self.honeybee.hardwareVersion];
        
        return cell;
        
    }
    else if ([key isEqual: HBSerialNumberKey])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: HBSerialNumberKey forIndexPath: indexPath];
        
        cell.textLabel.text = [NSString stringWithFormat: @"Serial Number %@", self.honeybee.serialNumber];
        
        return cell;
        
    }
	else if ([key isEqual: HBSamAppVersionKey])
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: HBSamAppVersionKey forIndexPath: indexPath];
		
		cell.textLabel.text = [NSString stringWithFormat: @"HB Appl v%@", self.honeybee.appVersion];
		
		cell.accessoryView = updateButton;
		
		[updateButton addTarget: self action: @selector(updateApplFirmware:) forControlEvents:UIControlEventPrimaryActionTriggered];
		
		return cell;
		
	}
	else if ([key isEqual: HBSamSblVersionKey])
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: HBSamSblVersionKey forIndexPath: indexPath];
		
		cell.textLabel.text = [NSString stringWithFormat: @"HB Boot v%@", self.honeybee.sblVersion];
		
		cell.accessoryView = updateButton;
		
		[updateButton addTarget: self action: @selector(updateBootFirmware:) forControlEvents:UIControlEventPrimaryActionTriggered];

		return cell;
		
	}
	else if ([key isEqual: HBWifiVersionKey])
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: HBWifiVersionKey forIndexPath: indexPath];
//		cell.viewController = self;
//		cell.honeybee = self.honeybee;
		
		cell.textLabel.text = [NSString stringWithFormat: @"Wifi v%@", self.honeybee.wifiVersion];

		cell.accessoryView = updateButton;

		[updateButton addTarget: self action: @selector(updateWifiFirmware:) forControlEvents:UIControlEventPrimaryActionTriggered];

		
		return cell;
		
	}
	else
	{
		assert(0);
		return nil;
	}
}

- (void) progress: (float) progress done: (BOOL) done error: (NSError*) error
{
	updateProgressAlert.message = [NSString stringWithFormat: @"%.1f %%", 100.0*progress];
	
	if (error || done)
	{
		[self dismissViewControllerAnimated: YES completion: nil];
	}
	
	if (error)
	{
		updateErrorAlert.message = error.localizedDescription;
		
		
		[self presentViewController: updateErrorAlert animated:YES completion:nil];
	}
	else if (done)
	{
		[updateProgressAlert dismissViewControllerAnimated: YES completion: nil];
		
		[self presentViewController: updateSuccessAlert animated:YES completion:nil];
	}

}

- (IBAction) updateWifiFirmware:(id)sender
{
	NSData* fwBinary = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: honeybeeWifiImageName ofType: @"bin"]];
	
	[self createAlertControllers];
	
	updateProgressAlert.title = @"Wifi Update in Progress…";
	updateProgressAlert.message = @"0.0 %";

	updateSuccessAlert.message = @"Wifi Update Successful.";

	[self presentViewController: updateProgressAlert animated:YES completion:nil];
	
	__weak HoneybeePropertiesViewController* weakSelf = self;
	
	[self.honeybee uploadFirmware: fwBinary forDestination: BEEDANCE_FILE_DST_FW_WIFI progess: ^(float progress, bool done, NSError *error) {
		
		HoneybeePropertiesViewController* strongSelf = weakSelf;
		
		[strongSelf progress: progress done: done error: error];
		
	}];

}
- (IBAction) updateApplFirmware:(id)sender
{
	NSData* fwImage = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: honeybeeApplImageName ofType: @"bin"]];
	NSData* fwBinary = [self getFirmwareBinaryFromImage: fwImage];
	
	[self createAlertControllers];

	updateProgressAlert.title = @"Application Update in Progress…";
	updateProgressAlert.message = @"0.0 %";
	
	updateSuccessAlert.message = @"Application Update Successful.";
	
	[self presentViewController: updateProgressAlert animated:YES completion:nil];
	
	__weak HoneybeePropertiesViewController* weakSelf = self;
	
	[self.honeybee uploadFirmware: fwBinary forDestination: BEEDANCE_FILE_DST_FW_APP progess: ^(float progress, bool done, NSError *error) {
		
		HoneybeePropertiesViewController* strongSelf = weakSelf;
		
		[strongSelf progress: progress done: done error: error];

	}];
	
}

- (IBAction) updateBootFirmware:(id)sender
{
	NSData* fwImage = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: honeybeeBootImageName ofType: @"bin"]];
	NSData* fwBinary = [self getFirmwareBinaryFromImage: fwImage];
	
	[self createAlertControllers];

	updateProgressAlert.title = @"Bootloader Update in Progress…";
	updateProgressAlert.message = @"0.0 %";
	
	updateSuccessAlert.message = @"Bootloader Update Successful.";
	
	[self presentViewController: updateProgressAlert animated:YES completion:nil];
	
	__weak HoneybeePropertiesViewController* weakSelf = self;
	
	[self.honeybee uploadFirmware: fwBinary forDestination: BEEDANCE_FILE_DST_FW_SBL progess: ^(float progress, bool done, NSError *error) {
		
		HoneybeePropertiesViewController* strongSelf = weakSelf;
		
		[strongSelf progress: progress done: done error: error];

	}];
	
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue destinationViewController] respondsToSelector: @selector(setHoneybee:)])
    {
        [(id)[segue destinationViewController] setHoneybee: self.honeybee];
    }
}



- (NSData*) getFirmwareBinaryFromImage: (NSData*) imageData
{
	const uint8_t* bytes = imageData.bytes;
	
	uint32_t length = *(const uint32_t*)(bytes + imageData.length + BOOTLOADER_LENGTH_ENDOFFS);
	
	NSLog(@"actual image length %u", length);
	
	return [imageData subdataWithRange: NSMakeRange(0, length)];
}

- (NSString*) getFirmwareVersionFromBinary: (NSData*) binData
{
	const uint8_t* bytes = binData.bytes;
	
	uint32_t fwVersion = *(const uint32_t*)(bytes + binData.length + BOOTLOADER_SOFTVERSION_ENDOFFS);
	
	const char* gitHash = (const char*)(bytes + binData.length + BOOTLOADER_GITHASH_ENDOFFS);
	
	NSLog(@"fwVersion %u", fwVersion);
	NSLog(@"gitHash %.*s", BOOTLOADER_GITHASH_SIZE, gitHash);
	
	return [NSString stringWithFormat: @"%u-%.*s", fwVersion, BOOTLOADER_GITHASH_SIZE, gitHash];
}

- (NSString*) honeyBeeApplImageVersion
{
	NSData* fwImageData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: honeybeeApplImageName ofType: @"bin"]];
	
	NSData* binData = [self getFirmwareBinaryFromImage: fwImageData];
	
	NSString* imageVersion = [self getFirmwareVersionFromBinary: binData];
	
	return imageVersion;
}

@end
