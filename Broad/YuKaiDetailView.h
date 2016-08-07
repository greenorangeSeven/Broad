//
//  YuKaiDetailView.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/14.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invoice.h"

@interface YuKaiDetailView : UIViewController

@property (strong, nonatomic) Invoice *invoice;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *tv_departname;
@property (weak, nonatomic) IBOutlet UILabel *tv_protocol;
@property (weak, nonatomic) IBOutlet UILabel *tv_prepaytime;
@property (weak, nonatomic) IBOutlet UILabel *tv_paynum;
@property (weak, nonatomic) IBOutlet UILabel *tv_paynum_p;
@property (weak, nonatomic) IBOutlet UILabel *tv_invoice_proj;
@property (weak, nonatomic) IBOutlet UILabel *tv_invoice_type;
@property (weak, nonatomic) IBOutlet UILabel *et_cuase;
@property (weak, nonatomic) IBOutlet UILabel *tv_yifang;
@property (weak, nonatomic) IBOutlet UILabel *tv_service;
@property (weak, nonatomic) IBOutlet UILabel *tv_applicant;
@property (weak, nonatomic) IBOutlet UILabel *tv_zhuguan;
@property (weak, nonatomic) IBOutlet UILabel *tv_zongjingli;
@property (weak, nonatomic) IBOutlet UILabel *tv_kaipiao;
@property (weak, nonatomic) IBOutlet UILabel *tv_fapiaono;
@property (weak, nonatomic) IBOutlet UILabel *tv_fapiaonotime;
@property (weak, nonatomic) IBOutlet UILabel *tv_caiwu;
@property (weak, nonatomic) IBOutlet UILabel *tv_qianshou;

@property (weak, nonatomic) IBOutlet UIView *receiptInfoView;
@property (weak, nonatomic) IBOutlet UIView *receiptBottomView;

@property (weak, nonatomic) IBOutlet UILabel *tf_TaxNumber;
@property (weak, nonatomic) IBOutlet UILabel *tf_TompanyAdd;
@property (weak, nonatomic) IBOutlet UILabel *tf_TompanyTel;
@property (weak, nonatomic) IBOutlet UILabel *tf_Bank;
@property (weak, nonatomic) IBOutlet UILabel *tf_Account;

@end
