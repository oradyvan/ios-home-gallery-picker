//
//  iOPhotoAssetPreviewController.m
//  iO
//
//  Created by Vadym Pilkevych on 04/01/16.
//  Copyright © 2016 NGTI. All rights reserved.
//

#import "iOPhotoAssetPreviewController.h"

@import HCAUI;
@import HCAUtils;


#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


static CGFloat const kProgressViewOffset = 12.0f;


@interface iOPhotoAssetPreviewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *selectBarButtonItem;

@property (nonatomic, strong) IBOutlet iOProgressView *progressView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *progressViewTrailingSpaceConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *progressViewBottomSpaceConstraint;

@end

@implementation iOPhotoAssetPreviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeUI];
    
    [self setupProgressView];
}

- (void)viewDidLayoutSubviews
{
    [self updateProgressViewLayout];
    
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __typeof(self) __weak weakSelf = self;
    
    [self.photoAsset requestImageOfSize:self.imageView.bounds.size
                        progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             if (error)
             {
                 weakSelf.progressView.hidden = YES;
             }
             else
             {
                 weakSelf.progressView.hidden = NO;
                 weakSelf.progressView.progress = (CGFloat)progress;
             }
         });
     }
     resultHandler:^(UIImage *result, NSDictionary *info)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             weakSelf.progressView.hidden = YES;
             
             if (result)
             {
                 weakSelf.imageView.image = result;
             }
         });
     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.photoAsset cancelImageRequest];
}

#pragma mark - Private

- (void)localizeUI
{
    self.selectBarButtonItem.title = NSLocalizedString(@"lblSelect", nil);
}

- (void)setupProgressView
{
    self.progressView.progressViewType = iOProgressViewTypePie;
    self.progressView.progressTintColor = [UIColor clearColor];
    self.progressView.trackTintColor = [UIColor whiteColor];
}

- (void)updateProgressViewLayout
{
    // Frame of the image, not the image view!
    CGRect imageFrame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    imageFrame = CGRectAspectFitInRect(imageFrame, self.imageView.frame);
    
    if (CGRectIsNan(imageFrame))
    {
        imageFrame = self.view.bounds;
    }
    
    self.progressViewTrailingSpaceConstraint.constant = kProgressViewOffset + CGRectGetMaxX(self.imageView.frame) - CGRectGetMaxX(imageFrame);
    self.progressViewBottomSpaceConstraint.constant = kProgressViewOffset + CGRectGetMaxY(self.imageView.frame) - CGRectGetMaxY(imageFrame);
    
    [self.view layoutIfNeeded];
}

#pragma mark - Actions

- (IBAction)selectBarButtonItemDidPress:(UIBarButtonItem *)button
{
    [self.delegate iOPhotoAssetPreviewControllerDidSelect:self];
}

@end
