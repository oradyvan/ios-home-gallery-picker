//
//  iOPhotoAssetsDataSource.h
//  iO
//
//  Created by Vadym Pilkevych on 11/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


typedef void (^iOPhotoAssetsDataSourceLibraryChangeBlock)(PHChange *changeInfo);


@interface iOPhotoAssetsDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, readonly) NSMutableOrderedSet<NSIndexPath *> *selectedAssetIndexPaths;
@property (nonatomic, copy) iOPhotoAssetsDataSourceLibraryChangeBlock photoLibraryChangeHandler;

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathOfAsset:(PHAsset *)asset;
- (NSUInteger)numberOfSelectedAssets;
- (NSArray<PHAsset *> *)selectedAssets;
- (void)selectAssetAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectAssetAtIndexPath:(NSIndexPath *)indexPath;

@end
