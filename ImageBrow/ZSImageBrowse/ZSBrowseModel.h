//
//  ZSBrowseModel.h
//  ImageBrow
//
//  Created by suning on 2018/10/26.
//  Copyright © 2018年 suning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZSBrowseModel : NSObject

// 加载网络图片大图url地址
@property (nonatomic, copy)NSString *bigImageUrl;

// 小图（用来转换坐标用）
@property (nonatomic, strong)UIImageView *smallImageView;


@end
