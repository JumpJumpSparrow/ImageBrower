//
//  UIImage+ZSScale.h
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZSScale)
// 得到图像显示完整后的frame
- (CGRect)mss_getBigImageRectSizeWithScreenWidth:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight;
@end
