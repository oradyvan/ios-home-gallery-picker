//
//  iOPhotoAsset.m
//  iO
//
//  Created by Vadym Pilkevych on 04/01/16.
//  Copyright © 2016 NGTI. All rights reserved.
//

#import "iOPhotoAsset.h"


#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


@interface iOPhotoAsset ()

@property (nonatomic, strong, readwrite) PHAsset *photoAsset;
@property (atomic, assign) PHImageRequestID imageRequestID;

@end


@implementation iOPhotoAsset

- (instancetype)initWithAsset:(PHAsset *)photoAsset
{
    self = [super init];
    if (self)
    {
        _photoAsset = photoAsset;
        _imageRequestID = PHInvalidImageRequestID;
    }
    return self;
}

#pragma mark - Public

- (void)requestImageOfSize:(CGSize)size
           progressHandler:(PHAssetImageProgressHandler)progressBlock
             resultHandler:(iOPhotoAssetRequestResultHandler)resultBlock
{
    [self cancelImageRequest];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.progressHandler = progressBlock;
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    
    self.imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:self.photoAsset
                                                                     targetSize:size
                                                                    contentMode:PHImageContentModeAspectFit
                                                                        options:options
                                                                  resultHandler:resultBlock];
}

- (void)cancelImageRequest
{
    if (self.imageRequestID != PHInvalidImageRequestID)
    {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        self.imageRequestID = PHInvalidImageRequestID;
    }
}

@end
