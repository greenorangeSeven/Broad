//
//  WeiXiuView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "RongYeListView.h"
#import "Solution.h"
#import "WeiXiuCell.h"
#import "RongYeAdd2017View.h"
#import "RongYeHandleDetailView.h"
#import "RongYeDetailView.h"
#import "SolutionMgmt.h"

@interface RongYeListView ()
{
    NSArray *solutionArray;
}

@end

@implementation RongYeListView

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"溶液管理列表";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
        
//    [self getData];
    [self getRongYeSecurity];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableReload) name:@"Notification_RongYeListReLoad" object:nil];
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
                 if ([s.ModuleCode isEqualToString:@"DA0302"] && [s.PermissionName isEqualToString:@"新建"]) {
                     haveQueryRecord = YES;
                     break;
                 }
             }
             if(haveQueryRecord)
             {
                 UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                 addBtn.frame = CGRectMake(0, 0, 58, 44);
                 [addBtn setTitle:@"新增" forState:UIControlStateNormal];
                 [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
                 UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
                 self.navigationItem.rightBarButtonItem = addItem;
                 [self getSystemTime];
             }
         };
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)getSystemTime
{
    [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@GetNowDateTime",api_base_url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             long systemTimeLong = [[Tool transformDateFormat:string andFromFormatterStr:@"yyyy-MM-dd HH:mm" andToFormatterStr:@"MMdd"] longLongValue];
             //取样年份
             if (systemTimeLong > 630) {
//                 UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//                 addBtn.frame = CGRectMake(0, 0, 58, 44);
//                 [addBtn setTitle:@"新增" forState:UIControlStateNormal];
//                 [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
//                 UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
                 self.navigationItem.rightBarButtonItem = nil;
             }
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)tableReload
{
//    [self getData];
}

- (void)add
{
    RongYeAdd2017View *addView = [[RongYeAdd2017View alloc] init];
    [self.navigationController pushViewController:addView animated:YES];
}

- (void)getData
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"select * From SolutionSample Where ProjID='%@' order by UploadTime desc",app.depart.PROJ_ID];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
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
        
        NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        solutionArray = [Tool readJsonToObjArray:table andObjClass:[Solution class]];
        
        [self.tableView reloadData];
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
//    if(solutionArray && [solutionArray count] > 0)
//    {
//        [self tableReload];
//    }
    [self getData];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

#pragma mark - tableView代理事件
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 112.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return solutionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([solutionArray count] > 0)
    {
        WeiXiuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiXiuCell"];
        if (!cell)
        {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WeiXiuCell" owner:self options:nil];
            for (NSObject *o in objects)
            {
                if ([o isKindOfClass:[WeiXiuCell class]])
                {
                    cell = (WeiXiuCell *)o;
                    break;
                }
            }
        }
        
        Solution *solution = solutionArray[indexPath.row];
        
        cell.name_label.text = [NSString stringWithFormat:@"上传人：%@",solution.Uploader];
        cell.type_label.text = [NSString stringWithFormat:@"出厂编号：%@",solution.OutFactNum];
        if(solution.ExecDate.length > 0)
        {
            NSString *timeStr = [solution.ExecDate substringToIndex:[solution.ExecDate rangeOfString:@" "].location];
            
            if(timeStr)
            {
                cell.no_label.text = [NSString stringWithFormat:@"取样时间：%@",timeStr];
            }
            else
            {
                cell.no_label.text = @"取样时间：未知";
            }
        }
        else
        {
            cell.no_label.text = @"取样时间：未知";
        }
        if(solution.UploadTime.length > 0)
        {
            NSString *timeStr = [solution.UploadTime substringToIndex:[solution.UploadTime rangeOfString:@" "].location];
            
            if(timeStr)
            {
                cell.time_label.text = [NSString stringWithFormat:@"上传时间：%@",timeStr];
            }
            else
            {
                cell.time_label.text = @"上传时间：未知";
            }
        }
        else
        {
            cell.time_label.text = @"上传时间：未知";
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
    Solution *solution = solutionArray[indexPath.row];
    //点击“下面20条”
    if (row >= [solutionArray count])
    {
    }
    else
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT a.*,b.* from [TB_CUST_ProjInf_SolutionMgmt] as a LEFT OUTER JOIN SolutionSample as b ON a.OutFact_Num=b.OutFactNum and a.Exec_Date=b.ExecDate where OutFactNum='%@' and Exec_Date='%@'",solution.OutFactNum, solution.ExecDate];
        
        [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
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
                 if([jsonArray count] > 0)
                 {
                     NSDictionary *jsonDic = [jsonArray objectAtIndex:0];
                     SolutionMgmt *solutionMgmt = [Tool readJsonDicToObj:jsonDic andObjClass:[SolutionMgmt class]];
                     RongYeHandleDetailView *detailView = [[RongYeHandleDetailView alloc] init];
                     detailView.solutionMgmt = solutionMgmt;
                     [self.navigationController pushViewController:detailView animated:YES];
                 }
                 else
                 {
                     RongYeDetailView *detailView = [[RongYeDetailView alloc] init];
                     detailView.solution = solution;
                     [self.navigationController pushViewController:detailView animated:YES];
                 }
             };
             
             [utils stringFromparserXML:operation.responseString target:@"string"];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             self.navigationItem.rightBarButtonItem.enabled = YES;
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         }];
        
        
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
