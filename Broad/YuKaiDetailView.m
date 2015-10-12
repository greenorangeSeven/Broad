//
//  YuKaiDetailView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/14.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "YuKaiDetailView.h"

@interface YuKaiDetailView ()

@end

@implementation YuKaiDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"详情";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.tv_qianshou.frame.origin.y + 1180);
    
    self.tv_applicant.text = self.invoice.App_Name;
    self.tv_service.text = self.invoice.Serv_Dept;
    self.tv_yifang.text = self.invoice.CONTR_SecParty;
    self.et_cuase.text = self.invoice.App_reason;
    self.tv_invoice_type.text = self.invoice.Invoice_Type;
    self.tv_invoice_proj.text = self.invoice.Invoice_Item;
    
    
    self.tv_paynum_p.text = [NSString stringWithFormat:@"%f",self.invoice.App_InvoiceAMT];
    
    self.tv_paynum.text = [NSString stringWithFormat:@"%f",self.invoice.BefPay_AMT];
    
    self.tv_prepaytime.text = self.invoice.BefPay_Date;
    self.tv_protocol.text = self.invoice.CONTR_No;
    self.tv_departname.text = self.invoice.CUST_Name;
    
    self.tv_zhuguan.text = [NSString stringWithFormat:@"%@\n%@-%@",self.invoice.Leader_Opinion,self.invoice.Leader_Sign,self.invoice.Leader_SignDate];
    
    self.tv_zongjingli.text = [NSString stringWithFormat:@"%@\n%@-%@",self.invoice.UserGenManager_Opinion,self.invoice.UserGenManager_Sign,self.invoice.UserGenManager_SignDate];
    
    self.tv_kaipiao.text = self.invoice.MakeOutInvoice_Sign;
    self.tv_fapiaono.text = self.invoice.Invoice_No;
    self.tv_fapiaonotime.text = self.invoice.MakeOutInvoice_Date;
    
    self.tv_caiwu.text = [NSString stringWithFormat:@"%@\n%@-%@",self.invoice.Fin_Opinion,self.invoice.Fin_Sign,self.invoice.Fin_SignDate];
    self.tv_qianshou.text = [NSString stringWithFormat:@"%@\n%@",self.invoice.SignFor_INF,self.invoice.SignFor_Date];
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
