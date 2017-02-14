//
//  WeiXiuDetail2017View.m
//  Broad
//
//  Created by Seven on 16/12/9.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import "WeiXiuDetail2017View.h"
#import "EnginUnit.h"
#import "MatnRec.h"
#import "RepairImgCell.h"
#import "Img.h"
#import "UIImageView+WebCache.h"
#import "WeiXiuUpdate2017View.h"

@interface WeiXiuDetail2017View ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableDictionary *imgDic;
    NSArray *imgArray;
    BOOL isOld;
    
    BOOL isJieDian;
}

@end

@implementation WeiXiuDetail2017View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"详情";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    [self initData];
    
    self.imgCollectionView.delegate = self;
    self.imgCollectionView.dataSource = self;
    
    self.servicetime_field.enabled = NO;
    self.servicetime2_field.enabled = NO;
    self.servicetime3_field.enabled = NO;
    imgArray = [[NSMutableArray alloc] init];
    [self.imgCollectionView registerClass:[RepairImgCell class] forCellWithReuseIdentifier:@"RepairImgCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifire:) name:@"notifire" object:nil];
    [self bindData];
}

- (void)getWeiHuSecurity
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModule '%@','DA0301'", app.userinfo.JiaoSe];
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
                 if ([s.ModuleCode isEqualToString:@"DA0301"] && [s.PermissionName isEqualToString:@"修改"]) {
                     haveQueryRecord = YES;
                     break;
                 }
             }
             if(!haveQueryRecord)
             {
                 self.navigationItem.rightBarButtonItem = nil;
             }
         };
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)initData
{
    [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@GetNowDateTime",api_base_url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
             [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSString *targetDate = [Tool transformDateFormat:string andFromFormatterStr:@"yyyy-MM-dd HH:mm" andToFormatterStr:@"yyyy-MM-dd"];
             long year = [[Tool transformDateFormat:self.matnRec.UploadTime andFromFormatterStr:@"yyyy-MM-dd HH:mm" andToFormatterStr:@"yyyy"] longLongValue];
             if ([self.matnRec.Type isEqualToString:@"年4次保养"])
             {
                 NSString *start = nil;
                 NSString *end = nil;
                 
                 long uploadMonthDayLong = [[Tool transformDateFormat:self.matnRec.UploadTime andFromFormatterStr:@"yyyy-MM-dd HH:mm" andToFormatterStr:@"MMdd"] longLongValue];
                 
                 if ([self.matnRec.Project isEqualToString:@"年1次保养"])
                 {
                     if(uploadMonthDayLong >= 1226)
                     {
                         start = [NSString stringWithFormat:@"%li-12-26",year];
                         end = [NSString stringWithFormat:@"%li-03-25",year+1];
                     }
                     else if (uploadMonthDayLong <= 325)
                     {
                         start = [NSString stringWithFormat:@"%li-12-26",year - 1];
                         end = [NSString stringWithFormat:@"%li-03-25",year];
                     }
                 }
                 else if ([self.matnRec.Project isEqualToString:@"年2次保养"])
                 {
                     start = [NSString stringWithFormat:@"%li-03-26",year];
                     end = [NSString stringWithFormat:@"%li-06-25",year];
                 }
                 else if ([self.matnRec.Project isEqualToString:@"年3次保养"])
                 {
                     start = [NSString stringWithFormat:@"%li-06-26",year];
                     end = [NSString stringWithFormat:@"%li-09-25",year];
                 }
                 else if ([self.matnRec.Project isEqualToString:@"年4次保养"])
                 {
                     start = [NSString stringWithFormat:@"%li-09-26",year];
                     end = [NSString stringWithFormat:@"%li-12-25",year];
                 }
                 int tag = [Tool compareOneDay:targetDate withAnotherDay:start];
                 //如果为0则两个日期相等,如果为1则服务时间大于起始时间
                 if(tag == 0 || tag == 1)
                 {
                     int tag = [Tool compareOneDay:targetDate withAnotherDay:end];
                     //如果为0则两个日期相等,如果为-1则服务时间小于起始时间
                     if(tag == 0 || tag == -1)
                     {
                         UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                         addBtn.frame = CGRectMake(0, 0, 78, 44);
                         [addBtn setTitle:@"修改" forState:UIControlStateNormal];
                         [addBtn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
                         UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
                         self.navigationItem.rightBarButtonItem = addItem;
                     }
                 }
             }
             else
             {
                 UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                 addBtn.frame = CGRectMake(0, 0, 78, 44);
                 [addBtn setTitle:@"修改" forState:UIControlStateNormal];
                 [addBtn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
                 UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
                 self.navigationItem.rightBarButtonItem = addItem;
             }
             [self getWeiHuSecurity];
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
         
     }];
}

- (void)notifire:(NSNotification *)notification
{
    self.matnRec = notification.userInfo[@"matnRec"];
    [self.img1_ImgView setImage:nil];
    [self.img2_ImgView setImage:nil];
    [self.img3_ImgView setImage:nil];
    [self.img4_ImgView setImage:nil];
    [self.img5_ImgView setImage:nil];
    [self.img6_ImgView setImage:nil];
    [self.img7_ImgView setImage:nil];
    [self.img8_ImgView setImage:nil];
    [self.img9_ImgView setImage:nil];
    [self.img10_ImgView setImage:nil];
    [self.img11_ImgView setImage:nil];
    [self.img12_ImgView setImage:nil];
    
    [self bindData];
}

- (void)update
{
    WeiXiuUpdate2017View *updateView = [[WeiXiuUpdate2017View alloc] init];
    updateView.matnRec = self.matnRec;
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
    //    cell.repairImg.frame = CGRectMake(0, 0, 85, 85);
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
             if(imgArray && imgArray.count > 0)
             {
                 self.matnRec.imgList = [NSMutableArray arrayWithArray:imgArray];
                 self.matnRec.isOld = isOld;
                 if(isOld)
                 {
                     self.imgCollectionView.hidden = NO;
                     self.imgContain_view.hidden = YES;
                     [self reSizeCollectionView];
                     [self.photos removeAllObjects];
                     [self.imgCollectionView reloadData];
                 }
                 else
                 {
                     self.imgContain_view.hidden = NO;
                     self.imgCollectionView.hidden = YES;
                     [self.photos removeAllObjects];
                     //                     self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.img9_view.frame.origin.y + self.img9_view.frame.size.height + 200);
                     [self setImg];
                 }
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

-(void) setImg
{
    int index = 0;
    if (self.matnRec.allfilename.length > 0)
    {
        Img *img = imgArray[index];
        [self.img1_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img1_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img1_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename02.length > 0)
    {
        Img *img = imgArray[index];
        [self.img2_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img2_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img2_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename03.length > 0)
    {
        Img *img = imgArray[index];
        [self.img3_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img3_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img3_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename04.length > 0)
    {
        Img *img = imgArray[index];
        
        [self.img4_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img4_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img4_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename05.length > 0)
    {
        Img *img = imgArray[index];
        [self.img5_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img5_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img5_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename06.length > 0)
    {
        Img *img = imgArray[index];
        [self.img6_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img6_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img6_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename07.length > 0)
    {
        Img *img = imgArray[index];
        
        [self.img7_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img7_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img7_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename08.length > 0)
    {
        Img *img = imgArray[index];
        
        [self.img8_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img8_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img8_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename09.length > 0)
    {
        Img *img = imgArray[index];
        
        [self.img9_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img9_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img9_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename10.length > 0)
    {
        Img *img = imgArray[index];
        
        [self.img10_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img10_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img10_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename11.length > 0)
    {
        Img *img = imgArray[index];
        [self.img11_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img11_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img11_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
    if (self.matnRec.allfilename12.length > 0)
    {
        Img *img = imgArray[index];
        [self.img12_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.img12_ImgView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.img12_ImgView addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
}

- (void)imgTapClick:(UITapGestureRecognizer *)sender
{
    //    UIImageView *img = (UIImageView *)sender;
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
    [browser setCurrentPhotoIndex:sender.view.tag];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:browser animated:YES];
}

-(void) bindData
{
    NSString *machineOther = self.matnRec.MachineOther;
    if([self.matnRec.Type isEqualToString:@"年4次保养"])
    {
        if(machineOther != nil && [machineOther rangeOfString:@"节电空调"].length > 0)
        {
            isJieDian = YES;
        }
        else
        {
            isJieDian = NO;
        }
    }
    
    if ([self.matnRec.Project isEqualToString:@"年1次保养"])
    {
        if(isJieDian)
        {
            self.img1_label.text = @"操作屏实时工况";
            self.img2_label.text = @"售后服务单";
            self.img3_view.hidden = YES;
            self.img4_view.hidden = YES;
            self.img5_view.hidden = YES;
            self.img6_view.hidden = YES;
            self.img7_view.hidden = YES;
            self.img8_view.hidden = YES;
            self.img9_view.hidden = YES;
            self.img10_view.hidden = YES;
            self.img11_view.hidden = YES;
            self.img12_view.hidden = YES;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.self.imgContain_view.frame.origin.y + self.self.img2_view.frame.origin.y + self.img2_view.frame.size.height);
            NSString *imgurl = [NSString stringWithFormat:@"%@%@",self.matnRec.allfilename,self.matnRec.allfilename02];
            [self getImg:imgurl];
        }
        else
        {
            self.img1_label.text = @"主体真空值";
            self.img2_label.text = @"操作屏实时工况";
            self.img3_label.text = @"其它";
            self.img4_label.text = @"售后服务单";
            self.img5_view.hidden = YES;
            self.img6_view.hidden = YES;
            self.img7_view.hidden = YES;
            self.img8_view.hidden = YES;
            self.img9_view.hidden = YES;
            self.img10_view.hidden = YES;
            self.img11_view.hidden = YES;
            self.img12_view.hidden = YES;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.self.imgContain_view.frame.origin.y + self.self.img4_view.frame.origin.y + self.img4_view.frame.size.height);
            NSString *imgurl = [NSString stringWithFormat:@"%@%@%@%@",self.matnRec.allfilename,self.matnRec.allfilename02,self.matnRec.allfilename03,self.matnRec.allfilename04];
            [self getImg:imgurl];
        }
    }
    else if ([self.matnRec.Project isEqualToString:@"年2次保养"])
    {
        if(isJieDian)
        {
            self.img1_label.text = @"冷水/冷却水靶流靶片长度";
            self.img2_label.text = @"机房机组清洁检查";
            self.img3_label.text = @"控制柜";
            self.img4_label.text = @"售后服务单";
            self.img5_view.hidden = YES;
            self.img6_view.hidden = YES;
            self.img7_view.hidden = YES;
            self.img8_view.hidden = YES;
            self.img9_view.hidden = YES;
            self.img10_view.hidden = YES;
            self.img11_view.hidden = YES;
            self.img12_view.hidden = YES;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.self.imgContain_view.frame.origin.y + self.self.img4_view.frame.origin.y + self.img4_view.frame.size.height);
            NSString *imgurl = [NSString stringWithFormat:@"%@%@%@%@",self.matnRec.allfilename,self.matnRec.allfilename02,self.matnRec.allfilename03,self.matnRec.allfilename04];
            [self getImg:imgurl];
        }
        else
        {
            self.img1_label.text = @"三级靶流靶片长度";
            self.img2_label.text = @"真空泵极限值";
            self.img3_label.text = @"点火电极检查";
            self.img4_label.text = @"燃烧机风轮";
            self.img5_label.text = @"燃料过滤器清理";
            self.img6_label.text = @"最大燃烧量O2含量";
            self.img7_label.text = @"机房机组清洁检查";
            self.img8_label.text = @"控制柜";
            self.img9_label.text = @"售后服务单";
            self.img10_view.hidden = YES;
            self.img11_view.hidden = YES;
            self.img12_view.hidden = YES;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.self.imgContain_view.frame.origin.y + self.self.img9_view.frame.origin.y + self.img9_view.frame.size.height);
            NSString *imgurl = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",self.matnRec.allfilename,self.matnRec.allfilename02,self.matnRec.allfilename03,self.matnRec.allfilename04,self.matnRec.allfilename05,self.matnRec.allfilename06,self.matnRec.allfilename07,self.matnRec.allfilename08,self.matnRec.allfilename09];
            [self getImg:imgurl];
        }
        
    }
    else if ([self.matnRec.Project isEqualToString:@"年3次保养"])
    {
        if(isJieDian)
        {
            self.img1_label.text = @"冷却塔水盘";
            self.img2_label.text = @"操作屏实时工况";
            self.img3_label.text = @"售后服务单";
            self.img4_view.hidden = YES;
            self.img5_view.hidden = YES;
            self.img6_view.hidden = YES;
            self.img7_view.hidden = YES;
            self.img8_view.hidden = YES;
            self.img9_view.hidden = YES;
            self.img10_view.hidden = YES;
            self.img11_view.hidden = YES;
            self.img12_view.hidden = YES;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.self.imgContain_view.frame.origin.y + self.self.img3_view.frame.origin.y + self.img3_view.frame.size.height);
            
            NSString *imgurl = [NSString stringWithFormat:@"%@%@%@",self.matnRec.allfilename,self.matnRec.allfilename02,self.matnRec.allfilename03];
            [self getImg:imgurl];
        }
        else
        {
            self.img1_label.text = @"主体真空值";
            self.img2_label.text = @"冷却塔水盘";
            self.img3_label.text = @"操作屏实时工况";
            self.img4_label.text = @"售后服务单";
            self.img5_view.hidden = YES;
            self.img6_view.hidden = YES;
            self.img7_view.hidden = YES;
            self.img8_view.hidden = YES;
            self.img9_view.hidden = YES;
            self.img10_view.hidden = YES;
            self.img11_view.hidden = YES;
            self.img12_view.hidden = YES;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.self.imgContain_view.frame.origin.y + self.self.img4_view.frame.origin.y + self.img4_view.frame.size.height);
            
            NSString *imgurl = [NSString stringWithFormat:@"%@%@%@%@",self.matnRec.allfilename,self.matnRec.allfilename02,self.matnRec.allfilename03,self.matnRec.allfilename04];
            [self getImg:imgurl];
        }
    }
    else if ([self.matnRec.Project isEqualToString:@"年4次保养"])
    {
        if(isJieDian)
        {
            self.img1_label.text = @"主机水侧排水";
            self.img2_label.text = @"机房机组清洁检查";
            self.img3_label.text = @"控制柜";
            self.img4_label.text = @"售后服务单";
            self.img5_view.hidden = YES;
            self.img6_view.hidden = YES;
            self.img7_view.hidden = YES;
            self.img8_view.hidden = YES;
            self.img9_view.hidden = YES;
            self.img10_view.hidden = YES;
            self.img11_view.hidden = YES;
            self.img12_view.hidden = YES;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.imgContain_view.frame.origin.y + self.img4_view.frame.origin.y + self.img4_view.frame.size.height);
            
            NSString *imgurl = [NSString stringWithFormat:@"%@%@%@%@",self.matnRec.allfilename,self.matnRec.allfilename02,self.matnRec.allfilename03,self.matnRec.allfilename04];
            [self getImg:imgurl];
        }
        else
        {
            self.img1_label.text = @"高发真空值";
            self.img2_label.text = @"主机水侧排水";
            self.img3_label.text = @"烟管";
            self.img4_label.text = @"其它";
            self.img5_label.text = @"机房机组清洁检查";
            self.img6_label.text = @"控制柜";
            self.img7_label.text = @"售后服务单";
            self.img8_view.hidden = YES;
            self.img9_view.hidden = YES;
            self.img10_view.hidden = YES;
            self.img11_view.hidden = YES;
            self.img12_view.hidden = YES;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.imgContain_view.frame.origin.y + self.img7_view.frame.origin.y + self.img7_view.frame.size.height);
            
            NSString *imgurl = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",self.matnRec.allfilename,self.matnRec.allfilename02,self.matnRec.allfilename03,self.matnRec.allfilename04,self.matnRec.allfilename05,self.matnRec.allfilename06,self.matnRec.allfilename07];
            [self getImg:imgurl];
        }
    }
    else
    {
        self.imgContain_view.hidden = YES;
        isOld = true;
        [self getImg:self.matnRec.allfilename];
    }
    
    self.enginer_label.text = self.matnRec.Exec_Man;
    self.uploador_label.text = self.matnRec.Uploader;
    self.uploadtime_label.text = self.matnRec.UploadTime;
    self.servcetype_field.text = self.matnRec.Type;
    self.serviceproject_field.text = self.matnRec.Project;
    self.chucang_no_label.text = self.matnRec.OutFact_Num;
    self.engine_no_label.text = self.matnRec.AirCondUnit_Mode;
    
    if (self.matnRec.Exec_Date.length > 0)
    {
        NSString *timeStr = @"";
        if([self.matnRec.Exec_Date rangeOfString:@" "].length > 0)
        {
            timeStr = [self.matnRec.Exec_Date substringToIndex:[self.matnRec.Exec_Date rangeOfString:@" "].location];
        }
        else
        {
            timeStr = self.matnRec.Exec_Date;
        }
        
        self.servicetime_field.text = timeStr;
    }
    if (![self.matnRec.Exec_Date01 isEqualToString:@"null"] && self.matnRec.Exec_Date01.length > 0)
    {
        NSString *timeStr = self.matnRec.Exec_Date01;
        if([self.matnRec.Exec_Date01 rangeOfString:@" "].length > 0)
        {
            timeStr = [self.matnRec.Exec_Date01 substringToIndex:[self.matnRec.Exec_Date01 rangeOfString:@" "].location];
        }
        else
        {
            timeStr = self.matnRec.Exec_Date01;
        }
        self.servicetime2_field.text = timeStr;
    }
    if (![self.matnRec.Exec_Date02 isEqualToString:@"null"] && self.matnRec.Exec_Date02.length > 0)
    {
        NSString *timeStr = self.matnRec.Exec_Date02;
        if([self.matnRec.Exec_Date02 rangeOfString:@" "].length > 0)
        {
            timeStr = [self.matnRec.Exec_Date02 substringToIndex:[self.matnRec.Exec_Date02 rangeOfString:@" "].location];
        }
        else
        {
            timeStr = self.matnRec.Exec_Date02;
        }
        
        self.servicetime3_field.text = timeStr;
    }
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
