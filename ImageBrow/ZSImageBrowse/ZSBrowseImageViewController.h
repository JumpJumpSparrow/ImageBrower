//
//  ZSBrowseImageViewController.h
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSBrowseModel.h"
#import "ZSBrowseCollectionViewCell.h"

#define MSS_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define MSS_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface ZSBrowseImageViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,assign)BOOL isEqualRatio;// 大小图是否等比（默认为等比）

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,assign)BOOL isFirstOpen;
@property (nonatomic,assign)CGFloat screenWidth;
@property (nonatomic,assign)CGFloat screenHeight;

- (instancetype)initWithBrowseItemArray:(NSArray *)browseItemArray currentIndex:(NSInteger)currentIndex;
- (void)showBrowseViewController;

// 子类重写此方法
- (void)loadBrowseImageWithBrowseItem:(ZSBrowseModel *)browseItem Cell:(ZSBrowseCollectionViewCell *)cell bigImageRect:(CGRect)bigImageRect;
- (void)showBrowseRemindViewWithText:(NSString *)text;
// 获取指定视图在window中的位置
- (CGRect)getFrameInWindow:(UIView *)view;

@end
