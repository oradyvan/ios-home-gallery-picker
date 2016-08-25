//
//  iOPhotoAsset.h
//  iO
//
//  Created by Vadym Pilkevych on 04/01/16.
//  Copyright © 2016 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


typedef void (^iOPhotoAssetRequestResultHandler)(UIImage *result, NSDictionary *info);


/**
 *  Represents a model object for a photo asset. Should be used from UI.
 */
@interface iOPhotoAsset : NSObject

@property (nonatomic, readonly) PHAsset *photoAsset;

- (instancetype)initWithAsset:(PHAsset *)photoAsset;

/**
 *  Requests an image representation for the current photo asset. Currently supports only a single request at a time. Cancels the previous request if reqested again.
 *
 *  @param size            The target size of image to be returned.
 *  @param progressBlock   A block that Photos calls periodically while downloading the image.
 *  @param resultBlock     A block to be called when image loading is complete, providing the requested image or information about the status of the request. Can be called multiple times.
 */
- (void)requestImageOfSize:(CGSize)size
           progressHandler:(PHAssetImageProgressHandler)progressBlock
             resultHandler:(iOPhotoAssetRequestResultHandler)resultBlock;

- (void)cancelImageRequest;

@end
