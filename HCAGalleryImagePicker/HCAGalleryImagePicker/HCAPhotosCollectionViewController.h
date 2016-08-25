//
//  MMVPhotosCollectionViewController.h
//  MMVImagePickerController
//
//  Created by Maksym Malyhin on 11/5/14.
//  Copyright (c) 2014 Maxim Malyhin. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "HCAAssetsLibrary.h"
#import <Photos/Photos.h>

@interface HCAPhotosCollectionViewController : UIViewController

@property (nonatomic) PHAssetCollection *collection;

@end
