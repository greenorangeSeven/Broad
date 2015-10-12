//
//  DepartDetails.h
//  Broad
//  用户详情
//  Created by 赵腾欢 on 15/9/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepartDetails : Jastor

@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *PROJ_Name;
@property (copy, nonatomic) NSString *CustShortName_CN;
@property (copy, nonatomic) NSString *PROJ_ID;

@property (copy, nonatomic) NSString *IsNameChange;

@property (copy, nonatomic) NSString *yhcym;

/**
 * 城市
 */
@property (copy, nonatomic) NSString *City_CN;

/**
 * 国家
 */
@property (copy, nonatomic) NSString *Country_CN;

/**
 * 地址
 */
@property (copy, nonatomic) NSString *PostalAdd_CN;

/**
 * 曾用名
 */
@property (copy, nonatomic) NSString *OldProjName;

/**
 * 高层负责人
 */
@property (copy, nonatomic) NSString *Mgmt_High;

/**
 * 高层负责人职务
 */
@property (copy, nonatomic) NSString *Mgmt_High_Pos;

/**
 * 高层负责人电话
 */
@property (copy, nonatomic) NSString *Mgmt_High_Tel;

/**
 * 高层负责人部门
 */
@property (copy, nonatomic) NSString *Mgmt_High_Dept;

/**
 * 高层负责人邮箱
 */
@property (copy, nonatomic) NSString *Mgmt_High_EMail;

/**
 * 高层负责人手机
 */
@property (copy, nonatomic) NSString *Mgmt_High_Mobile;

/**
 * 中层负责人
 */
@property (copy, nonatomic) NSString *Mgmt_Midd;

/**
 * 中层负责人部门
 */
@property (copy, nonatomic) NSString *DeptMgmt_Midd;

/**
 * 中层负责人职务
 */
@property (copy, nonatomic) NSString *DeptMgmt_Midd_Pos;

/**
 * 中层负责人电话
 */
@property (copy, nonatomic) NSString *DeptMgmt_Midd_Tel;

/**
 * 中层负责人邮箱
 */
@property (copy, nonatomic) NSString *DeptMgmt_Midd_EMail;

/**
 * 中层负责人手机
 */
@property (copy, nonatomic) NSString *DeptMgmt_Midd_Mobile;

/**
 * 机房负责人
 */
@property (copy, nonatomic) NSString *Mgmt_MachRoom;

/**
 * 机房负责人部门
 */
@property (copy, nonatomic) NSString *Mgmt_MachRoom_Dept;

/**
 * 机房负责人职务
 */
@property (copy, nonatomic) NSString *Mgmt_MachRoom_Pos;

/**
 * 机房负责人电话
 */
@property (copy, nonatomic) NSString *Mgmt_MachRoom_Tel;

/**
 * 机房负责人邮箱
 */
@property (copy, nonatomic) NSString *Mgmt_MachRoom_Email;

/**
 * 机房负责人手机
 */
@property (copy, nonatomic) NSString *Mgmt_MachRoom_Mobile;

/**
 * 决策层
 */
@property (copy, nonatomic) NSString *Decision_Making;

/**
 * 决策层部门
 */
@property (copy, nonatomic) NSString *Decision_Making_Dept;

/**
 * 决策层职务
 */
@property (copy, nonatomic) NSString *Decision_Making_Pos;

/**
 * 决策层办公电话
 */
@property (copy, nonatomic) NSString *Decision_Making_Tel;

/**
 * 决策层办公传真
 */
@property (copy, nonatomic) NSString *Decision_Making_Fax;

/**
 * 决策层手机
 */
@property (copy, nonatomic) NSString *Decision_Making_Mobile;

/**
 * 决策层家庭地址
 */
@property (copy, nonatomic) NSString *Decision_Making_Add;

/**
 * 决策层家庭邮编
 */
@property (copy, nonatomic) NSString *Decision_Making_Zip;

/**
 * 决策层邮箱
 */
@property (copy, nonatomic) NSString *Decision_Making_Email;
@end
