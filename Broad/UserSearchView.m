//
//  UserListView.m
//  Broad
//  用户列表页面
//  Created by 赵腾欢 on 15/8/31.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserSearchView.h"
#import "SDRefreshFooterView.h"
#import "Depart.h"
#import "TwoMainView.h"

@interface UserSearchView ()<UITableViewDataSource, UITableViewDelegate>
{
    SDRefreshFooterView *refreshFooter;
    NSString *ser_Dept;
    NSMutableArray *userList;
    NSString *searchKey;
    int allCount;
    BOOL isInit;
    BOOL isOver;
}

@end

@implementation UserSearchView

- (void)viewDidLoad
{
    [super viewDidLoad];
    isInit = true;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"用户搜索";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tableView];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    userList = [[NSMutableArray alloc] init];
    isOver = NO;
//    [self footerRefresh];
}

- (IBAction)searchAction:(id)sender
{
    searchKey = self.searchField.text;
    if(!searchKey || searchKey.length == 0)
    {
        [Tool showCustomHUD:@"请输入需要搜索的用户名" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    [self.view endEditing:YES];
    [self footerRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)footerRefresh
{
    if(isOver)
    {
        [refreshFooter endRefreshing];
        return;
    }
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
        NSDictionary *jsonDic = [jsonArray objectAtIndex:0];
        ser_Dept = jsonDic[@"jc01"];
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
            sqlStr = [NSString stringWithFormat:@"declare @p10 int set @p10=5067 exec SP_GetProjInfoByPage @PageIndex=%i,@UserName='%@',@PageSize=20,@SearchField='CustShortName_CN',@searchString='%@',@OrderBy=N'Send_Date',@Sort='desc',@Ser_Dept='%@',@Engineer='%@',@IsEMC='',@Total=@p10 output select @p10",pageIndex,app.userinfo.UserName,searchKey,ser_Dept,app.userinfo.UserName];
        }
        else if(app.userinfo.xzjb == 1)
        {
            sqlStr = [NSString stringWithFormat:
                      @"declare @p10 int set @p10=5067 exec SP_GetProjInfoByPage @PageIndex=%i,@UserName='%@',@PageSize=20,@SearchField='CustShortName_CN',@searchString='%@',@OrderBy=N'Send_Date',@Sort='desc',@Ser_Dept='%@',@Engineer='全部',@IsEMC='',@Total=@p10 output select @p10",pageIndex,app.userinfo.UserName,searchKey,ser_Dept];
        }
        else
        {
            sqlStr = [NSString stringWithFormat:@"declare @p10 int set @p10=5067 exec SP_GetProjInfoByPage @PageIndex=%i,@UserName='%@',@PageSize=20,@SearchField='CustShortName_CN',@searchString='%@',@OrderBy=N'Send_Date',@Sort='desc',@Ser_Dept='全部',@Engineer='全部',@IsEMC='',@Total=@p10 output select @p10",pageIndex,app.userinfo.UserName,searchKey];
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
        
        NSArray *userNewsList = [Tool readJsonToObjArray:table andObjClass:[Depart class]];
        if (userNewsList.count < 20) {
            isOver = YES;
        }
        [userList addObjectsFromArray:userNewsList];
        allCount = [userList count];
        
        NSDictionary *dic1 = table1[0];
        NSString *counts = dic1[@"Column1"];
        UILabel *tittle = (UILabel *) self.navigationItem.titleView;
        tittle.text = [NSString stringWithFormat:@"用户列表(%@)",counts];
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
    return 59.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([userList count] > 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] init];
        }
        Depart *depart = userList[indexPath.row];
        cell.textLabel.text = depart.CustShortName_CN;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
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
    if (row >= [userList count])
    {
    }
    else
    {
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        app.depart = userList[row];
        TwoMainView *twoMainView = [[TwoMainView alloc] init];
        [self.navigationController pushViewController:twoMainView animated:YES];
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
