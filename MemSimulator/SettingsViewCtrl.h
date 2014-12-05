//
//  SettingsViewCtrl.h
//  MemSimulator
//
//  Created by Stanley on 12/2/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewCtrl.h"

@interface SettingsViewCtrl : UITableViewController

@property (strong, nonatomic) DetailViewCtrl* detailViewCtrl;

@property (weak, nonatomic) IBOutlet UITextField *txtMemorySize;
@property (weak, nonatomic) IBOutlet UITextField *txtPageSize;
@property (weak, nonatomic) IBOutlet UITextField *txtTlbSize;
@property (weak, nonatomic) IBOutlet UITextField *txtTlbAlgorithm;
@property (weak, nonatomic) IBOutlet UITextField *txtPageAlgorithm;
@property (weak, nonatomic) IBOutlet UITextField *txtFrameAvailable;

- (IBAction)btnConfirmClick:(id)sender;
- (IBAction)btnResetClick:(id)sender;
@end
