//
//  Invoice.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Invoice : Jastor
/**
 * 自增长列
 */
@property (nonatomic, copy) NSString *ID;

/**
 * 关联流程表FlowInstance的Mark
 */
@property (nonatomic, copy) NSString *Invoice_ID;

/**
 * 32位的项目ID(对应用户信息表的)
 */
@property (nonatomic, copy) NSString *Proj_ID;

/**
 * 申请日期
 */
@property (nonatomic, copy) NSString *App_Date;

/**
 * 编号（没用到）
 */
@property (nonatomic, copy) NSString *Number;

/**
 * 发票号
 */
@property (nonatomic, copy) NSString *Invoice_No;

/**
 * 协议编号
 */
@property (nonatomic, copy) NSString *CONTR_No;

/**
 * 预付款日期
 */
@property (nonatomic, copy) NSString *BefPay_Date;

/**
 * 付款金额
 */
@property double BefPay_AMT;

/**
 * 申请开票金额
 */
@property double App_InvoiceAMT;

/**
 * 申请开票原因
 */
@property (nonatomic, copy) NSString *App_reason;

/**
 * 开票项目
 */
@property (nonatomic, copy) NSString *Invoice_Item;

/**
 * 发票类型
 */
@property (nonatomic, copy) NSString *Invoice_Type;

/**
 * 合同乙方
 */
@property (nonatomic, copy) NSString *CONTR_SecParty;

/**
 * 合同乙方为“其他”时，具体的乙方名
 */
@property (nonatomic, copy) NSString *SecParty_CustName;

/**
 * 服务部
 */
@property (nonatomic, copy) NSString *Serv_Dept;

/**
 * 申请人
 */
@property (nonatomic, copy) NSString *App_Name;

/**
 * 主管意见
 */
@property (nonatomic, copy) NSString *Leader_Opinion;

/**
 * 主管意见签名
 */
@property (nonatomic, copy) NSString *Leader_Sign;

/**
 * 是否已开票
 */
@property (nonatomic, copy) NSString *MakeOutInvoice_Sign;

/**
 * 开票日期
 */
@property (nonatomic, copy) NSString *MakeOutInvoice_Date;

/**
 * 财务意见
 */
@property (nonatomic, copy) NSString *Fin_Opinion;

/**
 * 工程师签收
 */
@property (nonatomic, copy) NSString *SignFor_INF;

/**
 * 单位名称
 */
@property (nonatomic, copy) NSString *CUST_Name;

/**
 * 主管签名日期
 */
@property (nonatomic, copy) NSString *Leader_SignDate;

/**
 * 用中总经理意见
 */
@property (nonatomic, copy) NSString *UserGenManager_Opinion;

/**
 * 用中总经理签名
 */
@property (nonatomic, copy) NSString *UserGenManager_Sign;

/**
 * 用中总经理签名日期
 */
@property (nonatomic, copy) NSString *UserGenManager_SignDate;

/**
 * 财务签名日期
 */
@property (nonatomic, copy) NSString *Fin_SignDate;

/**
 * 工程师签收时间
 */
@property (nonatomic, copy) NSString *SignFor_Date;

/**
 * 	财务签名
 */
@property (nonatomic, copy) NSString *Fin_Sign;

@property (nonatomic, copy) NSString *TaxNumber;
@property (nonatomic, copy) NSString *TompanyAdd;
@property (nonatomic, copy) NSString *Bank;

@end
