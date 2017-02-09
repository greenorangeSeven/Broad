//
//  SolutionMgmt.h
//  Broad
//
//  Created by Seven on 17/2/7.
//  Copyright © 2017年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SolutionMgmt : Jastor

/**
 * 自增长列
 */
@property (copy, nonatomic) NSString *ID;

/**
 * 取样时间
 */
@property (copy, nonatomic) NSString *Exec_Date;

/**
 * 出厂编号
 */
@property (copy, nonatomic) NSString *OutFact_Num;

/**
 * 样品接收时间
 */
@property (copy, nonatomic) NSString *ReceiveDate;

/**
 * 检查结果
 */
@property (copy, nonatomic) NSString *HandleOpinion;

/**
 * 机型
 */
@property (copy, nonatomic) NSString *AirCondUnit_Mode;

/**
 * 工程师
 */
@property (copy, nonatomic) NSString *Exec_Man;

/**
 * 用户名称
 */
@property (copy, nonatomic) NSString *CUST_Name;

/**
 * 处理时间
 */
@property (copy, nonatomic) NSString *HandleTime;

/**
 * 加%铬酸锂量
 */
@property (copy, nonatomic) NSString *LithiumByEngineer;

///**
// * 附件
// */
//@property (copy, nonatomic) NSString *Allfilename;

/**
 * 附件
 */
@property (copy, nonatomic) NSString *allfilename;

/**
 * 其他
 */
@property (copy, nonatomic) NSString *Other;

@property (copy, nonatomic) NSString *Mark;

/**
 * LiBr浓度
 */
@property (copy, nonatomic) NSString *LiBr;
/**
 * LiBr浓度结果
 */
@property (copy, nonatomic) NSString *LiBrResult;
/**
 * 密度
 */
@property (copy, nonatomic) NSString *Density;
/**
 * 温度
 */
@property (copy, nonatomic) NSString *Temp;
/**
 * 溶液外观
 */
@property (copy, nonatomic) NSString *SolutionOutward;
/**
 * 溶液外观结果
 */
@property (copy, nonatomic) NSString *OutwardResult;
/**
 * PH值
 */
@property (copy, nonatomic) NSString *PH;
/**
 * PH值结果
 */
@property (copy, nonatomic) NSString *PHResult;
/**
 * 全铜
 */
@property (copy, nonatomic) NSString *CU2;
/**
 * 全铜结果
 */
@property (copy, nonatomic) NSString *CU2Result;
/**
 * 全铁
 */
@property (copy, nonatomic) NSString *Fe;
/**
 * 全铁结果
 */
@property (copy, nonatomic) NSString *FeResult;
/**
 * Li2CrO4
 */
@property (copy, nonatomic) NSString *Licro4;
/**
 * Licro4结果
 */
@property (copy, nonatomic) NSString *Licro4Result;
/**
 * 沉淀量
 */
@property (copy, nonatomic) NSString *Precipitation;
/**
 * 沉淀物结果
 */
@property (copy, nonatomic) NSString *PrecipitationResult;
/**
 * Cl-(外厂溶液时)
 */
@property (copy, nonatomic) NSString *Cl;
/**
 * Cl-(外厂溶液时)结果
 */
@property (copy, nonatomic) NSString *ClResult;
/**
 * 溶液状态
 */
@property (copy, nonatomic) NSString *Result;

/**
 * 上传时间
 */
@property (copy, nonatomic) NSString *UploadTime1;

/**
 * 上传人
 */
@property (copy, nonatomic) NSString *Uploader1;

/**
 * 溶液取样图片
 */
@property (copy, nonatomic) NSString *allfilename1;

@end
