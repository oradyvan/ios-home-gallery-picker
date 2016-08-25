//
//  iOMultiplePhotoPicker.m
//  iO
//
//  Created by Vadym Pilkevych on 10/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import "iOMultiplePhotoPicker.h"
#import "iOPhotoCollectionsViewController.h"
#import "iOPhotoAssetsViewController.h"
#import "iOPhotoAssetPreviewController.h"
#import "iOPhotoAsset.h"


#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


@interface iOMultiplePhotoPicker ()<iOPhotoCollectionsViewControllerDelegate,
                                    iOPhotoAssetsViewControllerDelegate,
                                    iOPhotoAssetPreviewControllerDelegate>

@property (nonatomic, readonly) iOPhotoCollectionsViewController *collectionsViewController;
@property (nonatomic, weak) iOPhotoAssetsViewController *assetsViewController;

@end

@implementation iOMultiplePhotoPicker

@dynamic delegate;

- (instancetype)init
{
    self = [[UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil] instantiateInitialViewController];
    
    return self;
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    [self setupCollectionsViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    BOOL photoLibraryIsNotEmpty = (self.collectionsViewController.allPhotosCollection != nil);
    if (photoLibraryIsNotEmpty)
    {
        [self pushAssetsViewControllerWithAllPhotosCollection];
    }
}

#pragma mark - Private

- (iOPhotoCollectionsViewController *)collectionsViewController
{
    iOPhotoCollectionsViewController *controller = (iOPhotoCollectionsViewController *)self.viewControllers.firstObject;
    return controller;
}

- (void)setupNavigationBar
{
    // The attributes are taken from iONavigationBar class
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor clearColor];
    
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:18.f weight:UIFontWeightBold],
                                               NSShadowAttributeName : shadow};
}

- (void)setupCollectionsViewController
{
    iOPhotoCollectionsViewController *controller = self.collectionsViewController;
    controller.delegate = self;
    controller.title = NSLocalizedString(@"lblAlbumsTitle", nil);
}

- (iOPhotoAssetsViewController *)instantiateAssetsViewController
{
    iOPhotoAssetsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"iOPhotoAssetsViewController"];
    controller.delegate = self;
    controller.title = NSLocalizedString(@"ttlPhotoSelection", nil);
    return controller;
}

- (iOPhotoAssetPreviewController *)instantiateAssetPreviewController
{
    iOPhotoAssetPreviewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"iOPhotoAssetPreviewController"];
    controller.delegate = self;
    controller.title = NSLocalizedString(@"lblPreviewTitle", nil);
    return controller;
}

- (void)pushAssetsViewControllerWithAllPhotosCollection
{
    PHAssetCollection *initialCollection = [self.collectionsViewController allPhotosCollection];
    
    iOPhotoAssetsViewController *photoAssetsViewController = [self instantiateAssetsViewController];
    photoAssetsViewController.assetCollection = initialCollection;
    self.assetsViewController = photoAssetsViewController;
    [self pushViewController:photoAssetsViewController animated:NO];
}

#pragma mark - iOPhotoCollectionsViewControllerDelegate

- (void)iOPhotoCollectionsViewControllerDidCancel:(iOPhotoCollectionsViewController *)controller
{
    [self.delegate iOMultiplePhotoPickerDidCancel:self];
}

- (void)iOPhotoCollectionsViewController:(iOPhotoCollectionsViewController *)controller
                didSelectAssetCollection:(PHAssetCollection *)assetCollection
{
    iOPhotoAssetsViewController *photoAssetsViewController = [self instantiateAssetsViewController];
    photoAssetsViewController.assetCollection = assetCollection;
    self.assetsViewController = photoAssetsViewController;
    
    [self pushViewController:photoAssetsViewController animated:YES];
}

#pragma mark - iOPhotoAssetsViewControllerDelegate

- (void)iOPhotoAssetsViewControllerDidCancel:(iOPhotoAssetsViewController *)controller
{
    [self.delegate iOMultiplePhotoPickerDidCancel:self];
}

- (void)iOPhotoAssetsViewController:(iOPhotoAssetsViewController *)controller
             didFinishWithSelection:(NSArray<PHAsset *> *)selectedAssets
                        needsResize:(BOOL)needsResize
{
    [self.delegate iOMultiplePhotoPicker:self
           didFinishPickingMediaWithInfo:selectedAssets
                             needsResize:needsResize];
}

- (void)iOPhotoAssetsViewController:(iOPhotoAssetsViewController *)controller
        didLongPressOnItemWithAsset:(PHAsset *)asset
{
    iOPhotoAsset *assetDataItem = [[iOPhotoAsset alloc] initWithAsset:asset];
    
    iOPhotoAssetPreviewController *previewController = [self instantiateAssetPreviewController];
    previewController.photoAsset = assetDataItem;
    
    [self pushViewController:previewController animated:YES];
}

#pragma mark - iOPhotoAssetPreviewControllerDelegate

- (void)iOPhotoAssetPreviewControllerDidSelect:(iOPhotoAssetPreviewController *)controller
{
    [self.assetsViewController selectItemWithAsset:controller.photoAsset.photoAsset];
    
    [self popViewControllerAnimated:YES];
}

@end
