//
//  WeiXiuAddView.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Solution.h"

@interface RongYeUpdateView : UIViewController

@property (strong,nonatomic) Solution *solution;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *user_field;

@property (weak, nonatomic) IBOutlet UITextField *enginer_field;
@property (weak, nonatomic) IBOutlet UITextField *uploador_field;
@property (weak, nonatomic) IBOutlet UITextField *uploadtime_field;

@property (weak, nonatomic) IBOutlet UITextField *servicetime_field;

@property (weak, nonatomic) IBOutlet UILabel *engine_no_label;
@property (weak, nonatomic) IBOutlet UILabel *chucang_no_label;
@property (weak, nonatomic) IBOutlet UILabel *create_no_label;

@property (weak, nonatomic) IBOutlet UIView *engine_choice_view;
@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionView;

@end
