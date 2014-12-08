//
//  ResultCellCtrl.h
//  MemSimulator
//
//  Created by Stanley on 12/8/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultCellCtrl : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblSeq;
@property (weak, nonatomic) IBOutlet UILabel *lblDecVa;
@property (weak, nonatomic) IBOutlet UILabel *lblHexVa;
@property (weak, nonatomic) IBOutlet UILabel *lblDecPn;
@property (weak, nonatomic) IBOutlet UILabel *lblHexPn;
@property (weak, nonatomic) IBOutlet UILabel *lblDecOffset;
@property (weak, nonatomic) IBOutlet UILabel *lblHexOffset;
@property (weak, nonatomic) IBOutlet UILabel *lblDecFn;
@property (weak, nonatomic) IBOutlet UILabel *lblHexFn;
@property (weak, nonatomic) IBOutlet UILabel *lblDecPa;
@property (weak, nonatomic) IBOutlet UILabel *lblHexPa;
@property (weak, nonatomic) IBOutlet UILabel *lblTlbHit;
@property (weak, nonatomic) IBOutlet UILabel *lblPageHit;

- (void)setResultListItem:(NSDictionary*)resultItem;

@end
