//
//  ZSBrowseZoomScrollView.h
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZSBrowseZoomScrollViewTapBlock)(void);

@interface ZSBrowseZoomScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic,strong)UIImageView *zoomImageView;

- (void)tapClick:(ZSBrowseZoomScrollViewTapBlock)tapBlock;

@end
