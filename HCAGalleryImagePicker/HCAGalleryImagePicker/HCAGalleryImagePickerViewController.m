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

- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"HCAImagePicker" bundle:[NSBundle bundleWithIdentifier:HCAGalleryImagePickerBundleIdentifier]] instantiateInitialViewController];
    return self;
}

- (id)initWithSelectionHandler:(HCAImagePickerSelectionResultBlock)selectionHandler
{
    if (self = [self init])
    {
        self.completeSelectionHandler = selectionHandler;
    }
    
    return self;
}

@end
