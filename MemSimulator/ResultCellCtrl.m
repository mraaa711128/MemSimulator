//
//  ResultCellCtrl.m
//  MemSimulator
//
//  Created by Stanley on 12/8/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import "ResultCellCtrl.h"

@implementation ResultCellCtrl

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setResultListItem:(NSDictionary *)resultItem {
    NSNumber* seq = [resultItem objectForKey:@"seq"];
    NSNumber* pageno = [resultItem objectForKey:@"pageno"];
    NSNumber* frameno = [resultItem objectForKey:@"frameno"];
    NSNumber* offset = [resultItem objectForKey:@"offset"];
    NSNumber* tlbhit = [resultItem objectForKey:@"tlbhit"];
    NSNumber* pagehit = [resultItem objectForKey:@"pagehit"];
    NSDictionary* color = [resultItem objectForKey:@"color"];
    
    [self.lblSeq setText:[NSString stringWithFormat:@"%ld",(long)seq.integerValue]];
    [self.lblDecVa setText:[NSString stringWithFormat:@"%ld (%ld)",(long)pageno.integerValue,(long)offset.integerValue]];
    [self.lblHexVa setText:[NSString stringWithFormat:@"0x%lx (0x%lx)",(long)pageno.integerValue,(long)offset.integerValue]];
    [self.lblDecPn setText:[NSString stringWithFormat:@"%ld",(long)pageno.integerValue]];
    [self.lblHexPn setText:[NSString stringWithFormat:@"0x%lx",(long)pageno.integerValue]];
    [self.lblDecOffset setText:[NSString stringWithFormat:@"%ld",(long)offset.integerValue]];
    [self.lblHexOffset setText:[NSString stringWithFormat:@"0x%lx",(long)offset.integerValue]];
    [self.lblDecFn setText:[NSString stringWithFormat:@"%ld",(long)frameno.integerValue]];
    [self.lblHexFn setText:[NSString stringWithFormat:@"0x%lx",(long)frameno.integerValue]];
    [self.lblDecPa setText:[NSString stringWithFormat:@"%ld (%ld)",(long)frameno.integerValue,(long)offset.integerValue]];
    [self.lblHexPa setText:[NSString stringWithFormat:@"0x%lx (0x%lx)",(long)frameno.integerValue,(long)offset.integerValue]];
    NSString* strTlbHit;
    if (tlbhit == [NSNumber numberWithBool:YES]) {
        strTlbHit = @"Hit";
    } else {
        strTlbHit = @"Miss";
    }
    [self.lblTlbHit setText:strTlbHit];
    
    NSString* strPageHit;
    if (pagehit == [NSNumber numberWithBool:YES]) {
        if (tlbhit == [NSNumber numberWithBool:YES]) {
            strPageHit = @"";
        } else {
            strPageHit = @"Hit";
        }
    } else {
        strPageHit = @"Fault";
    }
    [self.lblPageHit setText:strPageHit];
    
    NSNumber* red = [color objectForKey:@"red"];
    NSNumber* green = [color objectForKey:@"green"];
    NSNumber* blue = [color objectForKey:@"blue"];

    self.lblSeq.backgroundColor = [UIColor colorWithRed:(CGFloat)(red.floatValue / 255.0) green:(CGFloat)(green.floatValue / 255.0) blue:(CGFloat)(blue.floatValue / 255.0) alpha:1.0];
    self.lblSeq.textColor = [UIColor whiteColor];
}
@end
