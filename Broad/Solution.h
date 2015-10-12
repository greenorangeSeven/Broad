//
//  Solution.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/4.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Solution : Jastor

/**
 * 自增长列
 */
@property (copy, nonatomic) NSString *ID;

/**
 * 32位的项目ID
 */
@property (copy, nonatomic) NSString *PROJ_ID;

/**
 * 责任工程师
 */
@property (copy, nonatomic) NSString *ExecMan;

/**
 * 取样时间
 */
@property (copy, nonatomic) NSString *ExecDate;

/**
 * 上传人
 */
@property (copy, nonatomic) NSString *Uploader;

/**
 * 上传时间
 */
@property (copy, nonatomic) NSString *UploadTime;

/**
 * 出厂编号
 */
@property (copy, nonatomic) NSString *OutFactNum;

/**
 * 机型
 */
@property (copy, nonatomic) NSString *AirCondUnitMode;

/**
 * 生产编号
 */
@property (copy, nonatomic) NSString *ProdNum;

/**
 * 附件
 */
@property (copy, nonatomic) NSString *allfilename;

/**
 * app内使用
 */
@property (strong, nonatomic) NSMutableArray *imgList;

- (void)initWithSolution:(Solution *)solu;

@end
