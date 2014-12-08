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
    
    [self.lblSeq setText:[NSString stringWithFormat:@"%ld",seq.integerValue]];
    [self.lblDecVa setText:[NSString stringWithFormat:@"%ld (%ld)",pageno.integerValue,offset.integerValue]];
    [self.lblHexVa setText:[NSString stringWithFormat:@"0x%lx (0x%lx)",pageno.integerValue,offset.integerValue]];
    [self.lblDecPn setText:[NSString stringWithFormat:@"%ld",pageno.integerValue]];
    [self.lblHexPn setText:[NSString stringWithFormat:@"0x%lx",pageno.integerValue]];
    [self.lblDecOffset setText:[NSString stringWithFormat:@"%ld",offset.integerValue]];
    [self.lblHexOffset setText:[NSString stringWithFormat:@"0x%lx",offset.integerValue]];
    [self.lblDecFn setText:[NSString stringWithFormat:@"%ld",frameno.integerValue]];
    [self.lblHexFn setText:[NSString stringWithFormat:@"0x%lx",frameno.integerValue]];
    [self.lblDecPa setText:[NSString stringWithFormat:@"%ld (%ld)",frameno.integerValue,offset.integerValue]];
    [self.lblHexPa setText:[NSString stringWithFormat:@"0x%lx (0x%lx)",frameno.integerValue,offset.integerValue]];
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
}
@end
