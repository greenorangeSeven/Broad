//
//  UserListView.m
//  Broad
//  用户列表页面
//  Created by 赵腾欢 on 15/8/31.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MessageListView.h"
#import "SDRefreshFooterView.h"
#import "Flow.h"
#import "TwoMainView.h"
#import "MsgCell.h"
#import "YuKaiFlowView.h"

@interface MessageListView ()<UITableViewDataSource,UITableViewDelegate>
{
    SDRefreshFooterView *refreshFooter;
    NSString *ser_Dept;
    NSArray *flowList;
    int allCount;
    BOOL isInit;
}

@end

@implementation MessageListView

- (void)viewDidLoad
{
    [super viewDidLoad];
    isInit = true;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"消息列表";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tableView];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    [self footerRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(footerRefresh) name:@"Notification_FlowListReLoad" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)footerRefresh
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"select * From V_GNServerDept Where jc='%@'",app.userinfo.Department];
    
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
    if(isInit)
    {
        request.hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
    }
    
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
        if ([jsonArray count] > 0) {
            NSDictionary *jsonDic = [jsonArray objectAtIndex:0];
            ser_Dept = jsonDic[@"jc01"];
        }
        
        if(!ser_Dept)
        {
            ser_Dept = @"";
        }
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        NSString *sqlStr = nil;
        
        //计算出页码
        int pageIndex = allCount / 20 + 1;
        
        if(app.userinfo.xzjb == 0)
        {
            sqlStr = [NSString stringWithFormat:@"declare @p11 int exec SP_GetMoreDaiBanFlowInfoInQueryByPage @OrderBy=N'ArriveTime',@Sort='desc', @PageIndex=%i,@PageSize=20,@UserName='%@',@Type='全部',@searchField='全部',@searchString='',@SerDept='%@',@Engineer='%@',@Total=@p11 output select @p11",pageIndex,app.userinfo.UserName,ser_Dept,app.userinfo.UserName];
        }
        else if(app.userinfo.xzjb == 1)
        {
            sqlStr = [NSString stringWithFormat:
                      @"declare @p11 int exec SP_GetMoreDaiBanFlowInfoInQueryByPage @OrderBy=N'ArriveTime',@Sort='desc', @PageIndex=%i,@PageSize=20,@UserName='%@',@Type='全部',@searchField='全部',@searchString='',@SerDept='%@',@Engineer='全部',@Total=@p11 output select @p11",pageIndex,app.userinfo.UserName,ser_Dept];
        }
        else
        {
            sqlStr = [NSString stringWithFormat:@"declare @p11 int exec SP_GetMoreDaiBanFlowInfoInQueryByPage @OrderBy=N'ArriveTime',@Sort='desc', @PageIndex=%i,@PageSize=20,@UserName='%@',@Type='全部',@searchField='全部',@searchString='',@SerDept='全部',@Engineer='全部',@Total=@p11 output select @p11",pageIndex,app.userinfo.UserName];
        }
        NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInUserInfo", api_base_url];
        
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
        if(isInit)
        {
            request.hud = [[MBProgressHUD alloc] initWithView:self.view];
            [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
        }
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)requestOK:(ASIHTTPRequest *)request
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
        
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray *table = [jsonDic objectForKey:@"Table"];
        NSArray *table1 = [jsonDic objectForKey:@"Table1"];
        
        flowList = [Tool readJsonToObjArray:table andObjClass:[Flow class]];
        
        NSDictionary *dic1 = table1[0];
        NSString *counts = dic1[@"Column1"];
        UILabel *tittle = (UILabel *) self.navigationItem.titleView;
        tittle.text = [NSString stringWithFormat:@"消息列表(%@)",counts];
        [self.tableView reloadData];
        [refreshFooter endRefreshing];
        if(isInit)
            isInit = NO;
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}

#pragma mark - tableView代理事件
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return flowList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([flowList count] > 0)
    {
        MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgCell"];
        if (!cell)
        {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MsgCell" owner:self options:nil];
            for (NSObject *o in objects)
            {
                if ([o isKindOfClass:[MsgCell class]])
                {
                    cell = (MsgCell *)o;
                    break;
                }
            }
        }
        Flow *flow = flowList[indexPath.row];
        cell.name_label.text = [NSString stringWithFormat:@"类型:%@",flow.FlowName];
        cell.type_label.text = [NSString stringWithFormat:@"用户名:%@",flow.PROJ_Name];
        
        if(flow.ApplyDateTime.length > 0)
        {
            NSString *timeStr = [flow.ApplyDateTime substringToIndex:[flow.ApplyDateTime rangeOfString:@" "].location];
            
            if(timeStr)
            {
                cell.no_label.text = [NSString stringWithFormat:@"上传时间:%@",timeStr];
            }
            else
            {
                cell.no_label.text = @"上传时间:未知";
            }
        }
        else
        {
            cell.no_label.text = @"上传时间:未知";
        }
        if (![flow.FlowName isEqualToString:@"预开发票申请审批"])
        {
            cell.tag_img.hidden = YES;
            cell.tag_label.hidden = YES;
        }
        else
        {
            cell.tag_img.hidden = NO;
            cell.tag_label.hidden = NO;
        }
        return cell;
    }
    else
    {
        return [[EndCellUtils Instance] getLoadEndCell:tableView andLoadOverString:@"暂无数据"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    //点击“下面20条”
    if (row >= [flowList count])
    {
    }
    else
    {
        Flow *flow = flowList[indexPath.row];
        if ([flow.FlowName isEqualToString:@"预开发票申请审批"])
        {
            YuKaiFlowView *flowView = [[YuKaiFlowView alloc] init];
            flowView.Mark = flow.Mark;
            [self.navigationController pushViewController:flowView animated:YES];
        }
    }
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
