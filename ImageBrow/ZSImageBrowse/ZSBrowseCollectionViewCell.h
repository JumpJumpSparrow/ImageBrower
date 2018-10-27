//
//  ZSBrowseCollectionViewCell.h
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSBrowseLoadingImageView.h"
#import "ZSBrowseZoomScrollView.h"

@class ZSBrowseCollectionViewCell;
typedef void(^ZSBrowseCollectionViewCellTapBlock)(ZSBrowseCollectionViewCell *browseCell);
@interface ZSBrowseCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)ZSBrowseZoomScrollView *zoomScrollView; // 滚动视图
@property (nonatomic, strong)ZSBrowseLoadingImageView *loadingView; // 加载视图

- (void)tapClick:(ZSBrowseCollectionViewCellTapBlock)tapBlock;
@end
