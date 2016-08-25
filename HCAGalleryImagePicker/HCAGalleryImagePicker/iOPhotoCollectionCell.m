//
//  iOPhotoCollectionCell.m
//  iO
//
//  Created by Vadym Pilkevych on 10/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import "iOPhotoCollectionCell.h"

#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


@implementation iOPhotoCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
    self.countLabel.font = [UIFont systemFontOfSize:12.f weight:UIFontWeightRegular];
}

@end
