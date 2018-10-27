//
//  ZSBrowseCollectionViewCell.m
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import "ZSBrowseCollectionViewCell.h"
#import "UIView+Additions.h"

@interface ZSBrowseCollectionViewCell ()

@property (nonatomic,copy)ZSBrowseCollectionViewCellTapBlock tapBlock;

@end

@implementation ZSBrowseCollectionViewCell
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self createCell];
    }
    return self;
}

- (void)createCell{
    _zoomScrollView = [[ZSBrowseZoomScrollView alloc]init];
    __weak __typeof(self)weakSelf = self;
    [_zoomScrollView tapClick:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.tapBlock(strongSelf);
    }];
    [self.contentView addSubview:_zoomScrollView];
    _loadingView = [[ZSBrowseLoadingImageView alloc]init];
    [_zoomScrollView addSubview:_loadingView];
}

- (void)tapClick:(ZSBrowseCollectionViewCellTapBlock)tapBlock{
    _tapBlock = tapBlock;
}

@end
