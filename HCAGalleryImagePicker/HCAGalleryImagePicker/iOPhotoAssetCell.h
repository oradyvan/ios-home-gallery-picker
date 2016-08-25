//
//  iOPhotoAssetCell.h
//  iO
//
//  Created by Vadym Pilkevych on 31/12/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOPhotoAssetSelectionMarkerView.h"


@interface iOPhotoAssetCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (void)setSelectionNumber:(NSUInteger)number;

@end
