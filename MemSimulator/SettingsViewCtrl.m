//
//  SettingsViewCtrl.m
//  MemSimulator
//
//  Created by Stanley on 12/2/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import "SettingsViewCtrl.h"
#import "DetailViewCtrl.h"

@interface SettingsViewCtrl ()

@end

@implementation SettingsViewCtrl

@synthesize txtMemorySize;
@synthesize txtPageSize;
@synthesize txtTlbSize;
@synthesize txtTlbAlgorithm;
@synthesize txtPageAlgorithm;
@synthesize txtFrameAvailable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.detailViewCtrl = (DetailViewCtrl*)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    [txtMemorySize setText:[NSString stringWithFormat:@"%@",[settings objectForKey:@"memorysize"]]];
    [txtPageSize setText:[NSString stringWithFormat:@"%@",[settings objectForKey:@"pagesize"]]];
    [txtTlbSize setText:[NSString stringWithFormat:@"%@",[settings objectForKey:@"tlbsize"]]];
    [txtTlbAlgorithm setText:[settings objectForKey:@"tlbalgorithm"]];
    [txtPageAlgorithm setText:[settings objectForKey:@"pagealgorithm"]];
    [txtFrameAvailable setText:[settings objectForKey:@"frameavailable"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"confirmSettings"]) {
        return YES;
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //DetailViewCtrl* detailView = (DetailViewCtrl*)[segue.destinationViewController topViewController];
    //[detailView resetSimulator];
    [self.detailViewCtrl resetSimulator];
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

- (IBAction)btnConfirmClick:(id)sender {
    @try {
        NSNumber* memorySize = [NSNumber numberWithInteger:txtMemorySize.text.integerValue];
        NSNumber* pageSize = [NSNumber numberWithInteger:txtPageSize.text.integerValue];
        NSNumber* tlbSize = [NSNumber numberWithInteger:txtTlbSize.text.integerValue];
        if (pageSize <= 0) {
            @throw [NSException exceptionWithName:@"pageSizeZero" reason:@"Page Size Can't be Zero" userInfo:nil];
        }
        if (memorySize < pageSize) {
            @throw [NSException exceptionWithName:@"memorySizeLessPageSize" reason:@"Memory Size Can't Less than Page Size" userInfo:nil];
        }
        
        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:memorySize forKey:@"memorysize"];
        [settings setObject:pageSize forKey:@"pagesize"];
        [settings setObject:tlbSize forKey:@"tlbsize"];
        [settings setObject:txtTlbAlgorithm.text forKey:@"tlbalgorithm"];
        [settings setObject:txtPageAlgorithm.text forKey:@"pagealgorithm"];
        [settings setObject:txtFrameAvailable.text forKey:@"frameavailable"];
        [settings synchronize];
        
        //[self performSegueWithIdentifier:@"confirmSettings" sender:self];
        [self.detailViewCtrl resetSimulator];        
    }
    @catch (NSException *exception) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[exception description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)btnResetClick:(id)sender {
}

@end
