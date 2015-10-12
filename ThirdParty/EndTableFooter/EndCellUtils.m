//
//  DataSingleton.m
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EndCellUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation EndCellUtils

//返回标示正在加载的选项
- (UITableViewCell *)getLoadEndCell:(UITableView *)tableView
                   andLoadOverString:(NSString *)loadOverString
{
    LoadingCell * cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[LoadingCell class]]) {
                cell = (LoadingCell *)o;
                break;
            }
        }
    }
    cell.lbl.font = [UIFont boldSystemFontOfSize:16.0];
    cell.lbl.text = loadOverString;
    
    return cell;
}

#pragma 单例模式定义
static EndCellUtils * instance = nil;
+(EndCellUtils *) Instance
{
    @synchronized(self)
    {
        if(nil == instance)
        {
            [self new];
        }
    }
    return instance;
}
+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}
@end
