//
//  MatnRec.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/3.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MatnRec.h"
#import "Img.h"

@implementation MatnRec

+ (id) imgList_class
{
    return [Img class];
}

-(void)initWithMatnRec:(MatnRec *)matnRec
{
    
    self.ID = matnRec.ID;
    self.Proj_ID = matnRec.Proj_ID;
    self.Exec_Man = matnRec.Exec_Man;
    self.Exec_Date = matnRec.Exec_Date;
    self.Exec_Date01 = matnRec.Exec_Date01;
    self.Exec_Date02 = matnRec.Exec_Date02;
    self.AirCondUnit_Mode = matnRec.AirCondUnit_Mode;
    self.OutFact_Num = matnRec.OutFact_Num;
    self.Pro_Num = matnRec.Pro_Num;
    self.Type = matnRec.Type;
    self.Project = matnRec.Project;
    self.Uploader = matnRec.Uploader;
    self.UploadTime = matnRec.UploadTime;
    self.AirCondUnit_Mode_Hold = matnRec.AirCondUnit_Mode_Hold;
    self.OutFact_Num_Hold = matnRec.OutFact_Num_Hold;
    self.Serv_Dept_Hold = matnRec.Serv_Dept_Hold;
    self.Engineer_Hold = matnRec.Engineer_Hold;
    self.CUST_Code_Hold = matnRec.CUST_Code_Hold;
    self.CUST_Name = matnRec.CUST_Name;
    self.Rating = matnRec.Rating;
    self.allfilename = matnRec.allfilename;
    self.allfilename02 = matnRec.allfilename02;
    self.allfilename03 = matnRec.allfilename03;
    self.allfilename04 = matnRec.allfilename04;
    self.allfilename05 = matnRec.allfilename05;
    self.allfilename06 = matnRec.allfilename06;
    self.allfilename07 = matnRec.allfilename07;
    self.allfilename08 = matnRec.allfilename08;
    self.allfilename09 = matnRec.allfilename09;
    self.EngineerNote = matnRec.EngineerNote;
    self.EngineerSign = matnRec.EngineerSign;
    self.EngineerSignDate = matnRec.EngineerSignDate;
    self.ManagerNote = matnRec.ManagerNote;
    self.ManagerSign = matnRec.ManagerSign;
    self.ManagerSignDate = matnRec.ManagerSignDate;
    self.UserHQNote = matnRec.UserHQNote;
    self.UserHQSign = matnRec.UserHQSign;
    self.UserHQSignDate = matnRec.UserHQSignDate;
    self.Mark = matnRec.Mark;
    self.imgList = [NSMutableArray arrayWithArray:matnRec.imgList];
    self.isOld = matnRec.isOld;
    self.dayType = matnRec.dayType;
}

@end
