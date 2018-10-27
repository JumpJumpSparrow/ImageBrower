//
//  ZSBrowseLoadingImageView.m
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import "ZSBrowseLoadingImageView.h"

@interface ZSBrowseLoadingImageView ()

@property (nonatomic,strong)CABasicAnimation *rotationAnimation;

@end

@implementation ZSBrowseLoadingImageView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        [self createImageView];
    }
    return self;
}

- (void)createImageView{
    self.image = [UIImage imageNamed:@"mss_browseLoading"];
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    _rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    _rotationAnimation.duration = 0.6f;
    _rotationAnimation.repeatCount = FLT_MAX;
}

- (void)startAnimation{
    self.hidden = NO;
    [self.layer addAnimation:_rotationAnimation
                      forKey:@"rotateAnimation"];
}

- (void)stopAnimation{
    self.hidden = YES;
    [self.layer removeAnimationForKey:@"rotateAnimation"];
}


@end
