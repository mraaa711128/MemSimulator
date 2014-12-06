//
//  DetailViewCtrl.h
//  MemSimulator
//
//  Created by Stanley on 12/3/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewCtrl : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tabMemAccessList;
@property (weak, nonatomic) IBOutlet UITableView *tabTlbList;
@property (weak, nonatomic) IBOutlet UITableView *tabPageList;
@property (weak, nonatomic) IBOutlet UITableView *tabMemAddress;

- (void)resetSimulator;
- (void)setMemoryAccessWithDecimalAddress:(NSInteger)decAddress;

@end
