//
//  MasterViewController.m
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 17.06.2018.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import "DeviceListViewController.h"
#import "HoneybeeDetailViewController.h"
#import "HoneybeeBluetoothConnection.h"

@import CoreBluetooth;




//#define BLE_DEVICE_SERVICE_UUID			"58040001-39C8-4304-97E1-EA175C7C295E"
//
//#define BLE_DEVICE_TX_UUID				"58040002-39C8-4304-97E1-EA175C7C295E"
//#define BLE_DEVICE_TX_WRITE_LEN			20
//
//#define BLE_DEVICE_RX_UUID				"58040003-39C8-4304-97E1-EA175C7C295E"
//#define BLE_DEVICE_RX_READ_LEN			20

@interface CBUUID (Private)

- (NSString*) toString;

@end


@implementation CBUUID (Private)

- (NSString*) toString
{
	return CFBridgingRelease(CFUUIDCreateString(NULL, (CFUUIDRef) self));
}

@end



@interface DeviceListViewController ()

@property NSMutableArray *objects;

@property(strong, nullable) CBCentralManager* bleManager;

@end

@implementation DeviceListViewController
{
	NSMutableSet* pendingBluetoothConnections;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (HoneybeeDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	
	NSLog(@"initiating BLE");
	
	self.bleManager = [[CBCentralManager alloc] initWithDelegate: self queue: dispatch_get_main_queue() options: nil];
	
	assert(self.bleManager);

}


- (void)viewWillAppear:(BOOL)animated {
	self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
	[super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender
{
	[self performSegueWithIdentifier: @"AddHoneyBeeStart" sender: self];

	if (!self.objects) {
	    self.objects = [[NSMutableArray alloc] init];
	}
	[self.objects insertObject:[NSDate date] atIndex:0];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
	    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	    HoneybeeBluetoothConnection *object = self.objects[indexPath.row];
	    HoneybeeDetailViewController *controller = (HoneybeeDetailViewController *)[[segue destinationViewController] topViewController];
	    [controller setHoneybee: object];
	    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
	    controller.navigationItem.leftItemsSupplementBackButton = YES;
	}
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	HoneybeeBluetoothConnection *hb = self.objects[indexPath.row];
	cell.textLabel.text = hb.name;
	return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	    [self.objects removeObjectAtIndex:indexPath.row];
	    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
	    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}
}

NSString* bleUartServiceUUID = @"6e400001-b5a3-f393-e0a9-e50e24dcca9e";

- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
	NSLog(@"BLE centralManagerDidUpdateState: %ld", (long)central.state);
	if (central.state == CBManagerStatePoweredOn)
	{
		NSLog(@"BLE Powered On, scanning...");
		[self.bleManager scanForPeripheralsWithServices: @[[CBUUID UUIDWithString: bleBeedanceServiceUUIDString], [CBUUID UUIDWithString: bleUartServiceUUID]] options:nil];
		//[bleManager scanForPeripheralsWithServices: nil options:nil];
	}
	
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSLog(@"discovered %@", peripheral.debugDescription);
	NSLog(@"ad %@", advertisementData.debugDescription);
	NSLog(@"rssi %@", RSSI);
	
	if (!pendingBluetoothConnections)
	{
		pendingBluetoothConnections = [NSMutableSet set];
	}
	
	[pendingBluetoothConnections addObject: peripheral];
	
	[central connectPeripheral: peripheral options: nil];

}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	if (!self.objects)
	{
		self.objects = [NSMutableArray array];
	}
	
	assert(self.objects);
	
	HoneybeeBluetoothConnection* hb = [[HoneybeeBluetoothConnection alloc] initWithPeripheral: peripheral];
	
	
	[self.objects addObject: hb];
	
	[self.tableView reloadData];
	
	[pendingBluetoothConnections removeObject: peripheral];

	NSLog(@"added HB %@", hb.name);
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	NSLog(@"could not connect to HB because %@", error);
	[pendingBluetoothConnections removeObject: peripheral];

}

@end
