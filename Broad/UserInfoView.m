//
//  UserInfoView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserInfoView.h"
#import "PrintObject.h"
#import "DepartDetails.h"
#import "UserInfoUpdateView.h"

@interface UserInfoView ()<UIWebViewDelegate>
{
}

@end

@implementation UserInfoView

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"详情";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 58, 44);
    [addBtn setTitle:@"修改" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    self.webView.delegate = self;
    [self getData];
}

- (void)getData
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"select * From TB_CUST_ProjInf Where PROJ_ID='%@'",app.depart.PROJ_ID];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSer:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
}

- (void)requestSer:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSDictionary *jsonDic = [jsonArray objectAtIndex:0];
        self.departDetails = [Tool readJsonDicToObj:jsonDic andObjClass:[DepartDetails class]];
        if(self.departDetails)
        {
            [self initdata];
        }
        else
        {
            [Tool showCustomHUD:@"加载失败" andView:self.view andImage:nil andAfterDelay:1.2f];
        }
        
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}


- (void)initdata
{
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"userdetails" ofType:@"html"];
    NSString *htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    NSURL *url =[NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:htmlStr baseURL:url];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewP
{
    NSString *jsonStr = [[NSString alloc] initWithData:[PrintObject getJSON:self.departDetails options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"bindData(%@);",jsonStr]];
}

- (void)update
{
    UserInfoUpdateView *updateView = [[UserInfoUpdateView alloc] init];
    updateView.departDetails = self.departDetails;
    [self.navigationController pushViewController:updateView animated:YES];
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
    
    if(self.departDetails)
    {
        NSString *jsonStr = [[NSString alloc] initWithData:[PrintObject getJSON:self.departDetails options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"bindData(%@);",jsonStr]];
    }
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
