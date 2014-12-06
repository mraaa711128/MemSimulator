//
//  PageListCellCtrl.h
//  MemSimulator
//
//  Created by Stanley on 12/6/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageListCellCtrl : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblFrameNo;
@property (weak, nonatomic) IBOutlet UIView *viewColor;

- (void)setPageInfo:(NSDictionary*)pageInfo;

@end
