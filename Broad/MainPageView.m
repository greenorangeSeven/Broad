//
//  MainPageView.m
//  Invitation
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MainPageView.h"
#import "UserListView.h"
#import "MessageListView.h"

@interface MainPageView ()
{
}

@end

@implementation MainPageView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"首页";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 58, 44);
    [backBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [backBtn setTitle:@"注销" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goTwoMain)];
    [self.usersView addGestureRecognizer:userTap];
    
    UITapGestureRecognizer *msgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goMsgView)];
    [self.msgView addGestureRecognizer:msgTap];
}

#pragma mark 跳转到用户列表页面
- (void)goTwoMain
{
    UserListView *userlistView = [[UserListView alloc] init];
    [self.navigationController pushViewController:userlistView animated:YES];
}

#pragma mark 跳转到消息提醒
- (void)goMsgView
{
    MessageListView *msglistView = [[MessageListView alloc] init];
    [self.navigationController pushViewController:msglistView animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (void)logout
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.userinfo = nil;
    [self.navigationController popViewControllerAnimated: YES];
}

@end
