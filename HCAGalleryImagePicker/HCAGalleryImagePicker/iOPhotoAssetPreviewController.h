//
//  iOPhotoAssetPreviewController.h
//  iO
//
//  Created by Vadym Pilkevych on 04/01/16.
//  Copyright © 2016 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "iOPhotoAsset.h"


@protocol iOPhotoAssetPreviewControllerDelegate;


/**
 *  Displays the given photo asset fullscreen with "aspect fit" content mode.
 */
@interface iOPhotoAssetPreviewController : UIViewController

@property (nonatomic, strong) iOPhotoAsset *photoAsset;
@property (nonatomic, weak) id<iOPhotoAssetPreviewControllerDelegate> delegate;

@end


@protocol iOPhotoAssetPreviewControllerDelegate <NSObject>

@required
- (void)iOPhotoAssetPreviewControllerDidSelect:(iOPhotoAssetPreviewController *)controller;

@end
