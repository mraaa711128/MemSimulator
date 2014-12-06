//
//  PageListCellCtrl.m
//  MemSimulator
//
//  Created by Stanley on 12/6/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import "PageListCellCtrl.h"

@implementation PageListCellCtrl

@synthesize lblFrameNo;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPageInfo:(NSDictionary *)pageInfo {
    NSNumber* frameno = [pageInfo objectForKey:@"frameno"];
    
    if (frameno.integerValue >= 0) {
        [lblFrameNo setText:[NSString stringWithFormat:@"%ld (0x%lx)",frameno.integerValue,frameno.integerValue]];
    } else {
        [lblFrameNo setText:@""];
    }
}
@end
