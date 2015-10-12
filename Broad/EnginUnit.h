//
//  EnginUnit.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/7.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnginUnit : Jastor

/**
 * 自增长列
 */
@property (copy, nonatomic) NSString *ID;

/**
 * 32位的项目ID(对应用户信息表的)
 */
@property (copy, nonatomic) NSString *PROJ_ID;

/**
 * 首次填表人
 */
@property (copy, nonatomic) NSString *First_FillMan;

/**
 * 首填日期
 */
@property (copy, nonatomic) NSString *First_FillDate;

/**
 * 补充填表人
 */
@property (copy, nonatomic) NSString *Add_FillMan;

/**
 * 补填日期
 */
@property (copy, nonatomic) NSString *Add_FillDate;

/**
 * 发货日期
 */
@property (copy, nonatomic) NSString *Send_Date;

/**
 * 生产编号
 */
@property (copy, nonatomic) NSString *Prod_Num;

/**
 * 出厂编号
 */
@property (copy, nonatomic) NSString *OutFact_Num;

/**
 * 机组型号
 */
@property (copy, nonatomic) NSString *AirCondUnit_Mode;

@end
