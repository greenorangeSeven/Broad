//
//  WeiXiuCell.h
//  Broad
//
//  Created by 赵腾欢 on 15/9/4.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name_label;
@property (weak, nonatomic) IBOutlet UILabel *type_label;
@property (weak, nonatomic) IBOutlet UILabel *no_label;
@property (weak, nonatomic) IBOutlet UILabel *tag_label;
@property (weak, nonatomic) IBOutlet UIImageView *tag_img;

@end
