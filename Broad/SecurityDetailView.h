//
//  SecurityDetailView.h
//  Broad
//
//  Created by Seven on 16/12/19.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecurityInfo.h"
#import "MWPhotoBrowser.h"

@interface SecurityDetailView : UIViewController<MWPhotoBrowserDelegate>
{
    NSMutableArray *_photos;
}

@property (nonatomic, retain) NSMutableArray *photos;

@property (strong, nonatomic) SecurityInfo *security;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *enginer_label;
@property (weak, nonatomic) IBOutlet UILabel *uploador_label;
@property (weak, nonatomic) IBOutlet UILabel *uploadtime_label;
@property (weak, nonatomic) IBOutlet UILabel *serviceproject_label;
@property (weak, nonatomic) IBOutlet UILabel *servicetime_label;

@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionView;

@end
