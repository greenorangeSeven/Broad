//
//  SecurityAddView.h
//  Broad
//
//  Created by Seven on 16/12/19.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecurityAddView : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *enginer_label;
@property (weak, nonatomic) IBOutlet UILabel *uploador_label;
@property (weak, nonatomic) IBOutlet UILabel *uploadtime_label;
@property (weak, nonatomic) IBOutlet UITextField *serviceproject_field;
@property (weak, nonatomic) IBOutlet UITextField *servicetime_field;

@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionView;

@end
