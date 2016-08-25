//
//  iOMultiplePhotoPicker.h
//  iO
//
//  Created by Vadym Pilkevych on 10/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@protocol iOMultiplePhotoPickerDelegate;


/**
 *  The class provides a possibility to pick multiple photo assets from the Photo Library.
 *  It does NOT work with the camera.
 *  Generally the class should be used in the similar manner as UIImagePickerController.
 *  The picker works only in iOS 8 and higher.
 */
@interface iOMultiplePhotoPicker : UINavigationController

@property (nonatomic, weak) id<UINavigationControllerDelegate, iOMultiplePhotoPickerDelegate> delegate;

@end


@protocol iOMultiplePhotoPickerDelegate <NSObject>

@required
- (void)iOMultiplePhotoPicker:(iOMultiplePhotoPicker *)picker didFinishPickingMediaWithInfo:(NSArray<PHAsset *> *)infoArray needsResize:(BOOL)needsResize;
- (void)iOMultiplePhotoPickerDidCancel:(iOMultiplePhotoPicker *)picker;

@end
