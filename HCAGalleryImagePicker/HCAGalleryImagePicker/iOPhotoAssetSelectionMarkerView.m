//
//  iOPhotoAssetSelectionMarkerView.m
//  iO
//
//  Created by Vadym Pilkevych on 06/05/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "iOPhotoAssetSelectionMarkerView.h"

@import HCAUI;


#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


#define kViewSize CGSizeMake(24, 24)
#define kTitleFontSize 14.f
#define kBackgroundImageName @"AssetSelectionCircle"

@interface iOPhotoAssetSelectionMarkerView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation iOPhotoAssetSelectionMarkerView

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        [self commonInit];
        
        _titleLabel.text = title;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return kViewSize;
}

#pragma mark - Public

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    
    [self setNeedsLayout];
}

#pragma mark - Private

- (void)commonInit
{
    [self constructSubviews];
    [self setupView];
}

- (void)setupView
{
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize weight:UIFontWeightLight];
}

- (void)constructSubviews
{
    UIImage *image = [UIImage imageNamed:kBackgroundImageName];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:backgroundImageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    self.titleLabel = label;
    
    [backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeTop toItem:self],
                           [NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeBottom toItem:self],
                           [NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeLeft toItem:self],
                           [NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeRight toItem:self]]];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX toItem:self],
                           [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY toItem:self]]];
}

@end
