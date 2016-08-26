//
//  HCAImagePickerNavigationControllerViewController.h
//  HomeCenter
//
//  Created by Maksym Malyhin on 11/7/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *_Nullable (^HCAImagePickerControllerPromtStringBlock)(NSArray *assets);
typedef void(^HCAImagePickerSelectionResultBlock)(NSArray<PHAsset *> *_Nullable assets, UIViewController *viewController);

@interface HCAGalleryImagePickerViewController : UINavigationController

@property (copy, nonatomic) HCAImagePickerControllerPromtStringBlock photoSelectionPromtStringBlock;
@property (copy, nonatomic) HCAImagePickerSelectionResultBlock completeSelectionHandler;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*In case of cancelation completion will be performed with (nil, nil)*/
+ (instancetype)startPickingPhotosFromViewContorller:(UIViewController *)viewController completion:(HCAImagePickerSelectionResultBlock)completion;

@end

NS_ASSUME_NONNULL_END