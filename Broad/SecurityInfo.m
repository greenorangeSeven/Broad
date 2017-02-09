//
//  SecurityInfo.m
//  Broad
//
//  Created by Seven on 16/12/19.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import "SecurityInfo.h"
#import "Img.h"

@implementation SecurityInfo

+ (id) imgList_class
{
    return [Img class];
}

-(void)initWithSecurity:(SecurityInfo *)security
{
    self.ID = security.ID;
    self.Proj_ID = security.Proj_ID;
    self.Exec_Man = security.Exec_Man;
    self.Exec_Date = security.Exec_Date;
    self.Project = security.Project;
    self.Uploader = security.Uploader;
    self.UploadTime = security.UploadTime;
    self.allfilename = security.allfilename;
    self.imgList = [NSMutableArray arrayWithArray:security.imgList];
}

@end
