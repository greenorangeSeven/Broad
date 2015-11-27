//
//  YuKaiAddView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "YuKaiAddView.h"
#import "ProjInf.h"
#import "SGActionView.h"
#import "HSDatePickerViewController.h"

@interface YuKaiAddView ()<UIAlertViewDelegate,UITextFieldDelegate,HSDatePickerViewControllerDelegate>
{
    NSArray *projInfList;
    NSMutableArray *projInfNoList;
    NSMutableArray *projInfAmtList;
    NSMutableDictionary *selectedDicIndexs;
    NSInteger selectProjInfIndex;
    NSInteger selectProj;
    NSInteger selectProt;
    NSInteger selectYi;
    MBProgressHUD *hud;
    NSDate *serviceDate;
    NSInteger rate;
    NSString *invoceId;
}

@end

@implementation YuKaiAddView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectProjInfIndex = -1;
    selectProj = -1;
    selectProt = -1;
    selectYi = -1;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.tv_applicant.frame.origin.y + 250);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"新增";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 78, 44);
    [addBtn setTitle:@"提交" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    
    self.tv_day_time.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd"];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.tv_usercode.text = [NSString stringWithFormat:@"客户代码:%@",app.depart.CUST_Code];
    self.tv_applicant.text = app.userinfo.UserName;
    self.tv_service.text = app.depart.Serv_Dept;
    self.tv_protocol.delegate = self;
    
    self.tv_prepaytime.delegate = self;
    self.tv_prepaytime.tag = 2;
    
    self.tv_invoice_proj.delegate = self;
    self.tv_invoice_proj.tag = 3;
    
    self.tv_invoice_type.delegate = self;
    self.tv_invoice_type.tag = 4;
    
    self.tv_yifang.delegate = self;
    self.tv_yifang.tag = 5;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.tv_applicant.frame.origin.y + 700);
    [self initPro];
}

//生成随机数
-(int)getRandomNumber:(int)start to:(int)end
{
    return (int)(start + (arc4random() % (end - start + 1)));
}

- (void)add
{
    NSString *departname = self.tv_departname.text;
    NSString *protocol = self.tv_protocol.text;
    NSString *prepaytime = self.tv_prepaytime.text;
    NSString *paynum = self.tv_paynum.text;
    NSString *paynump = self.tv_paynum_p.text;
    NSString *cuase = self.et_cuase.text;
    NSString *yifang = self.tv_yifang.text;
    
    if (departname.length == 0)
    {
        [Tool showCustomHUD:@"请填写单位名称" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (protocol.length == 0)
    {
        [Tool showCustomHUD:@"请选择协议编号" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (prepaytime.length == 0)
    {
        [Tool showCustomHUD:@"请选择预付款日期" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (paynum.length > 0)
    {
        if([paynum isEqualToString:@"0"])
        {
            [Tool showCustomHUD:@"付款金额不能为0" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
    }
    if (paynump.length == 0)
    {
        [Tool showCustomHUD:@"请填写申请开票金额" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    if (self.tv_invoice_proj.text.length == 0)
    {
        [Tool showCustomHUD:@"请选择开票项目" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    NSString *invoice_proj = [self.tv_invoice_proj.text substringToIndex:[self.tv_invoice_proj.text rangeOfString:@" "].location];
    
    if (self.tv_invoice_type.text.length == 0)
    {
        [Tool showCustomHUD:@"请选择发票类型" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    NSString *type = self.tv_invoice_type.text;
//    if([type rangeOfString:@"("].length > 0){
//        type = [type substringToIndex:[type rangeOfString:@"("].location];
//    }
    type = [type stringByReplacingOccurrencesOfString:@"(" withString:@""];
    type = [type stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSString *invoice_type = type;
    if (cuase.length == 0)
    {
        [Tool showCustomHUD:@"请填写申请原因" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (yifang.length == 0)
    {
        [Tool showCustomHUD:@"请选择合同乙方" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
//    invoceId = [Tool generateTradeNO];
    
    NSString *random =  [NSString stringWithFormat:@"%d" ,[self getRandomNumber:1000 to:9999]];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate  date] timeIntervalSince1970]];
    invoceId = [NSString stringWithFormat:@"%@%@", timeSp, random];
    
    NSString *sql = [NSString stringWithFormat:@"insert into TB_CUST_ProjInf_Invoice(Invoice_ID,Proj_ID,App_Date,CUST_Name,CONTR_No,BefPay_Date,BefPay_AMT,App_InvoiceAMT,App_reason,Invoice_Item,Invoice_Type,CONTR_SecParty,Serv_Dept,App_Name,Invoice_No,MakeOutInvoice_Sign) values('%@','%@',getdate(),'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','','否')",invoceId,app.depart.PROJ_ID,self.tv_departname.text,protocol,prepaytime,paynum,paynump,cuase,invoice_proj,invoice_type,yifang,app.depart.Serv_Dept,app.userinfo.UserName];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@DoActionInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sql forKey:@"sqlstr"];
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
        if([string isEqualToString:@"true"])
        {
            AppDelegate *app = [[UIApplication sharedApplication] delegate];
            NSString *sql = [NSString stringWithFormat:@"Sp_GetFlowStartInfo '预开发票申请审批','%@'",app.userinfo.UserName];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
            
            NSURL *url = [NSURL URLWithString: urlStr];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setUseCookiePersistence:NO];
            [request setTimeOutSeconds:30];
            [request setPostValue:sql forKey:@"sqlstr"];
            [request setDelegate:self];
            [request setDefaultResponseEncoding:NSUTF8StringEncoding];
            [request setDidFailSelector:@selector(requestFailed:)];
            [request setDidFinishSelector:@selector(requestOK:)];
            [request startAsynchronous];
            request.hud = [[MBProgressHUD alloc] initWithView:self.view];
            [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
        }
        else
        {
            [Tool showCustomHUD:@"新增失败,请重试" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
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
        
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSMutableArray *suItems = [[NSMutableArray alloc] init];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for(NSDictionary *jsonDic in jsonArray)
        {
            [suItems addObject:jsonDic[@"StepName"]];
            [items addObject:jsonDic[@"NextUserName"]];
        }
        
        [SGActionView showSheetWithTitle:@"请选择" itemTitles:suItems itemSubTitles:items selectedIndex:-1 selectedHandle:^(NSInteger index){
            
            NSDictionary *dic = jsonArray[index];
            AppDelegate *app = [[UIApplication sharedApplication] delegate];
            NSString *sql = [NSString stringWithFormat:@"Sp_FlowStart '%@','预开发票申请审批','%@','填写预开发票信息','%@','%@'",app.userinfo.UserName,dic[@"NextUserNameCode"],invoceId,app.depart.PROJ_ID];
            hud.hidden = NO;
            [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
            [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 XMLParserUtils *utils = [[XMLParserUtils alloc] init];
                 utils.parserFail = ^()
                 {
                     hud.hidden = YES;
                     [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                     [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                 };
                 utils.parserOK = ^(NSString *string)
                 {
//                     NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//                     NSError *error;
//                     
//                     NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                     NSDictionary *dic = table[0];
                     
                     AppDelegate *app = [[UIApplication sharedApplication] delegate];
                     NSString *sql = [NSString stringWithFormat:@"Sp_GetFlowStartInfo '预开发票申请审批','%@'",app.userinfo.UserName];
                     hud.hidden = NO;
                     [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
                     [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
                      {
                          NSLog(operation.responseString);
                          XMLParserUtils *utils = [[XMLParserUtils alloc] init];
                          utils.parserFail = ^()
                          {
                              hud.hidden = YES;
                              [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                              [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                          };
                          utils.parserOK = ^(NSString *string)
                          {
//                              NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//                              NSError *error;
//                              
//                              NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                              NSDictionary *dic = table[0];
                              [Tool showCustomHUD:@"新增成功" andView:self.view andImage:nil andAfterDelay:1.2f];
//                              [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_YuKaiListReLoad" object:nil];
                              [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                              
                          };
                          
                          [utils stringFromparserXML:operation.responseString target:@"string"];
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                      {
                          hud.hidden = YES;
                          [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                          [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                      }];
                 };
                 
                 [utils stringFromparserXML:operation.responseString target:@"string"];
             } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 hud.hidden = YES;
                 [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                 [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
             }];
        }];
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)initName
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sql = [NSString stringWithFormat:@"SELECT top 1 CN_Name FROM TB_CUST_ProjInf_ServAgt where Proj_ID='%@' order by Agt_Judm_Date DESC",app.depart.PROJ_ID];
    hud.hidden = NO;
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             hud.hidden = YES;
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
             [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error;
             
             NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             
             NSDictionary *dic = table[0];
             if(dic)
             {
                 self.tv_departname.text = dic[@"CN_Name"];
             }
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         hud.hidden = YES;
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
     }];
}

- (void)initPro
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT MIN(ID) as ID,Agt_Judm_Man,Agt_No,Agt_Type,Proj_GATE,Agt_Judm_Date,Agt_Amt,CN_Name FROM TB_CUST_ProjInf_ServAgt where Proj_ID='%@' group by Agt_Judm_Man,Agt_No,Agt_Type,Proj_GATE,Agt_Judm_Date,Agt_Amt,CN_Name order by Agt_Judm_Date DESC",app.depart.PROJ_ID];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestPro:)];
    
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    static BOOL isOK = NO;
    //协议编号选择
    if(textField.tag == 1)
    {
        
        [SGActionView showSheetMultiWithTitle:@"请选择协议"
                      itemTitles:projInfNoList
                      itemSubTitles:projInfAmtList
                      selectedDicIndex:selectedDicIndexs
                      selectedHandle:^(NSMutableDictionary *selectedDic)
        {
            if(selectedDic)
            {
                selectedDicIndexs = selectedDic;
                
                NSString *projStr = [[NSString alloc] init];
                for(NSString *key in selectedDic)
                {
                    NSNumber *number = selectedDic[key];
                    ProjInf *proj = projInfList[number.intValue];
                    projStr = [NSString stringWithFormat:@"%@%@;",projStr,proj.Agt_No];
                }
                
                self.tv_protocol.text = projStr;
            }
        }];
    }
    else if(textField.tag == 2)
    {
        HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
        hsdpvc.delegate = self;
        if (serviceDate) {
            hsdpvc.date = serviceDate;
        }
        [self presentViewController:hsdpvc animated:YES completion:nil];
    }
    else if(textField.tag == 3)
    {
        NSArray *items = @[@"技术服务费 (6%)",@"中央空调服务费 (6%)",@"中央空调维护费 (6%)",@"中央空调维保费 (6%)",@"全年水质管理 (6%)",@"水质管理服务费 (6%)",@"水系统清洗服务费 (6%)",@"中央空调铜管清洗费 (6%)",@"中央空调清洗费 (6%)",@"冷冻水全年水质管理 (6%)",@"空调备件 (17%)",@"主机及系统节能改造(17%)",@"技术改造 (17%)",@"油改气 (17%)",@"中央空调维修费 (17%)",@"能源服务费 (13%)"];
        [SGActionView showSheetWithTitle:@"请选择开票项目" itemTitles:items selectedIndex:selectProj selectedHandle:^(NSInteger index)
        {
            selectProj = index;
            if(index <= 9)
            {
                rate = 6;
            }
            else if(index > 9 && index <= 14)
            {
                rate = 17;
            }
            else if(index > 14)
            {
                rate = 13;
            }
            
            self.tv_invoice_proj.text = items[index];
            self.tv_invoice_type.text = @"";
        }];
    }
    else if(textField.tag == 4)
    {
        NSArray *items = @[[NSString stringWithFormat:@"增值税普通发票(%li%%)",(long)rate],[NSString stringWithFormat:@"增值税专用发票(%li%%)",(long)rate],@"收据"];
        [SGActionView showSheetWithTitle:@"请选择开票项目" itemTitles:items selectedIndex:selectProt selectedHandle:^(NSInteger index)
         {
             selectProt = index;
             self.tv_invoice_type.text = items[index];
         }];
    }
    else if(textField.tag == 5)
    {
        NSArray *items = @[@"远大空调有限公司", @"其他"];
        [SGActionView showSheetWithTitle:@"请选择开票项目" itemTitles:items selectedIndex:selectProt selectedHandle:^(NSInteger index)
         {
             selectYi = index;
             if(index == 1)
             {
                 isOK = YES;
                 self.tv_yifang.placeholder = @"请输入合同乙方";
                 [self.tv_yifang becomeFirstResponder];
                 return;
             }
             
             self.tv_yifang.text = items[index];
         }];
    }
    if(isOK)
        return YES;
    return NO;
}

#pragma mark - HSDatePickerViewControllerDelegate
- (void)hsDatePickerPickedDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *targetDate = [dateFormatter stringFromDate:date];
    self.tv_prepaytime.text = targetDate;
    serviceDate = date;
}

//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker did dismiss with %lu", (unsigned long)method);
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker will dismiss with %lu", (unsigned long)method);
}

- (void)requestPro:(ASIHTTPRequest *)request
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
        projInfList = [Tool readJsonToObjArray:table andObjClass:[ProjInf class]];
        if(projInfList && projInfList.count > 0)
        {
            AppDelegate *app = [[UIApplication sharedApplication] delegate];
            NSString *sqlStr = [NSString stringWithFormat:@"select a.*  from (SELECT UserName, [ID],Mark,dbo.f_getflowArriveTime(ID) as LastTime FROM [FlowInstance] where  FlowName='预开发票申请审批' and StatusName='流程中' and ApplyStatus like '%%(申请人确认);' and  UserName='%@') as a where DateDiff(day,a.LastTime,GETDATE()) > 15",app.userinfo.UserName];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
            
            NSURL *url = [NSURL URLWithString: urlStr];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setUseCookiePersistence:NO];
            [request setTimeOutSeconds:30];
            [request setPostValue:sqlStr forKey:@"sqlstr"];
            [request setDelegate:self];
            [request setDefaultResponseEncoding:NSUTF8StringEncoding];
            [request setDidFailSelector:@selector(requestFailed:)];
            [request setDidFinishSelector:@selector(requestExsit:)];
            [request startAsynchronous];
            request.hud = [[MBProgressHUD alloc] initWithView:self.view];
            [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"当前协议内容为空,不能申请发票" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)requestExsit:(ASIHTTPRequest *)request
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
        if(table && table.count > 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示:" message:[NSString stringWithFormat:@"您有%li张发票未签收,待全部签收后才能提交预开票申请!",(unsigned long)table.count] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            projInfNoList = [[NSMutableArray alloc] init];
            projInfAmtList = [[NSMutableArray alloc] init];
            
            for(ProjInf *pro in projInfList)
            {
                [projInfNoList addObject:[NSString stringWithFormat:@"协议编号:%@",pro.Agt_No]];
                [projInfAmtList addObject:[NSString stringWithFormat:@"协议金额:%@",pro.Agt_Amt]];
            }
            [self initName];
        }
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self back];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
