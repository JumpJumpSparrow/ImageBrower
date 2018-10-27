//
//  UIImage+ZSScale.m
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import "UIImage+ZSScale.h"

@implementation UIImage (ZSScale)
// 得到图像显示完整后的宽度和高度
- (CGRect)mss_getBigImageRectSizeWithScreenWidth:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight {
    CGFloat widthRatio = screenWidth / self.size.width;
    CGFloat heightRatio = screenHeight / self.size.height;
    CGFloat scale = MIN(widthRatio, heightRatio);
    CGFloat width = scale * self.size.width;
    CGFloat height = scale * self.size.height;
    return CGRectMake((screenWidth - width) / 2, (screenHeight - height) / 2, width, height);
}
@end
