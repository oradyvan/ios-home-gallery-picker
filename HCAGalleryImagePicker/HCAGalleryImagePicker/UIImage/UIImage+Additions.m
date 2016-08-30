//
//  UIImage+Additions.m
//
//  Created by Nikita Ivaniushchenko on 9/30/12.
//

#import "UIImage+Additions.h"

#if !__has_feature(objc_arc)
#error "ARC is required"
#endif

@implementation UIImage (Additions)

- (CGAffineTransform)io_orientationTransform
{
    CGAffineTransform orientationTransform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
            orientationTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -self.size.height);
            break;
            
        case UIImageOrientationRight:
            orientationTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -self.size.width, 0);
            break;
            
        case UIImageOrientationDown:
            orientationTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -self.size.width, -self.size.height);
            break;
            
        default:
            break;
    };
    
    return CGAffineTransformScale(orientationTransform, self.scale, self.scale);
}

- (UIImage *)io_subImageAtFrame:(CGRect)frame
{
    CGAffineTransform orientationTransform = [self io_orientationTransform];
    CGRect transformedFrame = CGRectApplyAffineTransform(frame, orientationTransform);

    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, transformedFrame);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return result;
}
@end
