//
//  Solution.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/4.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "Solution.h"

@implementation Solution

- (void)initWithSolution:(Solution *)solu
{
    self.ID = solu.ID;
    self.PROJ_ID = solu.PROJ_ID;
    self.ExecMan = solu.ExecMan;
    self.ExecDate = solu.ExecDate;
    self.Uploader = solu.Uploader;
    self.UploadTime = solu.UploadTime;
    self.OutFactNum = solu.OutFactNum;
    self.AirCondUnitMode = solu.AirCondUnitMode;
    self.ProdNum = solu.ProdNum;
    self.allfilename = solu.allfilename;
    self.imgList = [NSMutableArray arrayWithArray:solu.imgList];
}

@end
