//
//  RongYeAdd2017View.h
//  Broad
//
//  Created by Seven on 17/2/6.
//  Copyright © 2017年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RongYeAdd2017View : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *user_field;

@property (weak, nonatomic) IBOutlet UITextField *enginer_field;
@property (weak, nonatomic) IBOutlet UITextField *uploador_field;
@property (weak, nonatomic) IBOutlet UITextField *uploadtime_field;

@property (weak, nonatomic) IBOutlet UITextField *servicetime_field;

@property (weak, nonatomic) IBOutlet UIView *engine_choice_view;
@property (weak, nonatomic) IBOutlet UILabel *engine_no_label;
@property (weak, nonatomic) IBOutlet UILabel *chucang_no_label;
@property (weak, nonatomic) IBOutlet UILabel *create_no_label;

@property (weak, nonatomic) IBOutlet UIView *quyang_view;
@property (weak, nonatomic) IBOutlet UILabel *quyang_label;
@property (weak, nonatomic) IBOutlet UIButton *quyang_button;

- (IBAction)imgChoiceAction:(id)sender;

@end
