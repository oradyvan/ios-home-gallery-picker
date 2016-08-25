//
//  MMVAssetLibrary.m
//  MMVImagePickerController
//
//  Created by Maksym Malyhin on 11/5/14.
//  Copyright (c) 2014 Maxim Malyhin. All rights reserved.
//

#import "HCAAssetsLibrary.h"

@implementation HCAAssetsLibrary

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _assetsLibrary = [ALAssetsLibrary new];
    }
    return self;
}

- (void)allGroupsWithType:(ALAssetsGroupType)type completion:(HCAAssetsLibraryGroupsCompletionBlock)completion
{
    __block NSMutableArray *groups = nil;
    [self.assetsLibrary enumerateGroupsWithTypes:type usingBlock:^(ALAssetsGroup *group, BOOL *stop)
    {
        if (!groups)
        {
            groups = [NSMutableArray new];
        }
        
        if ([group numberOfAssets] > 0)
        {
            [groups addObject:group];
        }
        else if (completion)
        {
            completion(groups, nil);
        }
        
    } failureBlock:^(NSError *error)
    {
        if (completion)
        {
            completion(nil, error);
        }
    }];
}

+ (void)allAssetsFromGroup:(ALAssetsGroup *)group completion:(HCAAssetsLibraryPhotosCompletionBlock)completion
{
    __block NSMutableArray *assets = [NSMutableArray arrayWithCapacity:group.numberOfAssets];
    
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
    {
        if (result)
        {
            [assets addObject:result];
        }
        else if (completion)
        {
            completion([assets copy]);
        }
        
    }];
}

@end
