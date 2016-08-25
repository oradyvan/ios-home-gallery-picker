//
//  iOPhotoAssetCell.m
//  iO
//
//  Created by Vadym Pilkevych on 31/12/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "iOPhotoAssetCell.h"

#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


@interface iOPhotoAssetCell ()

@property (nonatomic, strong) IBOutlet iOPhotoAssetSelectionMarkerView *selectionMarkerView;

@end

@implementation iOPhotoAssetCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.selectionMarkerView.hidden = YES;
    [self setSelected:NO];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.selectionMarkerView.hidden = !selected;
}

#pragma mark - Public

- (void)setSelectionNumber:(NSUInteger)number
{
    [self.selectionMarkerView setTitle:[NSString stringWithFormat:@"%d", (int)number]];
}

@end
