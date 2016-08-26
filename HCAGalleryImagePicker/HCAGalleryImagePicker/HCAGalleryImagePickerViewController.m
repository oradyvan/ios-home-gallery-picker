//
//  HCAImagePickerNavigationControllerViewController.m
//  HomeCenter
//
//  Created by Maksym Malyhin on 11/7/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "HCAGalleryImagePickerViewController.h"

#import "HCAGalleryImagePicker.h"

@interface HCAGalleryImagePickerViewController ()

@end

@implementation HCAGalleryImagePickerViewController

+ (instancetype)startPickingPhotosFromViewContorller:(UIViewController *)viewController completion:(HCAImagePickerSelectionResultBlock)completion
{
    HCAGalleryImagePickerViewController *imagePickerViewController = [[UIStoryboard storyboardWithName:@"HCAImagePicker" bundle:[NSBundle bundleWithIdentifier:HCAGalleryImagePickerBundleIdentifier]] instantiateInitialViewController];
    imagePickerViewController.completeSelectionHandler = completion;
    [viewController presentViewController:imagePickerViewController animated:YES completion:NULL];
    return imagePickerViewController;
}

@end
