//
//  ProjInf.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjInf : Jastor

/**
 * 自增长列
 */
@property (nonatomic, copy) NSString *ID;

/**
 * 32位的项目ID(对应用户信息表的)
 */
@property (nonatomic, copy) NSString *PROJ_ID;

/**
 * 协议编号
 */
@property (nonatomic, copy) NSString *Agt_No;

/**
 * 协议用户名称
 */
@property (nonatomic, copy) NSString *CN_Name;

/**
 * 协议类型
 */
@property (nonatomic, copy) NSString *Agt_Type;

/**
 * 项目类别
 */
@property (nonatomic, copy) NSString *Proj_GATE;

/**
 * 协议服务部
 */
@property (nonatomic, copy) NSString *Agt_ServDept;

/**
 * 协议签订日期
 */
@property (nonatomic, copy) NSString *Agt_Judm_Date;

/**
 * 协议签订人
 */
@property (nonatomic, copy) NSString *Agt_Judm_Man;

/**
 * 协议开始日期
 */
@property (nonatomic, copy) NSString *Agt_BegDate;

/**
 * 协议结束日期
 */
@property (nonatomic, copy) NSString *Agt_EndDate;

/**
 * 标准金额
 */
@property (nonatomic, copy) NSString *Agt_Std_Amt;

/**
 * 协议金额
 */
@property (nonatomic, copy) NSString *Agt_Amt;

/**
 * 备注
 */
@property (nonatomic, copy) NSString *Agt_Memo;

/**
 * 上传人
 */
@property (nonatomic, copy) NSString *Uploader;

/**
 * 上传时间
 */
@property (nonatomic, copy) NSString *UploadTime;

/**
 * 附件
 */
@property (nonatomic, copy) NSString *allfilename;

/**
 * 出厂编号
 */
@property (nonatomic, copy) NSString *OutFact_Num;

/**
 * 机组型号
 */
@property (nonatomic, copy) NSString *AirCondUnit_Mode;

/**
 * 规定付款日期
 */
@property (nonatomic, copy) NSString *gdfkrq;

/**
 * 首次到款日期
 */
@property (nonatomic, copy) NSString *scdkrq;

/**
 * 到款金额总计
 */
@property (nonatomic, copy) NSString *dkjezj;

/**
 * 单次协议按年协议计算
 */
@property (nonatomic, copy) NSString *lnx;

/**
 * BIS数据库协议表ID
 */
@property (nonatomic, copy) NSString *fw_sno;

/**
 * 项目信息
 */
@property (nonatomic, copy) NSString *xmxx;

@end
