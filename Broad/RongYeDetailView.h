//
//  WeiXiuAddView.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Solution.h"
#import "MWPhotoBrowser.h"

@interface RongYeDetailView : UIViewController<MWPhotoBrowserDelegate>
{
    NSMutableArray *_photos;
}
@property (nonatomic, retain) NSMutableArray *photos;

@property (strong, nonatomic) Solution *solution;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *user_field;

@property (weak, nonatomic) IBOutlet UILabel *enginer_field;
@property (weak, nonatomic) IBOutlet UILabel *uploador_field;
@property (weak, nonatomic) IBOutlet UILabel *uploadtime_field;

@property (weak, nonatomic) IBOutlet UILabel *servicetime_field;

@property (weak, nonatomic) IBOutlet UILabel *engine_no_label;
@property (weak, nonatomic) IBOutlet UILabel *chucang_no_label;
@property (weak, nonatomic) IBOutlet UILabel *create_no_label;

@property (weak, nonatomic) IBOutlet UIView *engine_choice_view;
@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionView;

@end
