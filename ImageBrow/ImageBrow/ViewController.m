//
//  ViewController.m
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import "ViewController.h"

#import "UIView+Additions.h"
#import "UIImageView+WebCache.h"
#import "MSSCollectionViewCell.h"
#import "ZSBrowseImageViewController.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIViewControllerTransitioningDelegate>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSArray *smallUrlArray;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 70, 100, 50);
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"清空缓存" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    _smallUrlArray = @[@"http://127.0.0.1/image1.jpg",
                       @"http://127.0.0.1/0s.jpg",
                       @"http://127.0.0.1/0s.jpg",
                       @"http://127.0.0.1/0s.jpg",
                       @"http://127.0.0.1/0s.jpg",
                       @"http://127.0.0.1/image1.jpg"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    flowLayout.itemSize = CGSizeMake(80, 80);
    flowLayout.minimumLineSpacing = 10;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, btn.bottom, MSS_SCREEN_WIDTH, MSS_SCREEN_HEIGHT - btn.bottom) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    //cell注册
    [_collectionView registerClass:[MSSCollectionViewCell class] forCellWithReuseIdentifier:@"MSSCollectionViewCell"];
    [self.view addSubview:_collectionView];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_smallUrlArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSSCollectionViewCell" forIndexPath:indexPath];
    if (cell)
    {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_smallUrlArray[indexPath.row]]];
        cell.imageView.tag = indexPath.row + 100;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.clipsToBounds = YES;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *bigUrlArray = @[@"http://127.0.0.1/image1.jpg",
                             @"http://127.0.0.1/0s.jpg",
                             @"http://127.0.0.1/0s.jpg",
                             @"http://127.0.0.1/0s.jpg",
                             @"http://127.0.0.1/0s.jpg",
                             @"http://127.0.0.1/image1.jpg"];
    // 加载网络图片
    NSMutableArray *browseItemArray = [[NSMutableArray alloc]init];
    int i = 0;
    for(i = 0;i < [_smallUrlArray count];i++)
    {
        UIImageView *imageView = [self.view viewWithTag:i + 100];
        ZSBrowseModel *browseItem = [[ZSBrowseModel alloc]init];
        browseItem.bigImageUrl = bigUrlArray[i];// 加载网络图片大图地址
        browseItem.smallImageView = imageView;// 小图
        [browseItemArray addObject:browseItem];
    }
    MSSCollectionViewCell *cell = (MSSCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    ZSBrowseImageViewController *bvc = [[ZSBrowseImageViewController alloc]initWithBrowseItemArray:browseItemArray currentIndex:cell.imageView.tag - 100];
    
    [bvc showBrowseViewController];
    
}


- (void)btnClick
{
    [[SDImageCache sharedImageCache]clearMemory];
    [[SDImageCache sharedImageCache]clearDiskOnCompletion:^{
        [_collectionView reloadData];
    }];
}


@end
