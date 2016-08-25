//
//  HCAImagePickerController.m
//  HomeCenter
//
//  Created by Maksym Malyhin on 11/4/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "HCAImagePickerController.h"

#import "HCAGalleryImagePickerViewController.h"

@interface HCAImagePickerController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (copy, nonatomic) HCAImagePickerCompletionBlock completion;
@property (copy, nonatomic) HCAImagePickerCompletionBlock pickerDismissCompletion;
@property (strong, nonatomic) UIViewController *controllerForPresenting;

@property (strong, nonatomic) UIAlertController *selectPhotoAlertController;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation HCAImagePickerController

- (void)startGetPhotoFlowWithViewController:(UIViewController *)viewController completion:(HCAImagePickerCompletionBlock)completion
{
    self.completion = completion;
    self.controllerForPresenting = viewController;
    
    [self presentGetPhotoAlert];
}

- (UINavigationController *)startGetMultiplePhotosFlowWithViewController:(UIViewController *)viewController
                                                              completion:(HCAImagePickerSelectionResultBlock)completion
{
    HCAGalleryImagePickerViewController *vc = [[HCAGalleryImagePickerViewController alloc] initWithSelectionHandler:completion];
    [viewController presentViewController:vc animated:YES completion:NULL];
    return vc;
}

- (void)startGetPhotoFlowWithViewController:(UIViewController *)viewController pickerDismissCompletion:(HCAImagePickerCompletionBlock)completion
{
    self.pickerDismissCompletion = completion;
    self.controllerForPresenting = viewController;
    
    [self presentGetPhotoAlert];
}

#pragma mark - Get photo flow

- (void)presentGetPhotoAlert
{
    if (!self.selectPhotoAlertController)
    {
        __weak typeof(self) weakSelf = self;
        
        self.selectPhotoAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                            {
                                                [weakSelf.selectPhotoAlertController dismissViewControllerAnimated:YES completion:NULL];
                                            }];
        [self.selectPhotoAlertController addAction:cancelAlertAction];
        
        UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                  {
                                                      [weakSelf presentImagePickerWithSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
                                                  }];
        [self.selectPhotoAlertController addAction:photoLibraryAlertAction];
        
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIAlertAction *takePhotoAlertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                   {
                                                       [weakSelf presentImagePickerWithSourceType:(UIImagePickerControllerSourceTypeCamera)];
                                                   }];
            [self.selectPhotoAlertController addAction:takePhotoAlertAction];
        }
        
    }
    
    [self.controllerForPresenting presentViewController:self.selectPhotoAlertController animated:YES completion:NULL];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (!self.imagePicker)
    {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    
    _imagePicker.sourceType = sourceType;
    _imagePicker.allowsEditing = YES;
    [self.controllerForPresenting presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)imageDidSelect:(UIImage *)image
{
    if (self.completion)
    {
        self.completion(image, nil);
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self imageDidSelect:image];
    [picker dismissViewControllerAnimated:YES completion:^
    {
        if (self.pickerDismissCompletion)
        {
            self.pickerDismissCompletion(image, nil);
        }
    }];
    
    self.controllerForPresenting = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^
    {
        if (self.pickerDismissCompletion)
        {
            self.pickerDismissCompletion(nil, nil);
        }
    }];
    
    if (self.completion)
    {
        self.completion(nil, nil);
    }
    
    self.controllerForPresenting = nil;
}

@end
