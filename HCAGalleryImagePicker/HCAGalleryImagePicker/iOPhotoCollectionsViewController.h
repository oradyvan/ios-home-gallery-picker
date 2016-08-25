//
//  iOPhotoCollectionsViewController.h
//  iO
//
//  Created by Vadym Pilkevych on 10/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@protocol iOPhotoCollectionsViewControllerDelegate;


@interface iOPhotoCollectionsViewController : UITableViewController

@property (nonatomic, weak) id<iOPhotoCollectionsViewControllerDelegate> delegate;

- (PHAssetCollection *)allPhotosCollection;

@end


@protocol iOPhotoCollectionsViewControllerDelegate <NSObject>

@optional
- (void)iOPhotoCollectionsViewController:(iOPhotoCollectionsViewController *)controller didSelectAssetCollection:(PHAssetCollection *)assetCollection;
- (void)iOPhotoCollectionsViewControllerDidCancel:(iOPhotoCollectionsViewController *)controller;

@end
