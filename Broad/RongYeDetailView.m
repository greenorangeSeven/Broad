//
//  WeiXiuAddView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "RongYeDetailView.h"
#import "EnginUnit.h"
#import "Solution.h"
#import "RepairImgCell.h"
#import "Img.h"
#import "UIImageView+WebCache.h"
#import "RongYeUpdate2017View.h"

@interface RongYeDetailView ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableDictionary *imgDic;
    NSArray *imgArray;
    BOOL isOld;
    
    NSString *systemTime;
}

@end

@implementation RongYeDetailView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"详情";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    
    self.imgCollectionView.delegate = self;
    self.imgCollectionView.dataSource = self;
    
    //    self.servicetime_field.enabled = NO;
    
    imgArray = [[NSMutableArray alloc] init];
    [self.imgCollectionView registerClass:[RepairImgCell class] forCellWithReuseIdentifier:@"RepairImgCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifireSolution:) name:@"notifireSolution" object:nil];
    [self bindData];
}

- (void)getRongYeSecurity
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModule '%@','DA0302'", app.userinfo.JiaoSe];
    [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sqlStr,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error;
             NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             NSArray *securityList = [Tool readJsonToObjArray:jsonArray andObjClass:[UserSecurity class]];
             BOOL haveQueryRecord = NO;
             for (UserSecurity *s in securityList) {
                 if ([s.ModuleCode isEqualToString:@"DA0302"] && [s.PermissionName isEqualToString:@"修改"]) {
                     haveQueryRecord = YES;
                     break;
                 }
             }
             if(haveQueryRecord)
             {
                 UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                 addBtn.frame = CGRectMake(0, 0, 78, 44);
                 [addBtn setTitle:@"修改" forState:UIControlStateNormal];
                 [addBtn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
                 UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
                 self.navigationItem.rightBarButtonItem = addItem;
                 [self getSystemTime];
             }
         };
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)getSystemTime
{
    [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@GetNowDateTime",api_base_url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             systemTime = [Tool transformDateFormat:string andFromFormatterStr:@"yyyy-MM-dd HH:mm" andToFormatterStr:@"yyyy-MM-dd"];
             long systemTimeLong = [[Tool transformDateFormat:string andFromFormatterStr:@"yyyy-MM-dd HH:mm" andToFormatterStr:@"MMdd"] longLongValue];
             long systemYearLong = [[Tool transformDateFormat:string andFromFormatterStr:@"yyyy-MM-dd HH:mm" andToFormatterStr:@"yyyy"] longLongValue];
             //取样年份
             long execTimeLong = [[Tool transformDateFormat:self.servicetime_field.text andFromFormatterStr:@"yyyy-MM-dd" andToFormatterStr:@"yyyy"] longLongValue];
             if ((execTimeLong != systemYearLong) || systemTimeLong > 630) {
                 //                 UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                 //                 addBtn.frame = CGRectMake(0, 0, 78, 44);
                 //                 [addBtn setTitle:@"修改" forState:UIControlStateNormal];
                 //                 [addBtn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
                 //                 UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
                 self.navigationItem.rightBarButtonItem = nil;
             }
             
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)notifireSolution:(NSNotification *)notification
{
    self.solution = notification.userInfo[@"solution"];
    
    [self bindData];
}

- (void)update
{
    RongYeUpdate2017View *updateView = [[RongYeUpdate2017View alloc] init];
    updateView.solution = self.solution;
    [self.navigationController pushViewController:updateView animated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 动态调整scrollView的高度
- (void)reSizeCollectionView
{
    //这里根据小区个数自动调整高度
    NSInteger size = (imgArray.count)/3;
    
    NSInteger height = 0;
    if(size < 1)
    {
        height = 130;
    }
    else
    {
        height = size * 85 + 220;
    }
    
    float x = self.imgCollectionView.frame.origin.x;
    float y = self.imgCollectionView.frame.origin.y;
    float width = self.imgCollectionView.frame.size.width;
    
    //调整网格布局高度
    self.imgCollectionView.frame = CGRectMake(x, y, width, height);
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.imgCollectionView.frame.origin.y + self.imgCollectionView.frame.size.height + 10);
}

#pragma mark - 图片集合
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imgArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RepairImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RepairImgCell" forIndexPath:indexPath];
    if (!cell)
    {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RepairImgCell" owner:self options:nil];
        for (NSObject *o in objects)
        {
            if ([o isKindOfClass:[RepairImgCell class]])
            {
                cell = (RepairImgCell *)o;
                break;
            }
        }
    }
    
    Img *image = [imgArray objectAtIndex:[indexPath row]];
    [cell.repairImg sd_setImageWithURL:[NSURL URLWithString:image.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
    cell.repairImg.frame = CGRectMake(0, 0, 85, 85);
    //    cell.deleteBtn.hidden = YES;
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(85, 85);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.photos count] == 0) {
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        for (Img *image in imgArray) {
            MWPhoto * photo = [MWPhoto photoWithURL:[NSURL URLWithString:image.Url]];
            [photos addObject:photo];
        }
        self.photos = photos;
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = NO;//左右分页切换,默认否
    browser.displaySelectionButtons = NO;//是否显示选择按钮在图片上,默认否
    browser.alwaysShowControls = YES;//控制条件控件 是否显示,默认否
    browser.zoomPhotosToFill = NO;//是否全屏,默认是
    //    browser.wantsFullScreenLayout = YES;//是否全屏
    [browser setCurrentPhotoIndex:[indexPath row]];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:browser animated:YES];
}

//MWPhotoBrowserDelegate委托事件
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)getImg:(NSString *)imgurl
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@GetFileUrl",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:imgurl,@"fileName", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             hud.hidden = YES;
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
             [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error;
             
             NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             imgArray = nil;
             imgArray = [Tool readJsonToObjArray:table andObjClass:[Img class]];
             hud.hidden = YES;
             [self.solution.imgList removeAllObjects];
             if(imgArray && imgArray.count > 0)
             {
                 self.solution.imgList = [NSMutableArray arrayWithArray:imgArray];
                 self.imgCollectionView.hidden = NO;
                 [self reSizeCollectionView];
             }
             [self.photos removeAllObjects];
             [self.imgCollectionView reloadData];
             
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         hud.hidden = YES;
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
     }];
}

-(void) bindData
{
    
    [self getImg:self.solution.allfilename];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.enginer_field.text = self.solution.ExecMan;
    self.user_field.text = app.depart.CustShortName_CN;
    self.uploador_field.text = self.solution.Uploader;
    self.uploadtime_field.text = self.solution.UploadTime;
    self.chucang_no_label.text = self.solution.OutFactNum;
    self.engine_no_label.text = self.solution.AirCondUnitMode;
    self.create_no_label.text = self.solution.ProdNum;
    if (self.solution.ExecDate.length > 0)
    {
        NSString *timeStr = @"";
        if([self.solution.ExecDate rangeOfString:@" "].length > 0)
        {
            timeStr = [self.solution.ExecDate substringToIndex:[self.solution.ExecDate rangeOfString:@" "].location];
        }
        else
        {
            timeStr = self.solution.ExecDate;
        }
        self.servicetime_field.text = timeStr;
        
    }
    if (self.solution.UploadTime.length > 0)
    {
        NSString *timeStr = @"";
        if([self.self.solution.UploadTime rangeOfString:@" "].length > 0)
        {
            timeStr = [self.solution.UploadTime substringToIndex:[self.solution.UploadTime rangeOfString:@" "].location];
        }
        else
        {
            timeStr = self.solution.UploadTime;
        }
        
        self.uploadtime_field.text = timeStr;
        
    }
    [self getRongYeSecurity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
