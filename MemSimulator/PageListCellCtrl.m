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
@synthesize viewColor;

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
        [lblFrameNo setText:[NSString stringWithFormat:@"%ld (0x%lx)",(long)frameno.integerValue,(long)frameno.integerValue]];
    } else {
        [lblFrameNo setText:@""];
    }
    
    NSDictionary* color = [pageInfo objectForKey:@"color"];
    NSNumber* red = [color objectForKey:@"red"];
    NSNumber* green = [color objectForKey:@"green"];
    NSNumber* blue = [color objectForKey:@"blue"];
    viewColor.backgroundColor = [UIColor colorWithRed:(CGFloat)(red.floatValue / 255.0) green:(CGFloat)(green.floatValue / 255.0) blue:(CGFloat)(blue.floatValue / 255.0) alpha:1.0];

}
@end
