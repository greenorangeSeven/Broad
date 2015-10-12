//
//  TwoMainView.m
//  Broad
//  二级首页
//  Created by 赵腾欢 on 15/8/31.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "TwoMainView.h"
#import "WeiXiuListView.h"
#import "RongYeListView.h"
#import "YuKaiListView.h"
#import "UserInfoView.h"

@interface TwoMainView ()

@end

@implementation TwoMainView

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    titleLabel.text = app.depart.CustShortName_CN;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UITapGestureRecognizer *userinfoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userinfoAction)];
    [self.userinfoView addGestureRecognizer:userinfoTap];
    
    UITapGestureRecognizer *weihuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weihuAction)];
    [self.weixiuView addGestureRecognizer:weihuTap];
    
    UITapGestureRecognizer *rongyeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rongyeAction)];
    [self.rongyeView addGestureRecognizer:rongyeTap];
    
    UITapGestureRecognizer *yukaiTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yukaiAction)];
    [self.fapiaoView addGestureRecognizer:yukaiTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)userinfoAction
{
    UserInfoView *userinfoView = [[UserInfoView alloc] init];
    [self.navigationController pushViewController:userinfoView animated:YES];
}

- (void)weihuAction
{
    WeiXiuListView *weixiuView = [[WeiXiuListView alloc] init];
    [self.navigationController pushViewController:weixiuView animated:YES];
}

- (void)rongyeAction
{
    RongYeListView *rongyeView = [[RongYeListView alloc] init];
    [self.navigationController pushViewController:rongyeView animated:YES];
}

- (void)yukaiAction
{
    YuKaiListView *yukaiView = [[YuKaiListView alloc] init];
    [self.navigationController pushViewController:yukaiView animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
