//
//  SecurityTableView.m
//  Broad
//
//  Created by Seven on 16/12/19.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import "SecurityTableView.h"
#import "SecurityAddView.h"
#import "SecurityInfo.h"
#import "SecurityDetailView.h"

#import "WeiXiuCell.h"

@interface SecurityTableView ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *securityArray;
}

@end

@implementation SecurityTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"安全管理";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 58, 44);
    [addBtn setTitle:@"新增" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)add
{
    SecurityAddView *addView = [[SecurityAddView alloc] init];
    [self.navigationController pushViewController:addView animated:YES];
}

- (void)getData
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"select * From Tb_CUST_ProjInf_SecurityMgmt Where PROJ_ID='%@' order by UploadTime desc",app.depart.PROJ_ID];
    
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
        
        securityArray = [[NSArray alloc] init];
        
        securityArray = [Tool readJsonToObjArray:table andObjClass:[SecurityInfo class]];
        
        [self.tableView reloadData];
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}

#pragma mark - tableView代理事件
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 112.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return securityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([securityArray count] > 0)
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
        
        SecurityInfo *security = securityArray[indexPath.row];
        
        cell.name_label.text = [NSString stringWithFormat:@"服务项目：%@",security.Project];
        cell.type_label.text = [NSString stringWithFormat:@"服务时间：%@",security.Exec_Date];
        cell.no_label.text = [NSString stringWithFormat:@"上传人：%@",security.Uploader];
        
        if(security.UploadTime.length > 0)
        {
            cell.time_label.text = [NSString stringWithFormat:@"上传时间：%@",security.UploadTime];
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
    if (row >= [securityArray count])
    {
    }
    else
    {
        SecurityInfo *security = securityArray[row];
        SecurityDetailView *detailView = [[SecurityDetailView alloc] init];
        detailView.security = security;
        [self.navigationController pushViewController:detailView animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self getData];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
