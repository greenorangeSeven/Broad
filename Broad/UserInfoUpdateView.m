//
//  UserInfoUpdateView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/3.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserInfoUpdateView.h"
#import "PrintObject.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "UserInfoView.h"

@interface UserInfoUpdateView ()<UIWebViewDelegate>
{
    MBProgressHUD *hud;
    JSContext *context;
    DepartDetails *tempDepart;
}

@end

@implementation UserInfoUpdateView

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"修改";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 58, 44);
    [addBtn setTitle:@"提交" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    self.webView.delegate = self;
    [self initdata];
}

- (void)initdata
{
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"userdetailsupdate" ofType:@"html"];
    NSString *htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    NSURL *url =[NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:htmlStr baseURL:url];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewP
{
    
    NSString *jsonStr = [[NSString alloc] initWithData:[PrintObject getJSON:self.departDetails options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"bindData(%@);",jsonStr]];
    JSContext *tepcontext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    tepcontext[@"commitios"] = ^(NSString *infoJson)
    {
        [self update:infoJson];
    };
    context = tepcontext;
}

- (void)update
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    
    JSValue *function = context[@"commit"];
    [function callWithArguments:nil];
}

- (void)update:(NSString *)infoJson
{
    [self.view endEditing:YES];
    tempDepart = [Tool readJsonToObj:infoJson andObjClass:[DepartDetails class]];
    
    if(!tempDepart)
    {
        [Tool showCustomHUD:@"修改失败,请重试" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (![self.departDetails.PROJ_Name isEqualToString:tempDepart.PROJ_Name])
    {
        if (self.departDetails.yhcym.length == 0)
        {
            tempDepart.yhcym = [NSString stringWithFormat:@"%@(%@)",self.departDetails.PROJ_Name,[Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm:ss"]];
        }
        else
        {
            tempDepart.yhcym = [NSString stringWithFormat:@"%@(%@)|%@",self.departDetails.PROJ_Name,[Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm:ss"],self.departDetails.yhcym];
        }
        tempDepart.IsNameChange = @"1";
    }
    else
    {
        tempDepart.yhcym = self.departDetails.yhcym;
        tempDepart.IsNameChange = self.departDetails.IsNameChange;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"update TB_CUST_ProjInf set PROJ_Name='%@',CustShortName_CN='%@',City_CN='%@',Country_CN='%@',PostalAdd_CN='%@',yhcym='%@',Mgmt_High_Pos='%@',Mgmt_High_Tel='%@',Mgmt_High_Dept='%@',Mgmt_High_EMail='%@',Mgmt_High_Mobile='%@',Mgmt_Midd='%@',DeptMgmt_Midd='%@',DeptMgmt_Midd_Pos='%@',DeptMgmt_Midd_Tel='%@',DeptMgmt_Midd_EMail='%@',DeptMgmt_Midd_Mobile='%@',Mgmt_MachRoom='%@',Mgmt_MachRoom_Dept='%@',Mgmt_MachRoom_Pos='%@',Mgmt_MachRoom_Tel='%@',Mgmt_MachRoom_Email='%@',Mgmt_MachRoom_Mobile='%@',Decision_Making='%@',Decision_Making_Dept='%@',Decision_Making_Pos='%@',Decision_Making_Tel='%@',Decision_Making_Fax='%@',Decision_Making_Mobile='%@',Decision_Making_Add='%@',Decision_Making_Zip='%@',Decision_Making_Email='%@',IsNameChange='%@' where ID='%@'",tempDepart.PROJ_Name,tempDepart.CustShortName_CN,tempDepart.City_CN,tempDepart.Country_CN,tempDepart.PostalAdd_CN,tempDepart.yhcym,tempDepart.Mgmt_High_Pos,tempDepart.Mgmt_High_Tel,tempDepart.Mgmt_High_Dept,tempDepart.Mgmt_High_EMail,tempDepart.Mgmt_High_Mobile,tempDepart.Mgmt_Midd,tempDepart.DeptMgmt_Midd,tempDepart.DeptMgmt_Midd_Pos,tempDepart.DeptMgmt_Midd_Tel,tempDepart.DeptMgmt_Midd_EMail,tempDepart.DeptMgmt_Midd_Mobile,tempDepart.Mgmt_MachRoom,tempDepart.Mgmt_MachRoom_Dept,tempDepart.Mgmt_MachRoom_Pos,tempDepart.Mgmt_MachRoom_Tel,tempDepart.Mgmt_MachRoom_Email,tempDepart.Mgmt_MachRoom_Mobile,tempDepart.Decision_Making,tempDepart.Decision_Making_Dept,tempDepart.Decision_Making_Pos,tempDepart.Decision_Making_Tel,tempDepart.Decision_Making_Fax,tempDepart.Decision_Making_Mobile,tempDepart.Decision_Making_Add,tempDepart.Decision_Making_Zip,tempDepart.Decision_Making_Email,tempDepart.IsNameChange,self.departDetails.ID];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@DoActionInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestOK:)];
    [request startAsynchronous];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (hud)
    {
        [hud hide:NO];
    }
}

- (void)requestOK:(ASIHTTPRequest *)request
{
    if (hud)
    {
        [hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        [Tool showCustomHUD:@"修改失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        if([string isEqualToString:@"true"])
        {
            [Tool showCustomHUD:@"已修改" andView:self.view andImage:nil andAfterDelay:1.2f];
            tempDepart.ID = self.departDetails.ID;
            self.departDetails = tempDepart;
            //此页面已经存在于self.navigationController.viewControllers中,并且是当前页面的前一页面
            UserInfoView *userinfoView = (UserInfoView *) [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            
            //初始化其属性
            userinfoView.departDetails = nil;
            //传递参数过去
            userinfoView.departDetails = self.departDetails;
            //使用popToViewController返回并传值到上一页面
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        else
        {
            [Tool showCustomHUD:@"修改失败" andView:self.view andImage:nil andAfterDelay:1.2f];
        }
        
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
