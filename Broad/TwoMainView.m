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
#import "SecurityTableView.h"

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
    
    UITapGestureRecognizer *securityTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(securityAction)];
    [self.securityView addGestureRecognizer:securityTap];
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
    [self getUserinfoSecurity];
}

- (void)weihuAction
{
    [self getWeiHuSecurity];
}

- (void)rongyeAction
{
    [self getRongYeSecurity];
}

- (void)yukaiAction
{
    YuKaiListView *yukaiView = [[YuKaiListView alloc] init];
    [self.navigationController pushViewController:yukaiView animated:YES];
}

- (void)securityAction
{
    [self getAnQuanSecurity];
}

- (void)getUserinfoSecurity
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModule '%@','DA01'", app.userinfo.JiaoSe];
    [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sqlStr,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error;
             NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             NSArray *securityList = [Tool readJsonToObjArray:jsonArray andObjClass:[UserSecurity class]];
             BOOL haveQueryRecord = NO;
             for (UserSecurity *s in securityList) {
                 if ([s.ModuleCode isEqualToString:@"DA01"] && [s.PermissionName isEqualToString:@"查看"]) {
                     haveQueryRecord = YES;
                     break;
                 }
             }
             if(haveQueryRecord)
             {
                 UserInfoView *userinfoView = [[UserInfoView alloc] init];
                 [self.navigationController pushViewController:userinfoView animated:YES];
             }
             else
             {
                 [Tool showCustomHUD:@"您无查看权限" andView:self.view andImage:nil andAfterDelay:1.2f];
             }
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)getWeiHuSecurity
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModule '%@','DA0301'", app.userinfo.JiaoSe];
    [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sqlStr,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error;
             NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             NSArray *securityList = [Tool readJsonToObjArray:jsonArray andObjClass:[UserSecurity class]];
             BOOL haveQueryRecord = NO;
             for (UserSecurity *s in securityList) {
                 if ([s.ModuleCode isEqualToString:@"DA0301"] && [s.PermissionName isEqualToString:@"查看"]) {
                     haveQueryRecord = YES;
                     break;
                 }
             }
             if(haveQueryRecord)
             {
                 WeiXiuListView *weixiuView = [[WeiXiuListView alloc] init];
                 [self.navigationController pushViewController:weixiuView animated:YES];
             }
             else
             {
                 [Tool showCustomHUD:@"您无查看权限" andView:self.view andImage:nil andAfterDelay:1.2f];
             }
         };
         NSLog(@"%@", operation.responseString);
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)getAnQuanSecurity
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModule '%@','DA0305'", app.userinfo.JiaoSe];
    [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sqlStr,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error;
             NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             NSArray *securityList = [Tool readJsonToObjArray:jsonArray andObjClass:[UserSecurity class]];
             BOOL haveQueryRecord = NO;
             for (UserSecurity *s in securityList) {
                 if ([s.ModuleCode isEqualToString:@"DA0305"] && [s.PermissionName isEqualToString:@"查看"]) {
                     haveQueryRecord = YES;
                     break;
                 }
             }
             if(haveQueryRecord)
             {
                 SecurityTableView *securityView = [[SecurityTableView alloc] init];
                 [self.navigationController pushViewController:securityView animated:YES];
             }
             else
             {
                 [Tool showCustomHUD:@"您无查看权限" andView:self.view andImage:nil andAfterDelay:1.2f];
             }
         };
         NSLog(@"%@", operation.responseString);
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)getRongYeSecurity
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModule '%@','DA0302'", app.userinfo.JiaoSe];
    [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sqlStr,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error;
             NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             NSArray *securityList = [Tool readJsonToObjArray:jsonArray andObjClass:[UserSecurity class]];
             BOOL haveQueryRecord = NO;
             for (UserSecurity *s in securityList) {
                 if ([s.ModuleCode isEqualToString:@"DA0302"] && [s.PermissionName isEqualToString:@"查看"]) {
                     haveQueryRecord = YES;
                     break;
                 }
             }
             if(haveQueryRecord)
             {
                 RongYeListView *rongyeView = [[RongYeListView alloc] init];
                 [self.navigationController pushViewController:rongyeView animated:YES];
             }
             else
             {
                 [Tool showCustomHUD:@"您无查看权限" andView:self.view andImage:nil andAfterDelay:1.2f];
             }
         };
         NSLog(@"%@", operation.responseString);
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (BOOL)getSecurity:(NSString *)SecurityCode andSecurityTxt:(NSString *)reName
{
    static BOOL haveQueryRecord = NO;
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModule '%@','%@'", app.userinfo.JiaoSe, SecurityCode];
    
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url]]];
        
        [request setUseCookiePersistence:NO];
        [request setTimeOutSeconds:30];
        
        [request setPostValue:sqlStr forKey:@"sqlstr"];
        [request setDefaultResponseEncoding:NSUTF8StringEncoding];
        [request startSynchronous];
        
        NSError *error = [request error];
        if (!error)
        {
            NSString *response = [request responseString];
            XMLParserUtils *utils = [[XMLParserUtils alloc] init];
            utils.parserFail = ^()
            {
                [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
            };
            utils.parserOK = ^(NSString *string)
            {
                NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSArray *securityList = [Tool readJsonToObjArray:jsonArray andObjClass:[UserSecurity class]];
                BOOL haveQueryRecord = NO;
                for (UserSecurity *s in securityList) {
                    if ([s.ModuleCode isEqualToString:@"DA01"] && [s.PermissionName isEqualToString:@"查看"]) {
                        haveQueryRecord = YES;
                        break;
                    }
                }
            };
            
            [utils stringFromparserXML:response target:@"string"];
        }
        else
        {
            haveQueryRecord = NO;
        }
    
    return haveQueryRecord;
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
