//
//  UserInfo.h
//  Invitation
//
//  Created by mac on 15/3/16.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Permission.h"
#import "Jastor.h"

@interface UserInfo : Jastor

@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *UserName;
@property (copy, nonatomic) NSString *UserPwd;
@property (copy, nonatomic) NSString *TrueName;
@property (copy, nonatomic) NSString *Serils;
@property (copy, nonatomic) NSString *Department;
@property (copy, nonatomic) NSString *JiaoSe;
@property (copy, nonatomic) NSString *ActiveTime;
@property (copy, nonatomic) NSString *ZhiWei;
@property (copy, nonatomic) NSString *ZaiGang;
@property (copy, nonatomic) NSString *EmailStr;
@property (copy, nonatomic) NSString *IfLogin;
@property (copy, nonatomic) NSString *Sex;
@property (copy, nonatomic) NSString *BackInfo;
@property (copy, nonatomic) NSString *BirthDay;
@property (copy, nonatomic) NSString *MingZu;
@property (copy, nonatomic) NSString *SFZSerils;
@property (copy, nonatomic) NSString *HunYing;
@property (copy, nonatomic) NSString *ZhengZhiMianMao;
@property (copy, nonatomic) NSString *JiGuan;
@property (copy, nonatomic) NSString *HuKou;
@property (copy, nonatomic) NSString *XueLi;
@property (copy, nonatomic) NSString *ZhiCheng;
@property (copy, nonatomic) NSString *BiYeYuanXiao;
@property (copy, nonatomic) NSString *ZhuanYe;
@property (copy, nonatomic) NSString *CanJiaGongZuoTime;
@property (copy, nonatomic) NSString *JiaRuBenDanWeiTime;
@property (copy, nonatomic) NSString *JiaTingDianHua;
@property (copy, nonatomic) NSString *JiaTingAddress;
@property (copy, nonatomic) NSString *GangWeiBianDong;
@property (copy, nonatomic) NSString *JiaoYueBeiJing;
@property (copy, nonatomic) NSString *GongZuoJianLi;
@property (copy, nonatomic) NSString *SheHuiGuanXi;
@property (copy, nonatomic) NSString *JiangChengJiLu;
@property (copy, nonatomic) NSString *ZhiWuQingKuang;
@property (copy, nonatomic) NSString *PeiXunJiLu;
@property (copy, nonatomic) NSString *DanBaoJiLu;
@property (copy, nonatomic) NSString *NaoDongHeTong;
@property (copy, nonatomic) NSString *SheBaoJiaoNa;
@property (copy, nonatomic) NSString *TiJianJiLu;
@property (copy, nonatomic) NSString *BeiZhuStr;
@property (copy, nonatomic) NSString *FuJian;
@property (copy, nonatomic) NSString *POP3UserName;
@property (copy, nonatomic) NSString *POP3UserPwd;
@property (copy, nonatomic) NSString *POP3Server;
@property (copy, nonatomic) NSString *POP3Port;
@property (copy, nonatomic) NSString *SMTPUserName;
@property (copy, nonatomic) NSString *SMTPUserPwd;
@property (copy, nonatomic) NSString *SMTPServer;
@property (copy, nonatomic) NSString *SMTPFromEmail;
@property (copy, nonatomic) NSString *TiXingTime;
@property (copy, nonatomic) NSString *IfTiXing;
@property (copy, nonatomic) NSString *telphoneshort;
@property (copy, nonatomic) NSString *ok_sign;
@property (copy, nonatomic) NSString *Sort;
@property  int xzjb;
@property (copy, nonatomic) NSString *MyDept;
@property (copy, nonatomic) NSString *EnName;
@property (copy, nonatomic) NSString *IfCheBu;
@property (copy, nonatomic) NSString *IsGJB;

@property (strong, nonatomic) NSArray *permissions;

//判断是否有该权限
- (BOOL)isPermission:(NSString *) card andPer : (NSString *) perName;
@end
