//
//  SimulatorViewCtrl.m
//  MemSimulator
//
//  Created by Stanley on 12/2/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import "SimulatorViewCtrl.h"
#import "DetailViewCtrl.h"

@interface SimulatorViewCtrl ()

@end

@implementation SimulatorViewCtrl

@synthesize txtDecimalAddr;
@synthesize txtHeximalAddr;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.detailViewCtrl = (DetailViewCtrl*)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"confirmAccess"]) {
        return YES;
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //DetailViewCtrl* detailView = (DetailViewCtrl*)[segue.destinationViewController topViewController];
    if ([txtDecimalAddr.text isEqualToString:@""] == NO) {
        //[detailView setMemoryAccessWithDecimalAddress:txtDecimalAddr.text.integerValue];
        [self.detailViewCtrl setMemoryAccessWithDecimalAddress:txtDecimalAddr.text.integerValue];
    }
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/
/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
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
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Delegate
- (IBAction)btnAccessClick:(id)sender {
    [self.detailViewCtrl setMemoryAccessWithDecimalAddress:txtDecimalAddr.text.integerValue];
}

- (IBAction)btnResetClick:(id)sender {
    [self.detailViewCtrl resetSimulator];
}

#pragma  mark- Text Edit Delegate
- (IBAction)txtDecimalEditChanged:(id)sender {
    [txtHeximalAddr setText:[self getHexStringFromDecString:txtDecimalAddr.text]];
}

- (IBAction)txtHeximalEditChanged:(id)sender {
    if (txtHeximalAddr.text.length >= 2) {
        [txtHeximalAddr setText:[NSString stringWithFormat:@"0x%@",[txtHeximalAddr.text substringFromIndex:2].uppercaseString]];
    }
    [txtDecimalAddr setText:[self getDecStringFromHexString:txtHeximalAddr.text]];
}

#pragma mark - Private Function
- (NSString*)getHexStringFromDecString:(NSString*)decimalString {
    return [NSString stringWithFormat:@"0x%@",[NSString stringWithFormat:@"%lx",(long)decimalString.integerValue].uppercaseString];
}

- (NSString*)getDecStringFromHexString:(NSString*)heximalString {
    unsigned long long result = 0;
    NSScanner* scanner = [NSScanner scannerWithString:heximalString];
    [scanner setScanLocation:0];

    [scanner scanHexLongLong:&result];
    return [NSString stringWithFormat:@"%lld",result];
}

@end
