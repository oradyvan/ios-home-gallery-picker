//
//  HCACollectionViewCell.h
//  HomeCenter
//
//  Created by Maksym Malyhin on 11/6/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

@interface HCAImageCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic, readonly) UIImageView *imageView;

@property (nonatomic) PHImageRequestID imageRequestId;
@property (nonatomic) NSString *assetId;

@end
