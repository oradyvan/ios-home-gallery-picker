//
//  HCAImagePickerController.h
//  HomeCenter
//
//  Created by Maksym Malyhin on 11/4/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import <HCAGalleryImagePicker/HCAGalleryImagePicker.h>

NS_ASSUME_NONNULL_BEGIN

/*
The class provides convinient way to select or take a photo using UIImagePickerController under hood.
*/

typedef void(^HCAImagePickerSelectionResultBlock)(NSArray<PHAsset *> *_Nullable assets, UIViewController *viewController);
typedef void(^HCAImagePickerCompletionBlock)(UIImage  * _Nullable image, NSError  * _Nullable error);

@interface HCAImagePickerController : NSObject

/*
 Method starts get photo flow presenting alert view with available options.
 @param viewController A View controller that will be used to present UIImagePickerController modally.
 @param completion Completion handler.
*/
- (void)startGetPhotoFlowWithViewController:(UIViewController *)viewController completion:(HCAImagePickerCompletionBlock)completion;

- (void)startGetMultiplePhotosFlowWithViewController:(UIViewController *)viewController
                                          completion:(HCAImagePickerSelectionResultBlock)completion;

/*
 Method starts get photo flow presenting alert view with available options.
 @param viewController A View controller that will be used to present UIImagePickerController modally.
 @param completion Completion handler which is called after UIImagePickerController was dismissed
 */
- (void)startGetPhotoFlowWithViewController:(UIViewController *)viewController pickerDismissCompletion:(HCAImagePickerCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END