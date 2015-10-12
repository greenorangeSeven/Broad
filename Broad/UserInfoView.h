//
//  UserInfoView.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DepartDetails.h"

@interface UserInfoView : UIViewController

@property (strong, nonatomic) DepartDetails *departDetails;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
