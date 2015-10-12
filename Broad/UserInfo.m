//
//  UserInfo.m
//  Invitation
//
//  Created by mac on 15/3/16.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

- (BOOL)isPermission:(NSString *)card andPer:(NSString *)perName
{
    if(self.permissions)
    {
        for(Permission *per in self.permissions)
        {
            if([per.ModuleCode isEqualToString:card] && [per.PermissionName isEqualToString:perName])
            {
                return YES;
            }
        }
    }
    return NO;
}


@end
