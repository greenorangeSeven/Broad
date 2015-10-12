//
//  Permission.h
//  Broad
//
//  Created by 赵腾欢 on 15/8/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jastor.h"

@interface Permission : Jastor

@property (copy, nonatomic) NSString *ModuleCode;

@property (copy, nonatomic) NSString *PermissionName;

@end
