//
//  HBNetworkSetupViewController.m
//  HoneyBee Companion
//
//  Created by Dömötör Gulyás on 12/11/18.
//  Copyright © 2018 Airviz. All rights reserved.
//

#import "HBNetworkSetupViewController.h"
#import "HoneybeeBluetoothConnection.h"

@interface HBNetworkSetupViewController ()

@end

@implementation HBNetworkSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentNetworkName = @"<unknown>";
    self.scannedNetworks = @{};
    
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
//        self.navigationItem.title = honeybee.name;
        
        [honeybee getNetworkStatus: ^(NSDictionary *statusDict, NSError *error) {
            NSLog(@"getNetworkStatus response! %@, %@", statusDict, error);

            NSDictionary* wifiInfo = [statusDict objectForKey: @"wifi_client"];
            
            NSString* network = [wifiInfo objectForKey: @"SSID"];

            if (network)
            {
                self.currentNetworkName = network;
                [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: 0 inSection: 0]] withRowAnimation: UITableViewRowAnimationAutomatic];
            }
            
            // request wifi scan
            [honeybee requestWifiScan:^(NSDictionary *network, NSError *error) {
                
                NSArray* oldNetworkNames = [self.scannedNetworks.allKeys sortedArrayUsingSelector: @selector(compare:)];

                NSString* name = network[@"SSID"];
                
                if (name.length > 0)
                {
                    NSMutableDictionary* networks = [self.scannedNetworks mutableCopy];
                    networks[name] = network;
                    
                    self.scannedNetworks = networks;
                    
                    if ([oldNetworkNames containsObject: name])
                        [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: [oldNetworkNames indexOfObject: name] inSection: 1]] withRowAnimation: UITableViewRowAnimationAutomatic];
                    else
                        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex: 1] withRowAnimation: UITableViewRowAnimationAutomatic];
                    
                }
                
            }];
        }];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
// current network and known networks
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch(section)
    {
        case 0:
        {
            return 1;
        }
        case 1:
        {
            return self.scannedNetworks.count + 0;
        }
    }
    
    return 0;
}


- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    
    switch(indexPath.section)
    {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CurrentNetwork" forIndexPath: indexPath];
            
            cell.textLabel.text = self.currentNetworkName;

            return cell;
        }
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"FoundNetwork" forIndexPath: indexPath];
            
            NSArray* networkNames = [self.scannedNetworks.allKeys sortedArrayUsingSelector: @selector(compare:)];
            cell.textLabel.text = networkNames[indexPath.row];

            return cell;
        }
    }
    
    return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Current Network";
        case 1:
            return @"Scan Results";
        default:
            return nil;
    }
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

- (NSArray*) networkNames
{
    NSArray* networkNames = [self.scannedNetworks.allKeys sortedArrayUsingSelector: @selector(compare:)];
    
    return networkNames;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 1:
        {
            NSArray* names = [self networkNames];
            NSString* name = names[indexPath.row];
            
            NSDictionary* network = self.scannedNetworks[name];
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Enter Passcode" message: [NSString stringWithFormat: @"for network '%@'", name] preferredStyle: UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler: ^(UITextField * _Nonnull textField) {
                textField.placeholder = @"<passcode>";
            }];
            

            [alert addAction: [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: ^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alert addAction: [UIAlertAction actionWithTitle: @"Connect" style: UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
                UITextField* passField = alert.textFields[0];
                
                NSString* password = passField.text;
                
                NSMutableDictionary* netDict = network.mutableCopy;
                
                netDict[@"key"] = password;
                
                [self.honeybee joinNetwork: netDict];
            }]];
            
            [self presentViewController: alert animated: YES completion: ^{
            }];
            
            
            break;
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
