//
//  SimulatorViewCtrl.h
//  MemSimulator
//
//  Created by Stanley on 12/2/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewCtrl.h"

@interface SimulatorViewCtrl : UITableViewController

@property (strong, nonatomic) DetailViewCtrl* detailViewCtrl;

@property (weak, nonatomic) IBOutlet UITextField *txtDecimalAddr;
@property (weak, nonatomic) IBOutlet UITextField *txtHeximalAddr;

- (IBAction)btnAccessClick:(id)sender;
- (IBAction)btnResetClick:(id)sender;
- (IBAction)txtDecimalEditChanged:(id)sender;
- (IBAction)txtHeximalEditChanged:(id)sender;

@end
