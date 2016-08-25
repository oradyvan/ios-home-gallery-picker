//
//  HCAAssetCollection.m
//  HCAGalleryImagePicker
//
//  Created by Nikita Ivaniushchenko on 6/3/16.
//  Copyright © 2016 Swisscom. All rights reserved.
//

#import "HCAAssetCollection.h"

@interface HCAAssetCollection()

@property (nonatomic, strong, readwrite) PHAssetCollection *collection;
@property (nonatomic, strong, readwrite) PHAsset *lastAsset;
@property (nonatomic, assign, readwrite) NSUInteger assetCount;

@end

@implementation HCAAssetCollection

- (id)initWithCollection:(PHAssetCollection *)collection assets:(PHFetchResult *)assets
{
    if (self = [super init])
    {
        self.collection = collection;
        self.lastAsset = assets.firstObject; //Because fetch request passed here uses defaultAssetsFetchOptions
        self.assetCount = assets.count;
    }
    
    return self;
}

+ (PHFetchOptions *)defaultAssetsFetchOptions
{
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    fetchOptions.sortDescriptors = @[sortDescriptor];
    
    return fetchOptions;
}

@end
