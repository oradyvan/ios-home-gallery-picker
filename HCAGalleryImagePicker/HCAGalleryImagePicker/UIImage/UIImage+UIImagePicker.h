//
//  UIImage+UIImagePicker.h
//  iO
//
//  Created by Nikita Ivaniushchenko on 9/1/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIImageImagePickerCompletionHandler)(UIImage *image);

@interface UIImage (UIImagePicker)

+ (void)io_imageForImagePickerInfo:(NSDictionary *)imagePickerInfo completionHandler:(UIImageImagePickerCompletionHandler)completionHandler;

@end
