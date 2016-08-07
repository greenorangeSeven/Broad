//
//  YuKaiAddView.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YuKaiAddView : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *tv_usercode;
@property (weak, nonatomic) IBOutlet UILabel *tv_day_time;
@property (weak, nonatomic) IBOutlet UITextField *tv_departname;
@property (weak, nonatomic) IBOutlet UITextField *tv_protocol;
@property (weak, nonatomic) IBOutlet UITextField *tv_prepaytime;
@property (weak, nonatomic) IBOutlet UITextField *tv_paynum;
@property (weak, nonatomic) IBOutlet UITextField *tv_paynum_p;
@property (weak, nonatomic) IBOutlet UITextField *tv_invoice_proj;
@property (weak, nonatomic) IBOutlet UITextField *tv_invoice_type;
@property (weak, nonatomic) IBOutlet UITextField *et_cuase;
@property (weak, nonatomic) IBOutlet UITextField *tv_yifang;
@property (weak, nonatomic) IBOutlet UILabel *tv_service;
@property (weak, nonatomic) IBOutlet UILabel *tv_applicant;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *receiptInfoView;
@property (weak, nonatomic) IBOutlet UIView *receiptBottomView;

@property (weak, nonatomic) IBOutlet UITextField *tf_TaxNumber;
@property (weak, nonatomic) IBOutlet UITextField *tf_TompanyAdd;
@property (weak, nonatomic) IBOutlet UITextField *tf_TompanyTel;
@property (weak, nonatomic) IBOutlet UITextField *tf_Bank;
@property (weak, nonatomic) IBOutlet UITextField *tf_Account;

@end
