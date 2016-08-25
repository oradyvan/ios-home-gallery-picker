//
//  MMVAssetLibrary.h
//  MMVImagePickerController
//
//  Created by Maksym Malyhin on 11/5/14.
//  Copyright (c) 2014 Maxim Malyhin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^HCAAssetsLibraryGroupsCompletionBlock)(NSArray *groups, NSError *error);
typedef void(^HCAAssetsLibraryPhotosCompletionBlock)(NSArray *assets);

@interface HCAAssetsLibrary : NSObject

@property (nonatomic, readonly) ALAssetsLibrary *assetsLibrary;

- (void)allGroupsWithType:(ALAssetsGroupType)type completion:(HCAAssetsLibraryGroupsCompletionBlock)completion;
+ (void)allAssetsFromGroup:(ALAssetsGroup *)group completion:(HCAAssetsLibraryPhotosCompletionBlock)completion;

@end
