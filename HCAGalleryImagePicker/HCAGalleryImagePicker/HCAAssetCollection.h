//
//  HCAAssetCollection.h
//  HCAGalleryImagePicker
//
//  Created by Nikita Ivaniushchenko on 6/3/16.
//  Copyright © 2016 Swisscom. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Photos;

@interface HCAAssetCollection : NSObject

@property (nonatomic, strong, readonly) PHAssetCollection *collection;
@property (nonatomic, strong, readonly) PHAsset *lastAsset; // Latest by creationDate 
@property (nonatomic, assign, readonly) NSUInteger assetCount;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithCollection:(PHAssetCollection *)collection assets:(PHFetchResult *)assets NS_DESIGNATED_INITIALIZER;

+ (PHFetchOptions *)defaultAssetsFetchOptions;

@end
