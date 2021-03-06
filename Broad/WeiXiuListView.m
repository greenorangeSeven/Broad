//
//  WeiXiuView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "WeiXiuListView.h"
#import "MatnRec.h"
#import "WeiXiuCell.h"
#import "WeiXiuAddView.h"
#import "WeiXiuDetailView.h"
#import "WeiXiuAdd2016View.h"
#import "WeiXiuDetail2016View.h"

#import "WeiXiuAdd2017View.h"
#import "WeiXiuDetail2017View.h"

@interface WeiXiuListView ()
{
    NSArray *weixiuArray;
    NSString *systemTimeStr;
}

@end

@implementation WeiXiuListView

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"保养列表";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    [self getData];
    [self getWeiHuSecurity];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableReload) name:@"Notification_WeiXiuListReLoad" object:nil];
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
                 if ([s.ModuleCode isEqualToString:@"DA0301"] && [s.PermissionName isEqualToString:@"新建"]) {
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
             }
         };
         NSLog(@"%@", operation.responseString);
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
//    WeiXiuAddView *addView = [[WeiXiuAddView alloc] init];
//    WeiXiuAdd2016View *addView = [[WeiXiuAdd2016View alloc] init];
    WeiXiuAdd2017View *addView = [[WeiXiuAdd2017View alloc] init];
    [self.navigationController pushViewController:addView animated:YES];

}

- (void)getData
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
//    NSString *sqlStr = [NSString stringWithFormat:@"select * From TB_CUST_ProjInf_MatnRec Where PROJ_ID='%@' order by UploadTime desc",app.depart.PROJ_ID];
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT a.*,b.MachineOther from TB_CUST_ProjInf_MatnRec as a,[Tb_CUST_ProjInf_AirCondUnit] as b where a.OutFact_Num=b.OutFact_Num and a.PROJ_ID='%@' order by UploadTime desc",app.depart.PROJ_ID];
    
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
        NSError *error;
        NSLog(@"%@",string);
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        
        NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        weixiuArray = [[NSArray alloc] init];
        
        weixiuArray = [Tool readJsonToObjArray:table andObjClass:[MatnRec class]];
        
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
    
//    if(weixiuArray && [weixiuArray count] > 0)
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
    return weixiuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([weixiuArray count] > 0)
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
        
        MatnRec *matnRec = weixiuArray[indexPath.row];
        
        cell.name_label.text = [NSString stringWithFormat:@"服务项目：%@",matnRec.Project];
        cell.type_label.text = [NSString stringWithFormat:@"出厂编号：%@",matnRec.OutFact_Num];
        cell.no_label.text = [NSString stringWithFormat:@"机组型号：%@",matnRec.AirCondUnit_Mode];
        
        if(matnRec.UploadTime.length > 0)
        {
//            NSString *timeStr = [matnRec.UploadTime substringToIndex:[matnRec.UploadTime rangeOfString:@" "].location];
//
//            if(timeStr)
//            {
                cell.time_label.text = [NSString stringWithFormat:@"上传时间：%@",matnRec.UploadTime];
//            }
//            else
//            {
//                cell.time_label.text = @"上传时间:未知";
//            }
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
    //点击“下面20条”
    if (row >= [weixiuArray count])
    {
    }
    else
    {
        MatnRec *matnRec = weixiuArray[row];
        
        NSString *uploadTime =[Tool DateTimeRemoveTime:matnRec.UploadTime andSeparated:@" "];
        uploadTime = [uploadTime stringByReplacingOccurrencesOfString:@"-" withString:@""];
        int uploadInt =[uploadTime intValue];
        if (uploadInt >= 20160125 && uploadInt < 20161226) {
            WeiXiuDetail2016View *detailView = [[WeiXiuDetail2016View alloc] init];
            detailView.matnRec = matnRec;
            [self.navigationController pushViewController:detailView animated:YES];
        }
        else if (uploadInt >= 20161226) {
            WeiXiuDetail2017View *detailView = [[WeiXiuDetail2017View alloc] init];
            detailView.matnRec = matnRec;
            [self.navigationController pushViewController:detailView animated:YES];
        }
        else
        {
            WeiXiuDetailView *detailView = [[WeiXiuDetailView alloc] init];
            detailView.matnRec = matnRec;
            [self.navigationController pushViewController:detailView animated:YES];
        }
    }
}

- (void)getSystemTime
{
    [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@GetNowDateTime",api_base_url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
             [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {

             //             NSString *timeStr = [string substringToIndex:[string rangeOfString:@" "].location];
             systemTimeStr = [Tool transformDateFormat:string andFromFormatterStr:@"yyyy-MM-dd HH:mm" andToFormatterStr:@"yyyyMMdd"];
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {

         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
         
     }];
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
