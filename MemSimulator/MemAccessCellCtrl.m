//
//  MemAccessCellCtrl.m
//  MemSimulator
//
//  Created by Stanley on 12/5/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import "MemAccessCellCtrl.h"

@implementation MemAccessCellCtrl

@synthesize lblSeq;
@synthesize lblDecAddress;
@synthesize lblHexAddress;
@synthesize viewColor;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAccessInfo:(NSDictionary *)accessInfo {
    NSNumber* seq = [accessInfo objectForKey:@"seq"];
    NSNumber* pageno = [accessInfo objectForKey:@"pageno"];
    NSNumber* offset = [accessInfo objectForKey:@"offset"];
    NSString* decAddr = [NSString stringWithFormat:@"%ld (%ld)",pageno.integerValue,offset.integerValue];
    NSString* hexAddr = [NSString stringWithFormat:@"0x%lx (0x%lx)",pageno.integerValue,offset.integerValue];
    [lblSeq setText:[NSString stringWithFormat:@"%ld",seq.integerValue]];
    [lblDecAddress setText:decAddr];
    [lblHexAddress setText:hexAddr];
    
    NSDictionary* color = [accessInfo objectForKey:@"color"];
    NSNumber* red = [color objectForKey:@"red"];
    NSNumber* green = [color objectForKey:@"green"];
    NSNumber* blue = [color objectForKey:@"blue"];
    viewColor.backgroundColor = [UIColor colorWithRed:(CGFloat)(red.floatValue / 255.0) green:(CGFloat)(green.floatValue / 255.0) blue:(CGFloat)(blue.floatValue / 255.0) alpha:1.0];
}

@end
