//
//  SecurityInfo.h
//  Broad
//
//  Created by Seven on 16/12/19.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityInfo : Jastor

/**
 * 自增长列
 */
@property (copy, nonatomic) NSString *ID;

/**
 * 32位的项目ID(对应用户信息表的)
 */
@property (copy, nonatomic) NSString *Proj_ID;

/**
 * 工程师
 */
@property (copy, nonatomic) NSString *Exec_Man;

/**
 * 服务时间
 */
@property (copy, nonatomic) NSString *Exec_Date;

/**
 * 服务项目
 */
@property (copy, nonatomic) NSString *Project;

/**
 * 上传人
 */
@property (copy, nonatomic) NSString *Uploader;

/**
 * 上传时间
 */
@property (copy, nonatomic) NSString *UploadTime;

/**
 * 附件（英文版服务形式）
 */
@property (copy, nonatomic) NSString *allfilename;

/**
 * app内使用
 */
@property (strong, nonatomic) NSMutableArray *imgList;

-(void)initWithSecurity:(SecurityInfo *)security;

@end
