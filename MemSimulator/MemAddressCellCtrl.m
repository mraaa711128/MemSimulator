//
//  MemAddressCellCtrl.m
//  MemSimulator
//
//  Created by Stanley on 12/6/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import "MemAddressCellCtrl.h"

@implementation MemAddressCellCtrl

@synthesize lblFrameNo;
@synthesize viewOffsets;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMemAddressInfo:(NSDictionary *)memAddressInfo {
    NSNumber* frameNo = [memAddressInfo objectForKey:@"frameno"];
    [lblFrameNo setText:[NSString stringWithFormat:@"%ld (0x%lx)",frameNo.integerValue,frameNo.integerValue]];
    NSArray* arrOffsets = [memAddressInfo objectForKey:@"offsets"];
    NSArray* arrColors = [memAddressInfo objectForKey:@"colors"];
    for (UIView* view in viewOffsets.subviews) {
        [view removeFromSuperview];
    }
    for (int i = 0; i < arrOffsets.count; i++) {
        NSNumber* offset = [arrOffsets objectAtIndex:i];
        NSString* strOffset = [NSString stringWithFormat:@"%ld (0x%lx)",offset.integerValue,offset.integerValue];
        CGFloat dy = (i / 2)*21.0 + 5.0;
        CGFloat dx = (i % 2)*(viewOffsets.frame.size.width / 2.0);
        UILabel* lblOffset = [[UILabel alloc] initWithFrame:CGRectMake(dx, dy, viewOffsets.frame.size.width / 2.0, 21.0)];
        [lblOffset setText:strOffset];
        if (arrColors.count == arrOffsets.count) {
            NSDictionary* color = [arrColors objectAtIndex:i];
            NSNumber* red = [color objectForKey:@"red"];
            NSNumber* green = [color objectForKey:@"green"];
            NSNumber* blue = [color objectForKey:@"blue"];
            lblOffset.backgroundColor = [UIColor colorWithRed:(CGFloat)(red.floatValue / 255.0) green:(CGFloat)(green.floatValue / 255.0) blue:(CGFloat)(blue.floatValue / 255.0) alpha:1.0];
        }
        [viewOffsets addSubview:lblOffset];
    }
}

@end
