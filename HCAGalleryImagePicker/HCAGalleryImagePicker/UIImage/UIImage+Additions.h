//
//  UIImage+Additions.h
//
//  Created by Nikita Ivaniushchenko on 9/30/12.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
/**
 * Creates new image from the current one by clipping particular area
 * @param frame Specifies area to be clipped from the original image
 * @return Resulting image
 */
- (UIImage *)io_subImageAtFrame:(CGRect)frame;

@end
