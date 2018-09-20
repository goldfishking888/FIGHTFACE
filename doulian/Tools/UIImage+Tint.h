//
//  UIImage+Tint.h
//  doulian
//
//  Created by 孙扬 on 16/11/11.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)
- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;
- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;
@end
