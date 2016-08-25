//
//  HCAImagePickerNavigationControllerViewController.h
//  HomeCenter
//
//  Created by Maksym Malyhin on 11/7/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

#import "HCAImagePickerController.h"

typedef NSString * (^HCAImagePickerControllerPromtStringBlock)(NSArray *assets);

@interface HCAGalleryImagePickerViewController : UINavigationController

@property (copy, nonatomic) HCAImagePickerControllerPromtStringBlock photoSelectionPromtStringBlock;
@property (copy, nonatomic) HCAImagePickerSelectionResultBlock completeSelectionHandler;

/*In case of cancelation selectionHandler will be performed with (nil, nil)*/
- (id)initWithSelectionHandler:(HCAImagePickerSelectionResultBlock)selectionHandler;

@end
