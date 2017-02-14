//
//  SecurityDetailView.m
//  Broad
//
//  Created by Seven on 16/12/19.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import "SecurityDetailView.h"
#import "EnginUnit.h"
#import "RepairImgCell.h"
#import "Img.h"
#import "UIImageView+WebCache.h"
#import "SecurityUpdateView.h"

@interface SecurityDetailView ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSArray *imgArray;
}

@end

@implementation SecurityDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"详情";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.imgCollectionView.delegate = self;
    self.imgCollectionView.dataSource = self;
    
    imgArray = [[NSMutableArray alloc] init];
    [self.imgCollectionView registerClass:[RepairImgCell class] forCellWithReuseIdentifier:@"RepairImgCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifire:) name:@"securityNotifire" object:nil];
    [self bindData];
    [self getAnQuanSecurity];
}

- (void)getAnQuanSecurity
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModule '%@','DA0305'", app.userinfo.JiaoSe];
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
                 if ([s.ModuleCode isEqualToString:@"DA0305"] && [s.PermissionName isEqualToString:@"修改"]) {
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
             }
         };
         NSLog(@"%@", operation.responseString);
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}


- (void)update
{
    SecurityUpdateView *updateView = [[SecurityUpdateView alloc] init];
    updateView.security = self.security;
    [self.navigationController pushViewController:updateView animated:YES];
}

- (void)notifire:(NSNotification *)notification
{
    self.security = notification.userInfo[@"security"];
    [self bindData];
}

-(void) bindData
{
    [self getImg:self.security.allfilename];
    
    self.enginer_label.text = self.security.Exec_Man;
    self.uploador_label.text = self.security.Uploader;
    self.uploadtime_label.text = self.security.UploadTime;
    self.serviceproject_label.text = self.security.Project;
    
    if (self.security.Exec_Date.length > 0)
    {
        NSString *timeStr = @"";
        if([self.security.Exec_Date rangeOfString:@" "].length > 0)
        {
            timeStr = [self.security.Exec_Date substringToIndex:[self.security.Exec_Date rangeOfString:@" "].location];
        }
        else
        {
            timeStr = self.security.Exec_Date;
        }
        self.servicetime_label.text = timeStr;
    }
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
    NSArray *imgFileNames = [imgurl componentsSeparatedByString:@"|"];
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
             NSLog(@"%@", string);
             NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             imgArray = nil;
             imgArray = [Tool readJsonToObjArray:table andObjClass:[Img class]];
             hud.hidden = YES;
             if(imgArray && imgArray.count > 0)
             {
                 for (int i = 0; i < imgArray.count; i++) {
                     Img *img = imgArray[i];
                     img.fileName = imgFileNames[i+1];
                 }
                 self.security.imgList = [NSMutableArray arrayWithArray:imgArray];
                 self.imgCollectionView.hidden = NO;
                 [self.photos removeAllObjects];
                 [self.imgCollectionView reloadData];
             }
             else
             {
                 [self.photos removeAllObjects];
                 [self.imgCollectionView reloadData];
             }
             
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         hud.hidden = YES;
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
     }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
