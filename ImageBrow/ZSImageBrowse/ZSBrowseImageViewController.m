//
//  ZSBrowseImageViewController.m
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import "ZSBrowseImageViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ZSScale.h"
#import "ZSBrowseRemindView.h"
#import "UIView+Additions.h"

#define kBrowseSpace 50.0f

@interface ZSBrowseImageViewController ()

@property (nonatomic, strong) NSArray *browseItemArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UILabel *countLabel;// 当前图片位置
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) NSMutableArray *verticalBigRectArray;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
@property (nonatomic, strong) ZSBrowseRemindView *browseRemindView;
@end

@implementation ZSBrowseImageViewController

- (instancetype)initWithBrowseItemArray:(NSArray *)browseItemArray currentIndex:(NSInteger)currentIndex
{
    self = [super init];
    if(self)
    {
        _browseItemArray = browseItemArray;
        _currentIndex = currentIndex;
        _isEqualRatio = YES;
        _isFirstOpen = YES;
        _screenWidth = MSS_SCREEN_WIDTH;
        _screenHeight = MSS_SCREEN_HEIGHT;
        _currentOrientation = UIDeviceOrientationPortrait;
        _verticalBigRectArray = [[NSMutableArray alloc]init];
    }
    return self;
}
- (void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self createBrowseView];
}

- (void)initData{
    for (ZSBrowseModel *browseItem in _browseItemArray) {
        CGRect verticalRect = CGRectZero;
        // 等比可根据小图宽高计算大图宽高
        if(_isEqualRatio){
            if(browseItem.smallImageView){
                verticalRect = [browseItem.smallImageView.image mss_getBigImageRectSizeWithScreenWidth:MSS_SCREEN_WIDTH screenHeight:MSS_SCREEN_HEIGHT];

            }
        }
        NSValue *verticalValue = [NSValue valueWithCGRect:verticalRect];
        [_verticalBigRectArray addObject:verticalValue];
    }
}

- (void)createBrowseView {
    self.view.backgroundColor = [UIColor blackColor];
    if(_snapshotView) {
        _snapshotView.hidden = YES;
        [self.view addSubview:_snapshotView];
    }
    
    _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    _bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bgView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    // 布局方式改为从上至下，默认从左到右
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // Section Inset就是某个section中cell的边界范围
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // 每行内部cell item的间距
    flowLayout.minimumInteritemSpacing = 0;
    // 每行的间距
    flowLayout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, _screenWidth + kBrowseSpace, _screenHeight) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor blackColor];
    [_collectionView registerClass:[ZSBrowseCollectionViewCell class] forCellWithReuseIdentifier:@"ZSBrowserCell"];
    _collectionView.contentOffset = CGPointMake(_currentIndex * (_screenWidth + kBrowseSpace), 0);
    [_bgView addSubview:_collectionView];
    
    _countLabel = [[UILabel alloc]init];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.frame = CGRectMake(0, _screenHeight - 50, _screenWidth, 50);
    _countLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_currentIndex + 1,(long)_browseItemArray.count];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    [_bgView addSubview:_countLabel];
    
    _browseRemindView = [[ZSBrowseRemindView alloc]initWithFrame:_bgView.bounds];
    [_bgView addSubview:_browseRemindView];
}

// 获取指定视图在window中的位置
- (CGRect)getFrameInWindow:(UIView *)view{
    // 改用[UIApplication sharedApplication].keyWindow.rootViewController.view，防止present新viewController坐标转换不准问题
    return [view.superview convertRect:view.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
}
- (void)showBrowseViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    } else{
        _snapshotView = [rootViewController.view snapshotViewAfterScreenUpdates:NO];
    }
    [rootViewController presentViewController:self animated:NO completion:NULL];
}

- (void)loadBrowseImageWithBrowseItem:(ZSBrowseModel *)browseItem Cell:(ZSBrowseCollectionViewCell *)cell bigImageRect:(CGRect)bigImageRect {
    // 停止加载
    [cell.loadingView stopAnimation];
    // 判断大图是否存在
    if([[SDImageCache sharedImageCache]diskImageExistsWithKey:browseItem.bigImageUrl])
    {
        // 显示大图
        [self showBigImage:cell.zoomScrollView.zoomImageView browseItem:browseItem rect:bigImageRect];
    }
    // 如果大图不存在
    else
    {
        self.isFirstOpen = NO;
        // 加载大图
        [self loadBigImageWithBrowseItem:browseItem cell:cell rect:bigImageRect];
    }
}
- (void)showBigImage:(UIImageView *)imageView browseItem:(ZSBrowseModel *)browseItem rect:(CGRect)rect
{
    // 取消当前请求防止复用问题
    [imageView sd_cancelCurrentImageLoad];
    // 如果存在直接显示图片
    imageView.image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:browseItem.bigImageUrl];
    // 当大图frame为空时，需要大图加载完成后重新计算坐标
    CGRect bigRect = [self getBigImageRectIfIsEmptyRect:rect bigImage:imageView.image];
    // 第一次打开浏览页需要加载动画
    if(self.isFirstOpen)
    {
        self.isFirstOpen = NO;
        imageView.frame = [self getFrameInWindow:browseItem.smallImageView];
        [UIView animateWithDuration:0.5 animations:^{
            imageView.frame = bigRect;
        }];
    }
    else
    {
        imageView.frame = bigRect;
    }
}

// 加载大图
- (void)loadBigImageWithBrowseItem:(ZSBrowseModel *)browseItem cell:(ZSBrowseCollectionViewCell *)cell rect:(CGRect)rect{
    UIImageView *imageView = cell.zoomScrollView.zoomImageView;
    // 加载圆圈显示
    [cell.loadingView startAnimation];
    // 默认为屏幕中间
    [imageView mss_setFrameInSuperViewCenterWithSize:CGSizeMake(browseItem.smallImageView.width, browseItem.smallImageView.height)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:browseItem.bigImageUrl] placeholderImage:browseItem.smallImageView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        // 关闭图片浏览view的时候，不需要继续执行小图加载大图动画
        if(self.collectionView.userInteractionEnabled) {
            // 停止加载
            [cell.loadingView stopAnimation];
            
            if(error){
                [self showBrowseRemindViewWithText:@"图片加载失败"];
            } else {
                // 当大图frame为空时，需要大图加载完成后重新计算坐标
                CGRect bigRect = [self getBigImageRectIfIsEmptyRect:rect bigImage:image];
                // 图片加载成功
                [UIView animateWithDuration:0.5 animations:^{
                    imageView.frame = bigRect;
                }];
            }
        }
    }];
}

// 当大图frame为空时，需要大图加载完成后重新计算坐标
- (CGRect)getBigImageRectIfIsEmptyRect:(CGRect)rect bigImage:(UIImage *)bigImage
{
    if(CGRectIsEmpty(rect)) {
        return [bigImage mss_getBigImageRectSizeWithScreenWidth:self.screenWidth screenHeight:self.screenHeight];
    }
    return rect;
}
#pragma mark UIColectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZSBrowseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZSBrowserCell" forIndexPath:indexPath];
    if(cell) {
        ZSBrowseModel *browseItem = [_browseItemArray objectAtIndex:indexPath.item];
        // 还原初始缩放比例
        cell.zoomScrollView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
        cell.zoomScrollView.zoomScale = 1.0f;
        // 将scrollview的contentSize还原成缩放前
        cell.zoomScrollView.contentSize = CGSizeMake(_screenWidth, _screenHeight);
        cell.zoomScrollView.zoomImageView.contentMode = browseItem.smallImageView.contentMode;
        cell.zoomScrollView.zoomImageView.clipsToBounds = browseItem.smallImageView.clipsToBounds;
        [cell.loadingView mss_setFrameInSuperViewCenterWithSize:CGSizeMake(30, 30)];
        CGRect bigImageRect = [_verticalBigRectArray[indexPath.row] CGRectValue];

        [self loadBrowseImageWithBrowseItem:browseItem Cell:cell bigImageRect:bigImageRect];
        
        __weak __typeof(self)weakSelf = self;
        [cell tapClick:^(ZSBrowseCollectionViewCell *browseCell) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf tap:browseCell];
        }];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _browseItemArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_screenWidth + kBrowseSpace, _screenHeight);
}

#pragma mark UIScrollViewDeletate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _currentIndex = scrollView.contentOffset.x / (_screenWidth + kBrowseSpace);
    _countLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_currentIndex + 1,(long)_browseItemArray.count];
}

#pragma mark Tap Method
- (void)tap:(ZSBrowseCollectionViewCell *)browseCell{

    if(_snapshotView) {
        _snapshotView.hidden = NO;
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }
    // 集合视图背景色设置为透明
    _collectionView.backgroundColor = [UIColor clearColor];
    // 动画结束前不可点击透明背景后的内容
    _collectionView.userInteractionEnabled = NO;
    // 显示状态栏
    [self setNeedsStatusBarAppearanceUpdate];
    // 停止加载
    NSArray *cellArray = _collectionView.visibleCells;
    for (ZSBrowseCollectionViewCell *cell in cellArray) {
        [cell.loadingView stopAnimation];
    }
    [_countLabel removeFromSuperview];
    _countLabel = nil;
    
    NSIndexPath *indexPath = [_collectionView indexPathForCell:browseCell];
    browseCell.zoomScrollView.zoomScale = 1.0f;
    ZSBrowseModel *browseItem = _browseItemArray[indexPath.row];
    /*
     建议小图列表的collectionView尽量不要复用，因为当小图的列表collectionview复用时，传进来的BrowseItem数组只有当前显示cell的smallImageView，在当前屏幕外的cell上的小图由于复用关系实际是没有的，所以只能有简单的渐变动画
     */
    if(browseItem.smallImageView) {
        CGRect rect = [self getFrameInWindow:browseItem.smallImageView];
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.5 animations:^{
            browseCell.zoomScrollView.zoomImageView.transform = transform;
            browseCell.zoomScrollView.zoomImageView.frame = rect;
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:NULL];
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:NULL];
        }];
    }
}

#pragma mark RemindView Method
- (void)showBrowseRemindViewWithText:(NSString *)text
{
    [_browseRemindView showRemindViewWithText:text];
    _bgView.userInteractionEnabled = NO;
    [self performSelector:@selector(hideRemindView) withObject:nil afterDelay:0.7];
}

- (void)hideRemindView
{
    [_browseRemindView hideRemindView];
    _bgView.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
