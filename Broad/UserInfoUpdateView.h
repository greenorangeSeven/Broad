//
//  UserInfoUpdateView.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/3.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DepartDetails.h"

@interface UserInfoUpdateView : UIViewController

@property (assign, nonatomic) DepartDetails *departDetails;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
