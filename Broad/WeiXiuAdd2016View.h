//
//  WeiXiuAdd2016View.h
//  Broad
//
//  Created by Seven on 16/1/19.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeiXiuAdd2016View : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *enginer_label;
@property (weak, nonatomic) IBOutlet UILabel *uploador_label;
@property (weak, nonatomic) IBOutlet UILabel *uploadtime_label;
@property (weak, nonatomic) IBOutlet UITextField *servcetype_field;

@property (weak, nonatomic) IBOutlet UITextField *serviceproject_field;
@property (weak, nonatomic) IBOutlet UITextField *servicetime_field;
@property (weak, nonatomic) IBOutlet UITextField *servicetime2_field;
@property (weak, nonatomic) IBOutlet UITextField *servicetime3_field;

@property (weak, nonatomic) IBOutlet UILabel *engine_no_label;
@property (weak, nonatomic) IBOutlet UILabel *chucang_no_label;
@property (weak, nonatomic) IBOutlet UIView *engine_choice_view;
@property (weak, nonatomic) IBOutlet UIView *imgContain_view;
@property (weak, nonatomic) IBOutlet UIView *img1_view;
@property (weak, nonatomic) IBOutlet UILabel *img1_label;
@property (weak, nonatomic) IBOutlet UIButton *img1_button;
@property (weak, nonatomic) IBOutlet UIView *img2_view;
@property (weak, nonatomic) IBOutlet UILabel *img2_label;
@property (weak, nonatomic) IBOutlet UIButton *img2_button;
@property (weak, nonatomic) IBOutlet UIView *img3_view;
@property (weak, nonatomic) IBOutlet UILabel *img3_label;
@property (weak, nonatomic) IBOutlet UIButton *img3_button;
@property (weak, nonatomic) IBOutlet UIView *img4_view;
@property (weak, nonatomic) IBOutlet UILabel *img4_label;
@property (weak, nonatomic) IBOutlet UIButton *img4_button;
@property (weak, nonatomic) IBOutlet UIView *img5_view;
@property (weak, nonatomic) IBOutlet UILabel *img5_label;
@property (weak, nonatomic) IBOutlet UIButton *img5_button;
@property (weak, nonatomic) IBOutlet UIView *img6_view;
@property (weak, nonatomic) IBOutlet UILabel *img6_label;
@property (weak, nonatomic) IBOutlet UIButton *img6_button;
@property (weak, nonatomic) IBOutlet UIView *img7_view;
@property (weak, nonatomic) IBOutlet UILabel *img7_label;
@property (weak, nonatomic) IBOutlet UIButton *img7_button;
@property (weak, nonatomic) IBOutlet UIView *img8_view;
@property (weak, nonatomic) IBOutlet UILabel *img8_label;
@property (weak, nonatomic) IBOutlet UIButton *img8_button;
@property (weak, nonatomic) IBOutlet UIView *img9_view;
@property (weak, nonatomic) IBOutlet UILabel *img9_label;
@property (weak, nonatomic) IBOutlet UIButton *img9_button;
@property (weak, nonatomic) IBOutlet UIView *img10_view;
@property (weak, nonatomic) IBOutlet UILabel *img10_label;
@property (weak, nonatomic) IBOutlet UIButton *img10_button;
@property (weak, nonatomic) IBOutlet UIView *img11_view;
@property (weak, nonatomic) IBOutlet UILabel *img11_label;
@property (weak, nonatomic) IBOutlet UIButton *img11_button;
@property (weak, nonatomic) IBOutlet UIView *img12_view;
@property (weak, nonatomic) IBOutlet UILabel *img12_label;
@property (weak, nonatomic) IBOutlet UIButton *img12_button;
@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionView;

- (IBAction)imgChoiceAction:(id)sender;

@end
