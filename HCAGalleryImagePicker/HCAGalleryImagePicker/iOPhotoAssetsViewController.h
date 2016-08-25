//
//  iOPhotoAssetsViewController.h
//  iO
//
//  Created by Vadym Pilkevych on 14/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@protocol iOPhotoAssetsViewControllerDelegate;


/**
 *  The class represents a photo grid with photos from a certain asset collection. 
 *  It allows to select multiple photos.
 */
@interface iOPhotoAssetsViewController : UICollectionViewController

@property (nonatomic, weak) id<iOPhotoAssetsViewControllerDelegate> delegate;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

- (void)selectItemWithAsset:(PHAsset *)asset;

@end


@protocol iOPhotoAssetsViewControllerDelegate <NSObject>

@optional

- (void)iOPhotoAssetsViewController:(iOPhotoAssetsViewController *)controller
             didFinishWithSelection:(NSArray<PHAsset *> *)selectedAssets
                        needsResize:(BOOL)needsResize;

- (void)iOPhotoAssetsViewController:(iOPhotoAssetsViewController *)controller
        didLongPressOnItemWithAsset:(PHAsset *)asset;

- (void)iOPhotoAssetsViewControllerDidCancel:(iOPhotoAssetsViewController *)controller;

@end
