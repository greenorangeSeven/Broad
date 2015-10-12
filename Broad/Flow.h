//
//  FlowList.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/19.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "Jastor.h"

@interface Flow : Jastor

@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *rowid;
@property (copy, nonatomic) NSString *ApplyDateTime;
@property (copy, nonatomic) NSString *FlowName;
@property (copy, nonatomic) NSString *ApplyStatus;
@property (copy, nonatomic) NSString *PROJ_Name;
@property (copy, nonatomic) NSString *Mark;
@property (copy, nonatomic) NSString *TableName;
@property (copy, nonatomic) NSString *ServDept;
@property (copy, nonatomic) NSString *Engineer;
@property (copy, nonatomic) NSString *StatusName;
@property (copy, nonatomic) NSString *ArriveTime;

@end
