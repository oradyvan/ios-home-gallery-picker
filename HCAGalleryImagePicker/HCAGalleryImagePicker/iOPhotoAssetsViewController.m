//
//  iOPhotoAssetsViewController.m
//  iO
//
//  Created by Vadym Pilkevych on 14/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import "iOPhotoAssetsViewController.h"
#import "iOPhotoAssetsDataSource.h"
#import "iOPhotoAssetCell.h"

@import HCAUtils;
@import HCAUI;

#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


#define iOMultiplePhotoSelectionSectionInsets UIEdgeInsetsMake(5.f, 0.f, 5.f, 0.f)


static CGFloat const kCellInteritemSpacing = 2.f;
static int const kNumberOfCellsPerRow = 4;


@interface iOPhotoAssetsViewController ()

@property (nonatomic, strong) IBOutlet iOPhotoAssetsDataSource      *dataSource;
@property (nonatomic, strong) IBOutlet HCAButtonWithCustomAlignment *useFullResolutionButton;
@property (nonatomic, strong) IBOutlet UILabel                      *selectionNumberLabel;
@property (nonatomic, strong) IBOutlet UILongPressGestureRecognizer *collectionViewLongPressRecognizer;
@property (nonatomic, strong) UIBarButtonItem *photoResolutionBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *selectionNumberBarItem;
@property (nonatomic, strong) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic        ) BOOL            isCollectionViewTouchedByUser;

@end

@implementation iOPhotoAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDataSource];
    
    [self setupCollectionView];
    
    [self setupToolbarItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateToolbarItems];
    
    // Works properly on the next run loop cycle only
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (self.isCollectionViewTouchedByUser == NO)
        {
            [self.collectionView hca_scrollToBottomAnimated:NO];
        }
    });
}

#pragma mark - Public

- (void)selectItemWithAsset:(PHAsset *)asset
{
    NSIndexPath *indexPath = [self.dataSource indexPathOfAsset:asset];
    if (indexPath)
    {
        [self selectItemAtIndexPath:indexPath];
    }
}

#pragma mark - Private

- (void)setupDataSource
{
    CGSize thumbnailSizeInPoints = [self collectionViewItemSize];
    
    self.dataSource.itemSize = CGSizeMake(thumbnailSizeInPoints.width * UI_SCREEN_SCALE,
                                          thumbnailSizeInPoints.height * UI_SCREEN_SCALE);
    
    __typeof(self) __weak weakSelf = self;
    
    self.dataSource.photoLibraryChangeHandler = ^(PHChange *changeInfo)
    {
        [weakSelf.collectionView reloadData];
    };
}

- (void)setupCollectionView
{
    self.collectionView.allowsMultipleSelection = YES;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = [self collectionViewItemSize];
    layout.minimumLineSpacing = kCellInteritemSpacing;
    layout.minimumInteritemSpacing = kCellInteritemSpacing;
    layout.sectionInset = iOMultiplePhotoSelectionSectionInsets;
}

- (void)setupToolbarItems
{
    UIFont *font = [UIFont systemFontOfSize:17.f weight:UIFontWeightLight];
    
    // Toggle resolution button
    HCAButtonWithCustomAlignment *toggleResolutionButton = self.useFullResolutionButton;
    toggleResolutionButton.titleLabel.font = font;
    [toggleResolutionButton setTitle:NSLocalizedString(@"lblHighResolution", nil) forState:UIControlStateNormal];
    [toggleResolutionButton sizeToFit];
    
    UIBarButtonItem *resolutionBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toggleResolutionButton];
    resolutionBarButtonItem.width = toggleResolutionButton.bounds.size.width;
    self.photoResolutionBarButtonItem = resolutionBarButtonItem;
    
    // Selection number label
    self.selectionNumberLabel.font = font;
    
    UIBarButtonItem *selectionNumberBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectionNumberLabel];
    self.selectionNumberBarItem = selectionNumberBarItem;
    
    // Send button
    UIBarButtonItem *sendBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendButtonDidPress)];
    sendBarButtonItem.title = NSLocalizedString(@"lblSend", nil);
    self.doneBarButtonItem = sendBarButtonItem;
    
    // Put together
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[resolutionBarButtonItem, flexibleSpace, sendBarButtonItem];
}

- (void)updateToolbarItems
{
    NSUInteger numberOfSelectedAssets = [self.dataSource numberOfSelectedAssets];
    
    self.doneBarButtonItem.enabled = (numberOfSelectedAssets > 0);
    self.photoResolutionBarButtonItem.enabled = (numberOfSelectedAssets == 1);
    // Hide button when full resolution option is not available
    self.useFullResolutionButton.hidden = (numberOfSelectedAssets > 1);
    
    if (numberOfSelectedAssets == 0)
    {
        // Deselect option when no photos are selected (anymore)
        self.useFullResolutionButton.selected = NO;
    }
    
    // Show resolution button or selection number text
    if (numberOfSelectedAssets > 1)
    {
        NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
        [toolbarItems replaceObjectAtIndex:0 withObject:self.selectionNumberBarItem];
        [self setToolbarItems:toolbarItems animated:YES];
        
        self.selectionNumberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"lblSelectionNumberFormat", nil), numberOfSelectedAssets];
        [self.selectionNumberLabel sizeToFit];
    }
    else
    {
        NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
        [toolbarItems replaceObjectAtIndex:0 withObject:self.photoResolutionBarButtonItem];
        [self setToolbarItems:toolbarItems animated:YES];
    }
}

- (CGSize)collectionViewItemSize
{
    UIEdgeInsets sectionInset = iOMultiplePhotoSelectionSectionInsets;
    CGFloat interitemSpacing = kCellInteritemSpacing;
    
    // Take the smalles side (so it is orientation independant) and divide it by the number of tiles needed.
    CGFloat minSize = MIN(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    CGFloat itemsWidth = minSize - sectionInset.left - sectionInset.right - (kNumberOfCellsPerRow - 1) * interitemSpacing;
    
    CGFloat itemSideLength = floor(itemsWidth / kNumberOfCellsPerRow);
    return CGSizeMake(itemSideLength, itemSideLength);
}

- (void)resetSelectionNumbersInCollectionView
{
    for (NSUInteger i = 0; i < self.dataSource.selectedAssetIndexPaths.count; i++)
    {
        NSUInteger selectionNumber = i + 1;
        
        NSIndexPath *indexPath = self.dataSource.selectedAssetIndexPaths[i];
        iOPhotoAssetCell *cell = (iOPhotoAssetCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell setSelectionNumber:selectionNumber];
    }
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource.selectedAssetIndexPaths containsObject:indexPath])
    {
        // The asset is already selected
        return;
    }
    
    [self.dataSource selectAssetAtIndexPath:indexPath];
    
    [self.collectionView selectItemAtIndexPath:indexPath
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionNone];
    
    NSUInteger numberOfSelectedAssets = [self.dataSource numberOfSelectedAssets];
    
    iOPhotoAssetCell *cell = (iOPhotoAssetCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelectionNumber:numberOfSelectedAssets];
    
    [self updateToolbarItems];
}

#pragma mark - Actions

- (IBAction)toggleResolutionButtonDidPress
{
    self.useFullResolutionButton.selected = !self.useFullResolutionButton.isSelected;
}

- (IBAction)cancelButtonDidPress
{
    if ([self.delegate respondsToSelector:@selector(iOPhotoAssetsViewControllerDidCancel:)])
    {
        [self.delegate iOPhotoAssetsViewControllerDidCancel:self];
    }
}

- (void)sendButtonDidPress
{
    if ([self.delegate respondsToSelector:@selector(iOPhotoAssetsViewController:didFinishWithSelection:needsResize:)])
    {
        NSArray *selectedAssets = [self.dataSource selectedAssets];
        
        BOOL needsResize = YES;
        if (selectedAssets.count == 1)
        {
            needsResize = !self.useFullResolutionButton.isSelected;
        }
        
        [self.delegate iOPhotoAssetsViewController:self
                            didFinishWithSelection:selectedAssets
                                       needsResize:needsResize];
    }
}

- (IBAction)collectionViewDidLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer == self.collectionViewLongPressRecognizer)
    {
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            if ([self.delegate respondsToSelector:@selector(iOPhotoAssetsViewController:didLongPressOnItemWithAsset:)])
            {
                NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]];
                if (indexPath)
                {
                    PHAsset *asset = [self.dataSource assetAtIndexPath:indexPath];
                    [self.delegate iOPhotoAssetsViewController:self
                                   didLongPressOnItemWithAsset:asset];
                }
            }
            
            self.isCollectionViewTouchedByUser = YES;
        }
    }
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataSource selectAssetAtIndexPath:indexPath];
    
    NSUInteger numberOfSelectedAssets = [self.dataSource numberOfSelectedAssets];
    
    iOPhotoAssetCell *cell = (iOPhotoAssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelectionNumber:numberOfSelectedAssets];
    
    [self updateToolbarItems];
    
    self.isCollectionViewTouchedByUser = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataSource deselectAssetAtIndexPath:indexPath];
    
    [self resetSelectionNumbersInCollectionView];
    
    [self updateToolbarItems];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - Accessors

- (PHAssetCollection *)assetCollection
{
    return self.dataSource.assetCollection;
}

- (void)setAssetCollection:(PHAssetCollection *)assetCollection
{
    self.dataSource.assetCollection = assetCollection;
}

@end
