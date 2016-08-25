//
//  iOPhotoCollectionsDataSource.m
//  iO
//
//  Created by Vadym Pilkevych on 10/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import "iOPhotoCollectionsDataSource.h"
#import "iOPhotoCollectionCell.h"

@import HCAUtils;

#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


static NSString * const kCellReuseIdentifier = @"Cell";


@interface iOPhotoCollectionsDataSource () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *smartAlbumsFetchResult;
@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *albumsFetchResult;
@property (nonatomic, strong) NSArray<PHAssetCollection *> *photoAssetCollections; // Filtered and ordered collections from the fetch results

@end


@implementation iOPhotoCollectionsDataSource

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Public

- (PHAssetCollection *)assetCollectionAtIndexPath:(NSIndexPath *)indexPath
{
    if ((NSUInteger)indexPath.row >= self.photoAssetCollections.count)
    {
        return nil;
    }
    
    return self.photoAssetCollections[indexPath.row];
}

#pragma mark - Private

- (CGSize)collectionThumbnailSize
{
    return CGSizeMake(70.0f * UI_SCREEN_SCALE, 70.0f * UI_SCREEN_SCALE);
}

- (NSIndexPath *)indexPathOfCollection:(PHAssetCollection *)collection
{
    NSIndexPath * __block indexPath = nil;
    
    NSUInteger index = [self.photoAssetCollections indexOfObject:collection];
    if (index != NSNotFound)
    {
        indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    
    return indexPath;
}

#pragma mark - Photo asset collections list

- (PHFetchResult<PHAssetCollection *> *)smartAlbumsFetchResult
{
    if (_smartAlbumsFetchResult == nil)
    {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        // Filter by "estimatedAssetCount" doesn't work for smart albums :(
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES]];
        
        _smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                           subtype:PHAssetCollectionSubtypeAny
                                                                           options:options];
    }
    
    return _smartAlbumsFetchResult;
}

- (PHFetchResult<PHAssetCollection *> *)albumsFetchResult
{
    if (_albumsFetchResult == nil)
    {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES]];
        
        _albumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                      subtype:PHAssetCollectionSubtypeAny
                                                                      options:options];
    }
    
    return _albumsFetchResult;
}

- (NSArray<PHAssetCollection *> *)photoAssetCollections
{
    if (_photoAssetCollections == nil)
    {
        NSMutableArray<PHAssetCollection *> *mutableCollectionsArray = [NSMutableArray array];
        [mutableCollectionsArray addObjectsFromArray:[self smartAlbumPhotoAssetCollections]];
        [mutableCollectionsArray addObjectsFromArray:[self albumPhotoAssetCollections]];
        
        _photoAssetCollections = [mutableCollectionsArray copy];
    }
    
    return _photoAssetCollections;
}

- (NSArray<PHAssetCollection *> *)smartAlbumPhotoAssetCollections
{
    NSMutableArray<PHAssetCollection *> *smartAlbumsArray = [NSMutableArray array];
    NSMutableArray<PHAssetCollection *> *genericSmartAlbumsArray = [NSMutableArray array];
    
    [self.smartAlbumsFetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop)
    {
        switch (collection.assetCollectionSubtype)
        {
            case PHAssetCollectionSubtypeSmartAlbumUserLibrary:
            {
                if ([self collectionHasPhotoAssets:collection])
                {
                    [smartAlbumsArray insertObject:collection atIndex:0];
                }
                break;
            }
            case PHAssetCollectionSubtypeSmartAlbumPanoramas:
            case PHAssetCollectionSubtypeSmartAlbumFavorites:
            case PHAssetCollectionSubtypeSmartAlbumRecentlyAdded:
            case PHAssetCollectionSubtypeSmartAlbumBursts:
                // check if the subtypes available in iOS 8
            case PHAssetCollectionSubtypeSmartAlbumSelfPortraits:
            case PHAssetCollectionSubtypeSmartAlbumScreenshots:
            {
                if ([self collectionHasPhotoAssets:collection])
                {
                    [smartAlbumsArray addObject:collection];
                }
                break;
            }
            case PHAssetCollectionSubtypeSmartAlbumGeneric:
            {
                if ([self collectionHasPhotoAssets:collection])
                {
                    [genericSmartAlbumsArray addObject:collection];
                }
                break;
            }
            default:
                break;
        }
    }];
    
    [smartAlbumsArray addObjectsFromArray:genericSmartAlbumsArray];
    
    return [smartAlbumsArray copy];
}

- (NSArray<PHAssetCollection *> *)albumPhotoAssetCollections
{
    NSMutableArray<PHAssetCollection *> *mutableCollectionsArray = [NSMutableArray array];
    
    [self.albumsFetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if ([self collectionHasPhotoAssets:collection])
        {
            [mutableCollectionsArray addObject:collection];
        }
    }];
    
    return [mutableCollectionsArray copy];
}

#pragma mark - Photo assets counting

- (NSUInteger)photoAssetCountInCollection:(PHAssetCollection *)collection
{
    // It is possible to store the results in a hash table if necessary
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    options.wantsIncrementalChangeDetails = NO;
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection
                                                               options:options];
    return fetchResult.count;
}

- (BOOL)collectionHasPhotoAssets:(PHAssetCollection *)collection
{
    BOOL hasPhotoAssets = NO;
    
    if ([PHFetchOptions instancesRespondToSelector:@selector(fetchLimit)])
    {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.fetchLimit = 1;
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
        options.wantsIncrementalChangeDetails = NO;
        
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection
                                                                   options:options];
        
        hasPhotoAssets = (fetchResult.count > 0);
    }
    else
    {
        hasPhotoAssets = ([self photoAssetCountInCollection:collection] > 0);
    }
    
    return hasPhotoAssets;
}

#pragma mark - Collection thumbnail

- (void)requestThumbnailForAssetCollection:(PHAssetCollection *)collection
                             resultHandler:(void (^)(UIImage *image))resultHanlder
{
    PHAsset *keyAsset = [self lastKeyPhotoAssetForAssetCollection:collection];
    
    [self requestImageForAsset:keyAsset
                 resultHandler:resultHanlder];
}

// Doesn't work for transient collections!
- (PHAsset *)lastKeyPhotoAssetForAssetCollection:(PHAssetCollection *)collection
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    options.wantsIncrementalChangeDetails = NO;
    
    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchKeyAssetsInAssetCollection:collection
                                                                             options:options];
    return fetchResult.firstObject;
}

- (void)requestImageForAsset:(PHAsset *)asset resultHandler:(void (^)(UIImage *image))resultHandler
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:[self collectionThumbnailSize]
                                              contentMode:PHImageContentModeAspectFill
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         if (resultHandler && result)
         {
             resultHandler(result);
         }
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoAssetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAssetCollection *collection = self.photoAssetCollections[indexPath.row];
    
    NSUInteger assetCount = [self photoAssetCountInCollection:collection];
    
    iOPhotoCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.text = collection.localizedTitle;
    
    cell.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)assetCount];
    
    cell.thumbnailImageView.image = nil;
    
    [self loadThumbnailForCollection:collection
                         inTableView:tableView];
    
    return cell;
}

- (void)loadThumbnailForCollection:(PHAssetCollection *)collection
                       inTableView:(UITableView *)tableView
{
    __typeof(self) __weak weakSelf = self;
    UITableView * __weak weakTableView = tableView;
    
    [self requestThumbnailForAssetCollection:collection
                               resultHandler:^(UIImage *image)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             NSIndexPath *indexPath = [weakSelf indexPathOfCollection:collection];
             if (indexPath)
             {
                 iOPhotoCollectionCell *cell = [weakTableView cellForRowAtIndexPath:indexPath];
                 if (cell)
                 {
                     cell.thumbnailImageView.image = image;
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
        {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:self.smartAlbumsFetchResult];
            if (changeDetails)
            {
                self.smartAlbumsFetchResult = [changeDetails fetchResultAfterChanges];
                
                self.photoAssetCollections = nil;
            }
        }
        
        {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:self.albumsFetchResult];
            if (changeDetails)
            {
                self.albumsFetchResult = [changeDetails fetchResultAfterChanges];
                
                self.photoAssetCollections = nil;
            }
        }
        
        if (self.photoLibraryChangeHandler)
        {
            self.photoLibraryChangeHandler(changeInstance);
        }
    });
}

@end
