//
//  MMVPhotosCollectionViewController.m
//  MMVImagePickerController
//
//  Created by Maksym Malyhin on 11/5/14.
//  Copyright (c) 2014 Maxim Malyhin. All rights reserved.
//

#import "HCAPhotosCollectionViewController.h"
#import "HCAImageCollectionViewCell.h"
#import "HCAAssetCollection.h"

#import "HCAGalleryImagePickerViewController.h"
#import "HCAGalleryImagePicker.h"

#define kHCAPhotosCollectionNumberOfItemsInLine 4
#define kHCAPhotosCollectionMinimumInteritemSpacing 1

@interface HCAPhotosCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) PHFetchResult *photos;
@property (nonatomic) CGSize thumbnailsSize;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UIButton *uploadSelectedButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)nextButtonPressed;

@end

@implementation HCAPhotosCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.uploadSelectedButton setTitle:NSLocalizedString(@"Upload Selected", @"HCAPhotosCollectionViewController.UploadSelected") forState:UIControlStateNormal];
    [self.uploadSelectedButton sizeToFit];
    
    self.collectionView.allowsMultipleSelection = YES;
    
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([HCAImageCollectionViewCell class]) bundle:[NSBundle bundleForClass:[HCAImageCollectionViewCell class]]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self adjustCellSize];
    [self updatePhotoList];
    
    [self numberOfSelectedPhotosDidChange];
}

- (void)adjustCellSize
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    NSInteger itemsPerLine = kHCAPhotosCollectionNumberOfItemsInLine;
    NSInteger spacing = kHCAPhotosCollectionMinimumInteritemSpacing;
    
    CGFloat cellWidth = (CGRectGetWidth(self.view.bounds) - spacing * (itemsPerLine - 1)) / itemsPerLine;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.minimumInteritemSpacing = kHCAPhotosCollectionMinimumInteritemSpacing;
    flowLayout.minimumLineSpacing = kHCAPhotosCollectionMinimumInteritemSpacing;
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    self.thumbnailsSize = CGSizeMake(cellWidth * screenScale, cellWidth * screenScale);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HCAImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSInteger tag = indexPath.row;
    
    if (cell.tag != tag)
    {
        cell.imageView.image = nil;
    }
    
    cell.tag = tag;
    
    PHAsset *asset = self.photos[indexPath.row];
    
    if (![cell.assetId isEqualToString:asset.localIdentifier])
    {
        if (cell.imageRequestId)
        {
            [[PHImageManager defaultManager] cancelImageRequest:cell.imageRequestId];
            cell.assetId = asset.localIdentifier;
        }
        
        PHImageRequestOptions *imageOptions = [PHImageRequestOptions new];
        imageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        imageOptions.networkAccessAllowed = YES;
        
        cell.imageRequestId = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.thumbnailsSize contentMode:PHImageContentModeAspectFill options:imageOptions resultHandler:^(UIImage *result, NSDictionary *info)
                               {
                                   
                                   if (cell.tag == tag)
                                   {
                                       cell.imageView.image = result;
                                   }
                                   
                               }];
        
    }
    
    
    
    if ([collectionView.indexPathsForSelectedItems containsObject:indexPath])
    {
        [cell setSelected:YES];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self numberOfSelectedPhotosDidChange];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self numberOfSelectedPhotosDidChange];
}

- (void)numberOfSelectedPhotosDidChange
{
    [self updatePromt];
    [self updateButtons];
}

- (void)updateButtons
{
    NSUInteger numberOfSelectedItems = [[self.collectionView indexPathsForSelectedItems] count];
    
    if (numberOfSelectedItems == self.photos.count)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Deselect All", @"HCAPhotosCollectionViewController.DeselectAll")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(deselectAllButtonPressed)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select All", @"HCAPhotosCollectionViewController.SelectAll")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(selectAllButtonPressed)];
    }
    
    self.toolbar.hidden = (numberOfSelectedItems == 0);
    
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.bottom = self.toolbar.hidden ? 0.f : 44.f;
    self.collectionView.contentInset = contentInset;
}

- (void)updatePromt
{
    HCAImagePickerControllerPromtStringBlock photoSelectionPromtStringBlock = [(HCAGalleryImagePickerViewController *)self.navigationController photoSelectionPromtStringBlock];
    if (photoSelectionPromtStringBlock)
    {
        NSArray *selectedPhotos = [self selectedPhotos];
        
        self.navigationItem.prompt = photoSelectionPromtStringBlock(selectedPhotos);
    }
}

#pragma mark - Photos

- (void)updatePhotoList
{
    self.photos = [PHAsset fetchAssetsInAssetCollection:self.collection options:[HCAAssetCollection defaultAssetsFetchOptions]];
    [self.collectionView reloadData];

    [self updateButtons];
}

- (NSArray *)selectedPhotos
{
    NSArray *selectedCellIndexPaths = [self.collectionView indexPathsForSelectedItems];
    NSMutableIndexSet *selectedPhotoIndexes = [NSMutableIndexSet indexSet];
    
    for (NSIndexPath *indexPath in selectedCellIndexPaths)
    {
        [selectedPhotoIndexes addIndex:indexPath.row];
    }
    
    NSArray *selectedPhotos = [self.photos objectsAtIndexes:selectedPhotoIndexes];
    
    return selectedPhotos;
}

#pragma mark - Actions

- (IBAction)nextButtonPressed
{
    NSArray *selectedPhotos = [self selectedPhotos];
    
    HCAImagePickerSelectionResultBlock selectionResultBlock = [(HCAGalleryImagePickerViewController *)self.navigationController completeSelectionHandler];
    selectionResultBlock(selectedPhotos, self.navigationController);
}

- (IBAction)selectAllButtonPressed
{
    for (NSUInteger i = 0; i < self.photos.count; i++)
    {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    [self numberOfSelectedPhotosDidChange];
}

- (IBAction)deselectAllButtonPressed
{
    NSArray *selectedCellIndexPaths = [self.collectionView indexPathsForSelectedItems];
    NSMutableIndexSet *selectedPhotoIndexes = [NSMutableIndexSet indexSet];
    
    for (NSIndexPath *selectedIndexPath in selectedCellIndexPaths)
    {
        [self.collectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
    }
    
    [self numberOfSelectedPhotosDidChange];
}

@end
