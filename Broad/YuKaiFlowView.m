//
//  YuKaiFlowView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/19.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "YuKaiFlowView.h"
#import "Invoice.h"
#import "ProjInf.h"
#import "SGActionView.h"
#import "HSDatePickerViewController.h"

@interface YuKaiFlowView ()<UIAlertViewDelegate,UITextFieldDelegate,HSDatePickerViewControllerDelegate>
{
    Invoice *invoice;
    NSArray *seArray;
    NSArray *se2Array;
    
    NSArray *projInfList;
    NSMutableArray *projInfNoList;
    NSMutableArray *projInfAmtList;
    NSMutableDictionary *selectedDicIndexs;
    NSInteger selectProjInfIndex;
    NSInteger selectProj;
    NSInteger selectProt;
    NSInteger selectYi;
    NSInteger selectTime;
    MBProgressHUD *hud;
    NSDate *serviceDate;
    NSInteger rate;
    NSString *invoceId;
}
@end

@implementation YuKaiFlowView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hiddenReceiptInfoView];
    
    selectProjInfIndex = -1;
    selectProj = -1;
    selectProt = -1;
    selectYi = -1;
    selectTime = -1;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"预开发票";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.kaipiao_time_Field.frame.origin.y + 1250);
    
    AppDelegate *app =[[UIApplication sharedApplication] delegate];
    self.fapiaono_Field.enabled = NO;
    self.kaipiao_time_Field.enabled = NO;
    self.kaipiaoBtn.hidden = YES;
    
    //财务
    if ([app.userinfo.JiaoSe isEqualToString:@"UF"])
    {
        self.backFlowBtn.hidden = YES;
        self.kaipiaoBtn.hidden = NO;
        self.kaipiao_label.text = @"";
//        ll_kaipiao.setVisibility(View.VISIBLE);
//        bt_back.setVisibility(View.GONE);
//        tv_kaipiao.setText("否");
    }
    //用户中心总经理
    if ([app.userinfo.JiaoSe isEqualToString:@"UM"])
    {
        [self.comitBtn setTitle:@"通过" forState:UIControlStateNormal];
    }
    
    self.tv_protocol.delegate = self;
    
    self.tv_prepaytime.delegate = self;
    self.tv_prepaytime.tag = 2;
    
    self.kaipiao_time_Field.delegate = self;
    self.kaipiao_time_Field.tag = 6;
    
    self.tv_invoice_proj.delegate = self;
    self.tv_invoice_proj.tag = 3;
    
    self.tv_invoice_type.delegate = self;
    self.tv_invoice_type.tag = 4;
    
    self.tv_yifang.delegate = self;
    self.tv_yifang.tag = 5;
    
    [self initData];
}

- (void)initData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select * From TB_CUST_ProjInf_Invoice Where Invoice_ID='%@'",self.Mark];
    
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
        
        invoice = [Tool readJsonDicToObj:jsonDic andObjClass:[Invoice class]];
        if(invoice)
        {
           
            NSString *sqlStr = nil;
            sqlStr = [NSString stringWithFormat:@"Sp_GetFlowNextInfo '%@'",self.Mark];
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
            
            self.tv_applicant.text = invoice.App_Name;
            self.tv_service.text = invoice.Serv_Dept;
            self.tv_yifang.text = invoice.CONTR_SecParty;
            self.et_cuase.text = invoice.App_reason;
            self.tv_invoice_type.text = invoice.Invoice_Type;
            self.tv_invoice_proj.text = invoice.Invoice_Item;
            self.tv_paynum_p.text = [NSString stringWithFormat:@"%.6f",invoice.App_InvoiceAMT];
//            self.tv_paynum.text = [NSString stringWithFormat:@"%.6f",invoice.BefPay_AMT];
            self.tv_prepaytime.text = invoice.BefPay_Date;
            self.tv_protocol.text = invoice.CONTR_No;
            self.tv_departname.text = invoice.CUST_Name;
            self.zhuguan_label.text = [NSString stringWithFormat:@"%@  %@-%@",invoice.Leader_Opinion,invoice.Leader_Sign,invoice.Leader_SignDate];
            self.zongjingli_label.text = [NSString stringWithFormat:@"%@  %@-%@",invoice.UserGenManager_Opinion,invoice.UserGenManager_Sign,invoice.UserGenManager_SignDate];
            self.kaipiao_label.text = invoice.MakeOutInvoice_Sign;
            self.fapiaono_Field.text = invoice.Invoice_No;
            
            NSRange range = [invoice.Invoice_Type rangeOfString:@"专用"];
            if (range.length >0)
            {
                [self showReceiptInfoView];
                self.tf_TaxNumber.text = invoice.TaxNumber;
                self.tf_TompanyAdd.text = invoice.TompanyAdd;
                self.tf_Bank.text = invoice.Bank;
            }
            else
            {
                [self hiddenReceiptInfoView];
            }
            
            if (invoice.MakeOutInvoice_Date.length > 0)
            {
                NSString *timeStr = [invoice.App_Date substringToIndex:[invoice.App_Date rangeOfString:@" "].location];
                
                if(timeStr)
                {
                    self.kaipiao_time_Field.text = timeStr;
                }
                else
                {
                    self.kaipiao_time_Field.text = @"申请日期:未知";
                }
            }
            
            self.caiwu_label.text = [NSString stringWithFormat:@"%@  %@-%@",invoice.Fin_Opinion,invoice.Fin_Sign,invoice.Fin_SignDate];
            
            self.qianshou_label.text = [NSString stringWithFormat:@"%@  %@",invoice.SignFor_INF,invoice.SignFor_Date];
        }
        else
        {
            [Tool showCustomHUD:@"获取发票信息失败..." andView:self.view andImage:nil andAfterDelay:1.2f];
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
        
        seArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSDictionary *jsonDic = [seArray objectAtIndex:0];
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        if ([app.userinfo.JiaoSe isEqualToString:@"SE"] || [app.userinfo.JiaoSe isEqualToString:@"FJ"])
        {
            
                int stepid = [jsonDic[@"StepID"] intValue];
                if (stepid == 2)
                {
                    self.backFlowBtn.hidden = YES;
                    [self.comitBtn setTitle:@"重新提交" forState:UIControlStateNormal];
                }
                else
                {
                    [self.comitBtn setTitle:@"签收" forState:UIControlStateNormal];
                    self.backFlowBtn.hidden = YES;
                    
                    self.tv_departname.enabled = NO;
                    self.tv_protocol.enabled = NO;
                    self.tv_prepaytime.enabled = NO;
//                    self.tv_paynum.enabled = NO;
                    self.tv_paynum_p.enabled = NO;
                    self.tv_invoice_proj.enabled = NO;
                    self.tv_invoice_type.enabled = NO;
                    self.et_cuase.enabled = NO;
                    self.tv_yifang.enabled = NO;
                    self.tv_service.enabled = NO;
                    self.tv_applicant.enabled = NO;
                    self.zhuguan_label.enabled = NO;
                    self.zongjingli_label.enabled = NO;
                    self.caiwu_label.enabled = NO;
                    self.qianshou_label.enabled = NO;
                    self.kaipiao_label.enabled = NO;
                    self.fapiaono_Field.enabled = NO;
                    self.kaipiao_time_Field.enabled = NO;
                }
        }
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
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

- (IBAction)comitAction:(id)sender
{
    NSString *departname = self.tv_departname.text;
    NSString *protocol = self.tv_protocol.text;
    NSString *prepaytime = self.tv_prepaytime.text;
//    NSString *paynum = self.tv_paynum.text;
    NSString *paynump = self.tv_paynum_p.text;
    
    NSString *invoice_proj = self.tv_invoice_proj.text;
    NSRange iStart = [invoice_proj rangeOfString:@" "];
    
    NSString *invoicetypeStr = self.tv_invoice_type.text;
    NSRange range = [invoicetypeStr rangeOfString:@"专用"];
    if (range.length <= 0)
    {
        for (UIView *subView in [self.receiptInfoView subviews])
        {
            if ([subView isKindOfClass:[UITextField class]])
            {
                ((UITextField *)subView).text = @"";
            }
        }
    }
    NSString *TaxNumber = self.tf_TaxNumber.text;
    NSString *TompanyAdd = self.tf_TompanyAdd.text;
    NSString *Bank = self.tf_Bank.text;
    
    if(iStart.length > 0)
    {
//        invoice_proj = [self.tv_invoice_proj.text substringToIndex:[self.tv_invoice_proj.text rangeOfString:@" "].location];
        invoice_proj = [self.tv_invoice_proj.text substringToIndex:iStart.location];
    }
    else
    {
        invoice_proj = self.tv_invoice_proj.text;
    }
    
    NSString *type = self.tv_invoice_type.text;
//    if([type rangeOfString:@"("].length > 0)
//    {
//        type = [type substringToIndex:[type rangeOfString:@"("].location];
//    }
    type = [type stringByReplacingOccurrencesOfString:@"(" withString:@""];
    type = [type stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSString *invoice_type = type;
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
//    if (paynum.length > 0)
//    {
//        if([paynum isEqualToString:@"0"])
//        {
//            [Tool showCustomHUD:@"付款金额不能为0" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//    }
    if (paynump.length == 0)
    {
        [Tool showCustomHUD:@"请填写申请开票金额" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (invoice_proj.length == 0)
    {
        [Tool showCustomHUD:@"请选择开票项目" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (invoice_type.length == 0)
    {
        [Tool showCustomHUD:@"请选择发票类型" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
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
    //财务
    if ([app.userinfo.JiaoSe isEqualToString:@"UF"])
    {
        NSString *isKaipiao = self.kaipiao_label.text;
        if (isKaipiao.length == 0)
        {
            [Tool showCustomHUD:@"请选择是否已开票" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        else
        {
            if ([isKaipiao isEqualToString:@"是"])
            {
                NSString *fapiaono = self.fapiaono_Field.text;
                if (fapiaono.length == 0)
                {
                    [Tool showCustomHUD:@"请填写发票号" andView:self.view andImage:nil andAfterDelay:1.2f];
                    return;
                }
                NSString *fapiaotime = self.kaipiao_time_Field.text;
                if (fapiaotime.length == 0)
                {
                    [Tool showCustomHUD:@"请选择开票日期" andView:self.view andImage:nil andAfterDelay:1.2f];
                    return;
                }
            }
        }
    }
    
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    NSMutableArray *stitles = [[NSMutableArray alloc] init];
    for(int i = 0; i < seArray.count; ++i)
    {
        NSDictionary *dic = seArray[i];
        [titles addObject:[dic objectForKey:@"StepName"]];
        [stitles addObject:[dic objectForKey:@"NextUserName"]];
    }
    
    self.comitBtn.enabled = NO;
    
    [SGActionView showSheetWithTitle:@"请选择:"
                          itemTitles:titles
                       itemSubTitles:stitles
                       selectedIndex:-1
                      selectedHandle:^(NSInteger index){
                          
                          NSDictionary *dic = seArray[index];
                          
                          AppDelegate *app = [[UIApplication sharedApplication] delegate];
                          
                          NSString *RoleName = app.userinfo.JiaoSe;
                          
                          //主管
                          NSString *Leader_Opinion = nil;
                          NSString *Leader_Sign = nil;
                          NSString *Leader_SignDate = nil;
                          
                          //总经理
                          NSString * UserGenManager_Opinion = nil;
                          NSString * UserGenManager_Sign = nil;
                          NSString * UserGenManager_SignDate = nil;
                          
                          NSString * Fin_Opinion = nil;
                          NSString * Fin_SignDate = nil;
                          NSString * Fin_Sign = nil;
                          NSString * MakeOutInvoice_Sign = nil;
                          NSString * MakeOutInvoice_Date = nil;
                          NSString * Invoice_No = nil;
                          
                          NSString * SignFor_Date = nil;
                          NSString * SignFor_INF = nil;
                          
                          if ([RoleName isEqualToString:@"SI"])
                          {//售后信息
                          }
                          if ([RoleName isEqualToString:@"SH"])
                          {
                              Leader_Opinion = @"同意";
                              Leader_Sign = app.userinfo.UserName;
                              Leader_SignDate = @"getdate()";
                          }
                          else
                          {
                              Leader_Opinion = invoice.Leader_Opinion;
                              Leader_Sign = invoice.Leader_Sign;
                              Leader_SignDate = invoice.Leader_SignDate.length == 0
                              ? @"null"
                              : [NSString stringWithFormat:@"'%@'",invoice.Leader_SignDate];
                          }
                          //用户中心总经理
                          if ([RoleName isEqualToString:@"UM"])
                          {
                              UserGenManager_Opinion = @"同意";
                              UserGenManager_Sign = app.userinfo.UserName;
                              UserGenManager_SignDate = @"getdate()";
                          }
                          else
                          {
                              UserGenManager_Opinion = invoice.UserGenManager_Opinion;
                              UserGenManager_Sign = invoice.UserGenManager_Sign;
                              UserGenManager_SignDate = invoice.UserGenManager_SignDate.length == 0
                              ? @"null"
                              : [NSString stringWithFormat:@"'%@'",invoice.UserGenManager_SignDate];
                          }
                          //财务
                          if ([RoleName isEqualToString:@"UF"])
                          {
                              Fin_Opinion = @"同意";
                              Fin_SignDate = @"getdate()";
                              Fin_Sign = app.userinfo.UserName;
                              MakeOutInvoice_Date = self.kaipiao_time_Field.text.length == 0
                              ? @"null"
                              : [NSString stringWithFormat:@"'%@'",self.kaipiao_time_Field.text];
                              
                              MakeOutInvoice_Sign = self.kaipiao_label.text;
                              
                              Invoice_No = self.fapiaono_Field.text.length == 0
                              ? @"null"
                              : [NSString stringWithFormat:@"'%@'",self.fapiaono_Field.text];
                          }
                          else
                          {
                              Fin_Opinion = invoice.Fin_Opinion;
                              Fin_SignDate = invoice.Fin_SignDate.length == 0
                              ? @"null"
                              : [NSString stringWithFormat:@"'%@'",invoice.Fin_SignDate];
                              
                              Fin_Sign = invoice.Fin_Sign;
                              
                              //修改
                              MakeOutInvoice_Date = invoice.MakeOutInvoice_Date.length == 0
                              ? @"null"
                              : [NSString stringWithFormat:@"'%@'",invoice.MakeOutInvoice_Date ];
                              MakeOutInvoice_Sign = invoice.MakeOutInvoice_Sign;
                              Invoice_No = invoice.Invoice_No.length == 0
                              ? @"null"
                              : [NSString stringWithFormat:@"'%@'",invoice.Invoice_No];
                          }
                          //服务工程师或者服务技师
                          if ([RoleName isEqualToString:@"SE"] || [RoleName isEqualToString:@"FJ"])
                          {
                              NSDictionary *jsonDic = seArray[index];
                              long int stepid = (long int) jsonDic[@"StepID"];
                              if (stepid == 2)
                              {
                                  SignFor_Date = @"getdate()";
                                  SignFor_INF = app.userinfo.UserName;
                              }
                          }
     
     
//                        NSString *sqlStr = [NSString stringWithFormat:@"update TB_CUST_ProjInf_Invoice set Invoice_ID='%@',Proj_ID='%@',App_Date='%@',CUST_Name='%@',CONTR_No='%@',BefPay_Date='%@',BefPay_AMT='%@',App_InvoiceAMT='%@',App_reason='%@',Invoice_Item='%@',Invoice_Type='%@', CONTR_SecParty='%@',Serv_Dept='%@',App_Name='%@',Leader_Opinion=%@,Leader_Sign=%@,Leader_SignDate=%@,UserGenManager_Opinion=%@,UserGenManager_Sign=%@,UserGenManager_SignDate=%@,Fin_Opinion=%@,Fin_SignDate=%@,Fin_Sign=%@,MakeOutInvoice_Sign=%@,MakeOutInvoice_Date=%@,Invoice_No=%@,SignFor_INF=%@,SignFor_Date=%@, TaxNumber='%@', TompanyAdd='%@', Bank='%@' where ID='%@'",invoice.Invoice_ID,invoice.Proj_ID,invoice.App_Date,self.tv_departname.text,self.tv_protocol.text,self.tv_prepaytime.text,self.tv_paynum.text,self.tv_paynum_p.text,self.et_cuase.text,self.tv_invoice_proj.text,invoice_type,self.tv_yifang.text,invoice.Serv_Dept,invoice.App_Name,Leader_Opinion.length == 0?@"null":[NSString stringWithFormat:@"'%@'",Leader_Opinion],Leader_Sign.length == 0?@"null":[NSString stringWithFormat:@"'%@'",Leader_Sign],Leader_SignDate,UserGenManager_Opinion.length == 0?@"null":[NSString stringWithFormat:@"'%@'",UserGenManager_Opinion],UserGenManager_Sign.length == 0?@"null":[NSString stringWithFormat:@"'%@'",UserGenManager_Sign],UserGenManager_SignDate,Fin_Opinion.length == 0?@"null":[NSString stringWithFormat:@"'%@'",Fin_Opinion],Fin_SignDate,Fin_Sign.length == 0?@"null":[NSString stringWithFormat:@"'%@'",Fin_Sign],MakeOutInvoice_Sign.length == 0?@"null":[NSString stringWithFormat:@"'%@'",MakeOutInvoice_Sign],MakeOutInvoice_Date,Invoice_No,SignFor_INF.length == 0?@"null":[NSString stringWithFormat:@"'%@'",SignFor_INF],SignFor_Date,TaxNumber,TompanyAdd,Bank,invoice.ID];
                          NSString *sqlStr = [NSString stringWithFormat:@"update TB_CUST_ProjInf_Invoice set Invoice_ID='%@',Proj_ID='%@',App_Date='%@',CUST_Name='%@',CONTR_No='%@',BefPay_Date='%@',App_InvoiceAMT='%@',App_reason='%@',Invoice_Item='%@',Invoice_Type='%@', CONTR_SecParty='%@',Serv_Dept='%@',App_Name='%@',Leader_Opinion=%@,Leader_Sign=%@,Leader_SignDate=%@,UserGenManager_Opinion=%@,UserGenManager_Sign=%@,UserGenManager_SignDate=%@,Fin_Opinion=%@,Fin_SignDate=%@,Fin_Sign=%@,MakeOutInvoice_Sign=%@,MakeOutInvoice_Date=%@,Invoice_No=%@,SignFor_INF=%@,SignFor_Date=%@, TaxNumber='%@', TompanyAdd='%@', Bank='%@' where ID='%@'",invoice.Invoice_ID,invoice.Proj_ID,invoice.App_Date,self.tv_departname.text,self.tv_protocol.text,self.tv_prepaytime.text,self.tv_paynum_p.text,self.et_cuase.text,self.tv_invoice_proj.text,invoice_type,self.tv_yifang.text,invoice.Serv_Dept,invoice.App_Name,Leader_Opinion.length == 0?@"null":[NSString stringWithFormat:@"'%@'",Leader_Opinion],Leader_Sign.length == 0?@"null":[NSString stringWithFormat:@"'%@'",Leader_Sign],Leader_SignDate,UserGenManager_Opinion.length == 0?@"null":[NSString stringWithFormat:@"'%@'",UserGenManager_Opinion],UserGenManager_Sign.length == 0?@"null":[NSString stringWithFormat:@"'%@'",UserGenManager_Sign],UserGenManager_SignDate,Fin_Opinion.length == 0?@"null":[NSString stringWithFormat:@"'%@'",Fin_Opinion],Fin_SignDate,Fin_Sign.length == 0?@"null":[NSString stringWithFormat:@"'%@'",Fin_Sign],MakeOutInvoice_Sign.length == 0?@"null":[NSString stringWithFormat:@"'%@'",MakeOutInvoice_Sign],MakeOutInvoice_Date,Invoice_No,SignFor_INF.length == 0?@"null":[NSString stringWithFormat:@"'%@'",SignFor_INF],SignFor_Date,TaxNumber,TompanyAdd,Bank,invoice.ID];
                          
                          [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sqlStr,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
                           {
                               NSLog(operation.responseString);
                               XMLParserUtils *utils = [[XMLParserUtils alloc] init];
                               utils.parserFail = ^()
                               {
                                   hud.hidden = YES;
                                   [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                               };
                               utils.parserOK = ^(NSString *string)
                               {
                                   if([string isEqualToString:@"true"])
                                   {
                                    
                                       
                                       
                                       
                                       AppDelegate *app = [[UIApplication sharedApplication] delegate];
                                       NSString *sql = [NSString stringWithFormat:@"SP_FlowSubmit '%@',1,'%@/%@','%@','预开发票申请审批','同意'",app.userinfo.UserName,dic[@"StepID"],dic[@"NextUserNameCode"],self.Mark];
                                       hud.hidden = NO;
                                       [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
                                       [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
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
                                                if([string isEqualToString:@"true"])
                                                {
//                                                    NSString *stepID = dic[@"StepID"];
                                                    int stepid = [dic[@"StepID"] intValue];
                                                    if ([app.userinfo.JiaoSe isEqualToString:@"SE"] || [app.userinfo.JiaoSe isEqualToString:@"FJ"])
                                                    {
                                                        if (stepid == 2)
                                                        {
                                                            [Tool showCustomHUD:@"重新提交成功" andView:self.view andImage:nil andAfterDelay:1.2f];
                                                        }
                                                        else if (!(stepid == 2))
                                                        {
                                                            [Tool showCustomHUD:@"办结成功" andView:self.view andImage:nil andAfterDelay:1.2f];
                                                        }
                                                        //
                                                    }
                                                    else
                                                    {
                                                        [Tool showCustomHUD:@"办理成功" andView:self.view andImage:nil andAfterDelay:1.2f];
                                                    }
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_FlowListReLoad" object:nil];
                                                    [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                                                }
                                                else
                                                {
                                                    [Tool showCustomHUD:@"办理失败" andView:self.view andImage:nil andAfterDelay:1.2f];
                                                    self.comitBtn.enabled = YES;
                                                }
                                            };
                                            
                                            [utils stringFromparserXML:operation.responseString target:@"string"];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                        {
                                            hud.hidden = YES;
                                            self.comitBtn.enabled = YES;
                                            [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                                            [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                                        }];

                                       
                                   }
                                   
                                };
                               
                               [utils stringFromparserXML:operation.responseString target:@"string"];
                           } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                           {
                               hud.hidden = YES;
                               [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                               [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                           }];

                      }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backFlowAction:(id)sender
{
    self.backFlowBtn.enabled = NO;
    NSString *sqlStr = nil;
    sqlStr = [NSString stringWithFormat:@"Sp_GetApplyInfo '%@'",self.Mark];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestBFOK:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
    
}

- (void)requestBFOK:(ASIHTTPRequest *)request
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
        
        se2Array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSDictionary *jsonDic = [seArray objectAtIndex:0];
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        NSMutableArray *stitles = [[NSMutableArray alloc] init];
        for(int i = 0; i < se2Array.count; ++i)
        {
            NSDictionary *dic = se2Array[i];
            [titles addObject:[dic objectForKey:@"StepName"]];
            [stitles addObject:[dic objectForKey:@"NextUserName"]];
        }
        
        [SGActionView showSheetWithTitle:@"请选择:"
                              itemTitles:titles
                           itemSubTitles:stitles
                           selectedIndex:-1
                          selectedHandle:^(NSInteger index){
                              NSDictionary *dic = se2Array[index];
                              AppDelegate *app = [[UIApplication sharedApplication] delegate];
                              NSString *sql = [NSString stringWithFormat:@"SP_FlowSubmit '%@',-1,'%@/%@','%@','预开发票申请审批','驳回'",app.userinfo.UserName,dic[@"StepID"],dic[@"NextUserNameCode"],self.Mark];
                              hud.hidden = NO;
                              [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
                              [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
                               {
                                   NSLog(operation.responseString);
                                   XMLParserUtils *utils = [[XMLParserUtils alloc] init];
                                   utils.parserFail = ^()
                                   {
                                       hud.hidden = YES;
                                       [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                                       [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                                       self.backFlowBtn.enabled = YES;
                                   };
                                   utils.parserOK = ^(NSString *string)
                                   {
                                       if([string isEqualToString:@"true"])
                                       {
                                           [Tool showCustomHUD:@"驳回成功" andView:self.view andImage:nil andAfterDelay:1.2f];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_FlowListReLoad" object:nil];
                                           [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                                       }
                                       else
                                       {
                                           [Tool showCustomHUD:@"驳回失败" andView:self.view andImage:nil andAfterDelay:1.2f];
                                           self.backFlowBtn.enabled = YES;
                                       }
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
    else if(textField.tag == 2 || textField.tag == 6)
    {
        HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
        selectTime = textField.tag;
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
             if([self.receiptInfoView isHidden] == NO)
             {
                 [self hiddenReceiptInfoView];
             }
         }];
    }
    else if(textField.tag == 4)
    {
        NSArray *items = @[[NSString stringWithFormat:@"增值税普通发票(%li%%)",rate],[NSString stringWithFormat:@"增值税专用发票(%li%%)",rate],@"收据"];
        [SGActionView showSheetWithTitle:@"请选择开票项目" itemTitles:items selectedIndex:selectProt selectedHandle:^(NSInteger index)
         {
             selectProt = index;
             NSString *invoicetypeStr = items[index];
             self.tv_invoice_type.text = invoicetypeStr;
             NSRange range = [invoicetypeStr rangeOfString:@"专用"];
             if (range.length >0)
             {
                 [self showReceiptInfoView];
             }
             else
             {
                 [self hiddenReceiptInfoView];
             }
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
    
    if(selectTime == 2)
    {
        self.tv_prepaytime.text = targetDate;
    }
    else if(selectTime == 6)
    {
        self.kaipiao_time_Field.text = targetDate;
    }
    serviceDate = date;
}

//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker did dismiss with %lu", method);
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker will dismiss with %lu", method);
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
            projInfNoList = [[NSMutableArray alloc] init];
            projInfAmtList = [[NSMutableArray alloc] init];
            
            for(ProjInf *pro in projInfList)
            {
                [projInfNoList addObject:[NSString stringWithFormat:@"协议编号:%@",pro.Agt_No]];
                [projInfAmtList addObject:[NSString stringWithFormat:@"协议金额:%@",pro.Agt_Amt]];
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"当前协议内容为空,不能申请发票" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (IBAction)kaipiaoAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否开票" message:@"是否已开票？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    alert.tag = 0;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        self.kaipiao_label.text = @"是";
        self.fapiaono_Field.enabled = YES;
        self.kaipiao_time_Field.enabled = YES;
    }
    else if(buttonIndex == 1) {
        self.kaipiao_label.text = @"否";
        self.fapiaono_Field.text = @"";
        self.kaipiao_time_Field.text = @"";
        self.fapiaono_Field.enabled = NO;
        self.kaipiao_time_Field.enabled = NO;
    }
}

- (void)hiddenReceiptInfoView
{
    self.receiptInfoView.hidden = YES;
    
    self.receiptBottomView.frame = CGRectMake(self.receiptBottomView.frame.origin.x, self.receiptInfoView.frame.origin.y, self.receiptBottomView.frame.size.width, self.receiptBottomView.frame.size.height);
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.receiptBottomView.frame.origin.y + self.receiptBottomView.frame.size.height);
}

- (void)showReceiptInfoView
{
    self.receiptInfoView.hidden = NO;
    
    self.receiptBottomView.frame = CGRectMake(self.receiptBottomView.frame.origin.x, self.receiptBottomView.frame.origin.y + self.receiptInfoView.frame.size.height, self.receiptBottomView.frame.size.width, self.receiptBottomView.frame.size.height);
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.receiptBottomView.frame.origin.y + self.receiptBottomView.frame.size.height);
}

@end
