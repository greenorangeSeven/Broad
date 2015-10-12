//
//  MatnRec.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/3.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatnRec : Jastor

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

@property (copy, nonatomic) NSString *Exec_Date01;
@property (copy, nonatomic) NSString *Exec_Date02;

/**
 * 机组型号
 */
@property (copy, nonatomic) NSString *AirCondUnit_Mode;

/**
 * 出厂编号
 */
@property (copy, nonatomic) NSString *OutFact_Num;

/**
 * 台数（没用到）
 */
@property (copy, nonatomic) NSString *Pro_Num;

/**
 * 服务类型
 */
@property (copy, nonatomic) NSString *Type;

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
 * 机组型号保留（没用到）
 */
@property (copy, nonatomic) NSString *AirCondUnit_Mode_Hold;

/**
 * 出厂编号（没用到）
 */
@property (copy, nonatomic) NSString *OutFact_Num_Hold;

/**
 * 服务部（没用到）
 */
@property (copy, nonatomic) NSString *Serv_Dept_Hold;

/**
 * 工程师（没用到）
 */
@property (copy, nonatomic) NSString *Engineer_Hold;

/**
 * 客户代码（没用到）
 */
@property (copy, nonatomic) NSString *CUST_Code_Hold;

/**
 * 用户名称（没用到）
 */
@property (copy, nonatomic) NSString *CUST_Name;

/**
 * 英文版主管打分
 */
@property (copy, nonatomic) NSString *Rating;

/**
 * 附件（英文版服务形式）
 */
@property (copy, nonatomic) NSString *allfilename;

/**
 * 英文版现场照片（年4次保养附件）
 */
@property (copy, nonatomic) NSString *allfilename02;

/**
 * 英文版触摸屏照片（年4次保养附件）
 */
@property (copy, nonatomic) NSString *allfilename03;
@property (copy, nonatomic) NSString *allfilename04;//	varchar(8000)	英文版其它照片（年4次保养附件）
@property (copy, nonatomic) NSString *allfilename05;//	varchar(8000)	年4次保养附件
@property (copy, nonatomic) NSString *allfilename06;//	varchar(8000)	年4次保养附件
@property (copy, nonatomic) NSString *allfilename07;//	varchar(8000)	年4次保养附件
@property (copy, nonatomic) NSString *allfilename08;//	varchar(8000)	年4次保养附件
@property (copy, nonatomic) NSString *allfilename09;//	varchar(8000)	年4次保养附件
@property (copy, nonatomic) NSString *EngineerNote;//	varchar(5000)	英文版工程师描述
@property (copy, nonatomic) NSString *EngineerSign;//	varchar(50)	英文版工程师签名
@property (copy, nonatomic) NSString *EngineerSignDate;//	datetime	英文版工程师签名时间
@property (copy, nonatomic) NSString *ManagerNote;//	varchar(5000)	英文版主管评价
@property (copy, nonatomic) NSString *ManagerSign;//	varchar(50)	英文版主管签名
@property (copy, nonatomic) NSString *ManagerSignDate;//	datetime	英文版主管签名时间
@property (copy, nonatomic) NSString *UserHQNote;//	varchar(5000)	英文版国际部经理评价
@property (copy, nonatomic) NSString *UserHQSign;//	varchar(50)	英文版国际部经理签名
@property (copy, nonatomic) NSString *UserHQSignDate;//	datetime	英文版国际部经理签名时间
@property (copy, nonatomic) NSString *Mark;//	varchar(50)	英文版流程唯一标示


/**
 * app内使用
 */
@property (strong, nonatomic) NSMutableArray *imgList;

/**
 * app内使用，标识老版本
 */
@property  BOOL isOld;

/**
 * app内使用,标识是日常保养
 */
@property BOOL dayType;

-(void)initWithMatnRec:(MatnRec *)matnRec;

@end
