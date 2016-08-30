//
//  UIImage+UIImagePicker.m
//  iO
//
//  Created by Nikita Ivaniushchenko on 9/1/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "UIImage+UIImagePicker.h"
#import "UIImage+Additions.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#if !__has_feature(objc_arc)
#error "ARC is required"
#endif

CGRect CGRectScale(CGRect rect, CGFloat scale)
{
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}

static NSUInteger kMaxImagePickerOutputResolution = 1000 * 1000 * 20;  //20 Mpx

@implementation UIImage (UIImagePicker)

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count)
{
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error)
    {
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info)
{
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
+ (UIImage *)io_thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size
{
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks =
    {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    NSDictionary *options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                              (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithUnsignedInteger:size],
                              (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES };
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)options);
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef)
    {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

+ (void)io_imageForImagePickerInfo:(NSDictionary *)imagePickerInfo completionHandler:(UIImageImagePickerCompletionHandler)completionHandler
{
    UIImage *image = [imagePickerInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    // crop rect determines how the image was edited after the picture has been taken by camera
    CGRect cropRect = [[imagePickerInfo valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    if (!CGRectIsEmpty(cropRect))
    {
        // don't take the edited image unless our own crop fails (which shouldn't happen)! it's buggy because crop rect is usually buggy

        // only use given crop rectangle when its extents are less than extents of the original image
        CGSize imageSize = image.size;
        CGSize cropSize = cropRect.size;

        // do not let crop rect be more than the original image bounds
        if (cropSize.width >= imageSize.width)
        {
            cropRect.origin.x = 0;
            cropRect.size.width = imageSize.width;
        }
        if (cropSize.height >= imageSize.height)
        {
            cropRect.origin.y = 0;
            cropRect.size.height = imageSize.height;
        }
        
        image = [image io_subImageAtFrame:cropRect];
        
        if (image == nil)
        {
            image = [imagePickerInfo objectForKey:UIImagePickerControllerEditedImage];
        }
    }

    NSUInteger longestEdge = MAX(image.size.width, image.size.height) * image.scale;
    NSUInteger imageResolution = image.size.width * image.size.height * (image.scale * image.scale);
    CGFloat resolutionScale = (float)imageResolution / kMaxImagePickerOutputResolution;
    CGFloat downscale = 1.f;
    
    while (resolutionScale > 1.f)
    {
        longestEdge /= 2.f;
        resolutionScale /= 4.f;
        
        downscale *= 2.f;
    }
    
    if (downscale > 1.f)
    {
        NSURL *assetURL = [imagePickerInfo objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *assetLibrary = [ALAssetsLibrary new];
        [assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset)
        {
            if (completionHandler)
            {
                UIImage *scaledImage = [UIImage io_thumbnailForAsset:asset maxPixelSize:longestEdge];
                
                if (!CGRectIsEmpty(cropRect))
                {
                    CGRect scaledCropRect = CGRectScale(cropRect, 1.f/downscale);
                    scaledImage = [scaledImage io_subImageAtFrame:scaledCropRect];
                }
                
                completionHandler(scaledImage);
            }
        }
        failureBlock:^(NSError *error)
        {
            if (completionHandler)
            {
                completionHandler(nil);
            }
        }];
    }
    else
    {
        if (completionHandler)
        {
            completionHandler(image);
        }
    }
}

@end
