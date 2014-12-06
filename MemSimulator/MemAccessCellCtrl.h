//
//  MemAccessCellCtrl.h
//  MemSimulator
//
//  Created by Stanley on 12/5/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemAccessCellCtrl : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblSeq;
@property (weak, nonatomic) IBOutlet UILabel *lblDecAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblHexAddress;
@property (weak, nonatomic) IBOutlet UIView *viewColor;

- (void)setAccessInfo:(NSDictionary*)accessInfo;

@end
