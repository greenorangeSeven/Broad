//
//  YuKaiFlowView.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/19.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YuKaiFlowView : UIViewController

@property (copy, nonatomic) NSString *Mark;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *tv_departname;
@property (weak, nonatomic) IBOutlet UITextField *tv_protocol;
@property (weak, nonatomic) IBOutlet UITextField *tv_prepaytime;
//@property (weak, nonatomic) IBOutlet UITextField *tv_paynum;
@property (weak, nonatomic) IBOutlet UITextField *tv_paynum_p;
@property (weak, nonatomic) IBOutlet UITextField *tv_invoice_proj;
@property (weak, nonatomic) IBOutlet UITextField *tv_invoice_type;
@property (weak, nonatomic) IBOutlet UITextField *et_cuase;
@property (weak, nonatomic) IBOutlet UITextField *tv_yifang;
@property (weak, nonatomic) IBOutlet UILabel *tv_service;
@property (weak, nonatomic) IBOutlet UILabel *tv_applicant;
@property (weak, nonatomic) IBOutlet UILabel *zhuguan_label;

@property (weak, nonatomic) IBOutlet UILabel *zongjingli_label;
@property (weak, nonatomic) IBOutlet UILabel *caiwu_label;
@property (weak, nonatomic) IBOutlet UILabel *qianshou_label;
@property (weak, nonatomic) IBOutlet UILabel *kaipiao_label;
@property (weak, nonatomic) IBOutlet UITextField *fapiaono_Field;
@property (weak, nonatomic) IBOutlet UITextField *kaipiao_time_Field;
- (IBAction)comitAction:(id)sender;
- (IBAction)backFlowAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *comitBtn;
@property (weak, nonatomic) IBOutlet UIButton *backFlowBtn;
- (IBAction)kaipiaoAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *kaipiaoBtn;

@property (weak, nonatomic) IBOutlet UIView *receiptInfoView;
@property (weak, nonatomic) IBOutlet UIView *receiptBottomView;

@property (weak, nonatomic) IBOutlet UITextField *tf_TaxNumber;
@property (weak, nonatomic) IBOutlet UITextField *tf_TompanyAdd;
@property (weak, nonatomic) IBOutlet UITextField *tf_Bank;


@end
