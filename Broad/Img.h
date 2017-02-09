//
//  Img.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/3.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Img : Jastor

/**
 * 后台图片
 */
@property (copy, nonatomic) NSString *Url;

@property (copy, nonatomic) NSString *fileName;

/**
 * 前端本地图片
 */
@property (copy, nonatomic) UIImage *img;

@property (copy, nonatomic) NSString *tag;
@end
