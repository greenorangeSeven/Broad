//
//  DataSingleton.h
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LoadingCell.h"

@interface EndCellUtils : NSObject

#pragma 单例模式
+ (EndCellUtils *) Instance;
+ (id)allocWithZone:(NSZone *)zone;

//返回标示正在加载的选项
- (UITableViewCell *)getLoadEndCell:(UITableView *)tableView
                  andLoadOverString:(NSString *)loadOverString;

@end
