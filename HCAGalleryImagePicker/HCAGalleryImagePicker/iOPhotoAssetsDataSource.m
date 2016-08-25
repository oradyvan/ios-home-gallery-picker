//
//  iOPhotoAssetsDataSource.m
//  iO
//
//  Created by Vadym Pilkevych on 11/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import "iOPhotoAssetsDataSource.h"
#import "iOPhotoAssetCell.h"

@import HCAUtils;

#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


static NSString * const kCellReuseIdentifier = @"Cell";


@interface iOPhotoAssetsDataSource () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;
@property (nonatomic, strong, readwrite) NSMutableOrderedSet<NSIndexPath *> *selectedAssetIndexPaths;

@end

@implementation iOPhotoAssetsDataSource

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Public

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath
{
    return self.fetchResult[indexPath.item];
}

- (NSIndexPath *)indexPathOfAsset:(PHAsset *)asset
{
    NSIndexPath *indexPath = nil;
    
    NSUInteger index = [self.fetchResult indexOfObject:asset];
    if (index != NSNotFound)
    {
        indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    }
    
    return indexPath;
}

- (NSUInteger)numberOfSelectedAssets
{
    return self.selectedAssetIndexPaths.count;
}

- (NSArray<PHAsset *> *)selectedAssets
{
    NSMutableArray *selectedAssets = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in self.selectedAssetIndexPaths)
    {
        PHAsset *asset = self.fetchResult[indexPath.item];
        if (asset)
        {
            [selectedAssets addObject:asset];
        }
    }
    
    return [selectedAssets copy];
}

- (void)selectAssetAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedAssetIndexPaths addObject:indexPath];
}

- (void)deselectAssetAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedAssetIndexPaths removeObject:indexPath];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = [self assetAtIndexPath:indexPath];
    
    iOPhotoAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    NSUInteger index = [self.selectedAssetIndexPaths indexOfObject:indexPath];
    BOOL cellIsSelected = (index != NSNotFound);
    if (cellIsSelected)
    {
        NSUInteger selectionNumber = index + 1;
        [cell setSelectionNumber:selectionNumber];
        
        [cell setSelected:YES];
    }
    
    cell.imageView.image = nil;
    
    [self requestImageForAsset:asset inCollectionView:collectionView];
    
    return cell;
}

- (void)requestImageForAsset:(PHAsset *)asset inCollectionView:(UICollectionView *)collectionView
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:self.itemSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         if ([info[PHImageCancelledKey] boolValue])
         {
             return;
         }
         
         if (info[PHImageErrorKey])
         {
#ifdef DEBUG
             NSLog(@"Error loading an image from Photo Library. %@", info[PHImageErrorKey]);
#endif
             return;
         }
         
         if (!result)
         {
             return;
         }
         
         __typeof(self) __weak weakSelf = self;
         UICollectionView * __weak weakCollectionView = collectionView;
         
         dispatch_async(dispatch_get_main_queue(), ^
         {
             NSIndexPath *indexPath = [weakSelf indexPathOfAsset:asset];
             if (indexPath)
             {
                 iOPhotoAssetCell *cell = (iOPhotoAssetCell *)[weakCollectionView cellForItemAtIndexPath:indexPath];
                 if (cell)
                 {
                     cell.imageView.image = result;
                 }
             }
         });
     }];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        PHObjectChangeDetails *collectionChanges = [changeInstance changeDetailsForObject:self.assetCollection];
        if (collectionChanges)
        {
            self.assetCollection = collectionChanges.objectAfterChanges;
        }
        
        PHFetchResultChangeDetails *fetchResultChanges = [changeInstance changeDetailsForFetchResult:self.fetchResult];
        if (fetchResultChanges)
        {
            self.fetchResult = fetchResultChanges.fetchResultAfterChanges;
        }
        
        if (self.photoLibraryChangeHandler)
        {
            self.photoLibraryChangeHandler(changeInstance);
        }
    });
}

#pragma mark - Accessors

- (PHFetchResult<PHAsset *> *)fetchResult
{
    if (_fetchResult == nil)
    {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"mediaType == %ld", (long)PHAssetMediaTypeImage]];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        _fetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection
                                                     options:options];
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    
    return _fetchResult;
}

- (NSMutableOrderedSet *)selectedAssetIndexPaths
{
    if (_selectedAssetIndexPaths == nil)
    {
        _selectedAssetIndexPaths = [NSMutableOrderedSet orderedSet];
    }
    
    return _selectedAssetIndexPaths;
}

@end
