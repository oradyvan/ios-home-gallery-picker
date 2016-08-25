//
//  HCACollectionViewCell.m
//  HomeCenter
//
//  Created by Maksym Malyhin on 11/6/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "HCAImageCollectionViewCell.h"

#import "HCAGalleryImagePicker.h"

@interface HCAImageCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *selectionOverlayView;

@end

@implementation HCAImageCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionOverlayView.hidden = YES;
}

- (void)setSelected:(BOOL)selected
{
    self.selectionOverlayView.hidden = !selected;
    
    [super setSelected:selected];
}

@end
