//
//  LoginView.h
//  Broad
//  登录页面
//  Created by 赵腾欢 on 15/8/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *contactBtn;
- (IBAction)loginAction:(id)sender;
- (IBAction)contactAction:(id)sender;

@end
