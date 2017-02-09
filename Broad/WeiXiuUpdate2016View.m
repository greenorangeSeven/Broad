//
//  WeiXiuUpdate2016View.m
//  Broad
//
//  Created by Seven on 16/1/20.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import "WeiXiuUpdate2016View.h"
#import "HSDatePickerViewController.h"
#import "EnginUnit.h"
#import "SGActionView.h"
#import "MatnRec.h"
#import "RepairImgCell.h"
#import "Img.h"

#define ORIGINAL_MAX_WIDTH 540.0f

@interface WeiXiuUpdate2016View ()<UICollectionViewDataSource, UICollectionViewDelegate,UITextFieldDelegate,HSDatePickerViewControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    MatnRec *newmatnRec;
    NSMutableDictionary *imgDic;
    NSArray *enginUnitArray;
    NSMutableArray *enginUnitNoArray;
    NSMutableArray *enginUnitModeArray;
    NSArray *serviceProjects;
    NSInteger selectedServiceTypeIndex;
    NSInteger selectedServiceNameIndex;
    NSInteger selectedEnginIndex;
    
    NSInteger selectPicIndex;
    UIImageView *targetImg;
    NSInteger selectTimeIndex;
    MBProgressHUD *hud;
    NSDate *serviceDate;
    
    
    NSString *deleteImgStr;
    NSString *newsAllfilename;
    
    double timeCha;
    
    BOOL fromCamera;
    
    BOOL haveUploadImage;
}

@end

@implementation WeiXiuUpdate2016View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    newmatnRec = [[MatnRec alloc] init];
    [newmatnRec initWithMatnRec:self.matnRec];
    
    fromCamera = NO;
    haveUploadImage = NO;
    
    deleteImgStr = @"";
    selectedServiceTypeIndex = -1;
    selectedServiceNameIndex = -1;
    selectedEnginIndex = -1;
    selectPicIndex = -1;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"修改";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 78, 44);
    [addBtn setTitle:@"提交" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    
//    self.imgCollectionView.hidden = YES;
//    self.imgContain_view.hidden = YES;
    
    self.imgCollectionView.delegate = self;
    self.imgCollectionView.dataSource = self;
    
    //初始化图片集合
    imgDic = [[NSMutableDictionary alloc] init];
    if([newmatnRec.Type isEqualToString:@"异常处理"] || [newmatnRec.Type isEqualToString:@"巡视"] || [newmatnRec.Type isEqualToString:@"机房管理"])
    {
        Img *img = [[Img alloc] init];
        img.img = [UIImage imageNamed:@"camera_tag"];
        [newmatnRec.imgList insertObject:img atIndex:0];
        
    }
    
    [self.imgCollectionView registerClass:[RepairImgCell class] forCellWithReuseIdentifier:@"RepairImgCell"];
    
    [self bindData];
    [self initData];
    
    newsAllfilename = self.matnRec.allfilename;
    
    self.servcetype_field.delegate = self;
    self.servcetype_field.tag = 1;
    
    self.serviceproject_field.delegate = self;
    self.serviceproject_field.tag = 2;
    [self initField:self.serviceproject_field];
    
    self.servicetime_field.delegate = self;
    self.servicetime_field.tag = 3;
    [self initField:self.servicetime_field];
    
    self.servicetime2_field.delegate = self;
    self.servicetime2_field.tag = 4;
    
    self.servicetime3_field.delegate = self;
    self.servicetime3_field.tag = 5;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    self.enginer_label.text = app.depart.Duty_Engineer;
    self.uploador_label.text = app.userinfo.UserName;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enginChoice)];
    UITapGestureRecognizer *imgTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction1)];
    UITapGestureRecognizer *imgTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction2)];
    UITapGestureRecognizer *imgTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction3)];
    UITapGestureRecognizer *imgTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction4)];
    UITapGestureRecognizer *imgTap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction5)];
    UITapGestureRecognizer *imgTap6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction6)];
    UITapGestureRecognizer *imgTap7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction7)];
    UITapGestureRecognizer *imgTap8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction8)];
    UITapGestureRecognizer *imgTap9 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction9)];
    UITapGestureRecognizer *imgTap10 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction10)];
    UITapGestureRecognizer *imgTap11 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction11)];
    UITapGestureRecognizer *imgTap12 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction12)];
    
//    [self.engine_choice_view addGestureRecognizer:tap];
    [self.img1_ImgView addGestureRecognizer:imgTap1];
    [self.img2_ImgView addGestureRecognizer:imgTap2];
    [self.img3_ImgView addGestureRecognizer:imgTap3];
    [self.img4_ImgView addGestureRecognizer:imgTap4];
    [self.img5_ImgView addGestureRecognizer:imgTap5];
    [self.img6_ImgView addGestureRecognizer:imgTap6];
    [self.img7_ImgView addGestureRecognizer:imgTap7];
    [self.img8_ImgView addGestureRecognizer:imgTap8];
    [self.img9_ImgView addGestureRecognizer:imgTap9];
    [self.img10_ImgView addGestureRecognizer:imgTap10];
    [self.img11_ImgView addGestureRecognizer:imgTap11];
    [self.img12_ImgView addGestureRecognizer:imgTap12];
    
    
    [self enabledField];
    timeCha = [self intervalSinceNow:newmatnRec.UploadTime];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)enabledField
{
    if (self.servicetime_field.text.length > 0) {
        self.servicetime_field.enabled = NO;
    }
    if (self.servicetime2_field.text.length > 0) {
        self.servicetime2_field.enabled = NO;
    }
    if (self.servicetime3_field.text.length > 0) {
        self.servicetime3_field.enabled = NO;
    }
    if ([self.servcetype_field.text isEqualToString:@"年4次保养"]) {
        self.serviceproject_field.enabled = NO;
    }
}

- (void)initField:(UITextField *)textField
{
    if ([self.servcetype_field.text isEqualToString:@"异常处理"])
    {
        serviceProjects = @[@"燃烧机",@"真空",@"电器控制",@"水系统",@"其它"];
        self.imgCollectionView.hidden = NO;
    }
    else if([self.servcetype_field.text isEqualToString:@"巡视"])
    {
        serviceProjects = @[@"巡视"];
        self.imgCollectionView.hidden = NO;
    }
    else if ([self.servcetype_field.text isEqualToString:@"机房管理"])
    {
        serviceProjects = @[@"机房管理"];
        self.imgCollectionView.hidden = NO;
    }
}

- (double)intervalSinceNow: (NSString *) theDate
{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        //        timeString = [timeString substringToIndex:timeString.length-7];
        return [timeString doubleValue];
    }
    return -1;
}

-(void) bindData
{
    if ([newmatnRec.Project isEqualToString:@"年1次保养"])
    {
        //        self.img1_label.text = @"蒸发器";
        //        self.img2_label.text = @"吸收器、冷凝器";
        //        self.img3_label.text = @"真空泵极限值";
        //        self.img4_label.text = @"售后服务单";
        //        self.img5_label.text = @"主体真空值";
        //        self.img6_label.text = @"最大燃烧量";
        //        self.img7_label.text = @"最小燃烧量";
        self.img1_label.text = @"蒸发器";
        self.img2_label.text = @"吸收器、冷凝器";
        self.img3_label.text = @"真空泵极限值";
        self.img4_label.text = @"主体真空值";
        self.img5_label.text = @"最大燃烧量(O2)";
        self.img6_label.text = @"最小燃烧量(O2)";
        self.img7_label.text = @"售后服务单";
        self.img8_view.hidden = YES;
        self.img9_view.hidden = YES;
        self.img10_view.hidden = YES;
        self.img11_view.hidden = YES;
        self.img12_view.hidden = YES;
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.self.imgContain_view.frame.origin.y + self.self.img7_view.frame.origin.y + self.img7_view.frame.size.height);
        
        CGRect viewFrame = self.imgContain_view.frame;
        viewFrame.size.height = self.img7_view.frame.origin.y + self.img7_view.frame.size.height;
        self.imgContain_view.frame = viewFrame;
        
    }
    else if ([newmatnRec.Project isEqualToString:@"年2次保养"])
    {
        self.img1_label.text = @"真空泵极限值";
        self.img2_label.text = @"烟管";
        self.img3_label.text = @"主体真空值";
        self.img4_label.text = @"高发真空值";
        self.img5_label.text = @"燃料过滤器清洗";
        self.img6_label.text = @"软水器";
        self.img7_label.text = @"三级保护靶片长度";
        self.img8_label.text = @"冷却塔检查";
        self.img9_label.text = @"售后服务单";
        self.img10_view.hidden = YES;
        self.img11_view.hidden = YES;
        self.img12_view.hidden = YES;
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.self.imgContain_view.frame.origin.y + self.self.img9_view.frame.origin.y + self.img9_view.frame.size.height);
        
        CGRect viewFrame = self.imgContain_view.frame;
        viewFrame.size.height = self.img9_view.frame.origin.y + self.img9_view.frame.size.height;
        self.imgContain_view.frame = viewFrame;
        
    }
    else if ([newmatnRec.Project isEqualToString:@"年3次保养"])
    {
        self.img1_label.text = @"真空泵极限值";
        self.img2_label.text = @"主体真空值";
        self.img3_label.text = @"最大燃烧量(O2)";
        self.img4_label.text = @"最小燃烧量(O2)";
        self.img5_label.text = @"冷却塔填料";
        self.img6_label.text = @"售后服务单";
        self.img7_view.hidden = YES;
        self.img8_view.hidden = YES;
        self.img9_view.hidden = YES;
        self.img10_view.hidden = YES;
        self.img11_view.hidden = YES;
        self.img12_view.hidden = YES;
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.self.imgContain_view.frame.origin.y + self.self.img6_view.frame.origin.y + self.img6_view.frame.size.height);
        
        CGRect viewFrame = self.imgContain_view.frame;
        viewFrame.size.height = self.img6_view.frame.origin.y + self.img6_view.frame.size.height;
        self.imgContain_view.frame = viewFrame;
    }
    else if ([newmatnRec.Project isEqualToString:@"年4次保养"])
    {
        //            self.img1_label.text = @"高发液位";
        //            self.img2_label.text = @"烟管检查";
        //            self.img3_label.text = @"热水器铜管";
        //            self.img4_label.text = @"燃料过滤器清洗";
        //            self.img5_label.text = @"油泵过滤器清洗";
        //            self.img6_label.text = @"雾化盘清理";
        //            self.img7_label.text = @"风轮清理";
        //            self.img8_label.text = @"主机水侧排水";
        //            self.img9_label.text = @"售后服务单";
        self.img1_label.text = @"高发液位";
        self.img2_label.text = @"烟管";
        self.img3_label.text = @"点火电极清理";
        self.img4_label.text = @"燃料过滤器清洗";
        self.img5_label.text = @"火焰探测器清理";
        self.img6_label.text = @"雾化盘清理";
        self.img7_label.text = @"风轮清理";
        self.img8_label.text = @"主机水侧排水";
        self.img9_label.text = @"真空泵极限值";
        self.img10_label.text = @"主体真空值";
        self.img11_label.text = @"高发真空值";
        self.img12_label.text = @"售后服务单";
        
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.imgContain_view.frame.origin.y + self.img12_view.frame.origin.y + self.img12_view.frame.size.height);
        
        CGRect viewFrame = self.imgContain_view.frame;
        viewFrame.size.height = self.img12_view.frame.origin.y + self.img12_view.frame.size.height;
        self.imgContain_view.frame = viewFrame;
        NSLog(@"%f", self.imgContain_view.frame.size.height);
        
        CGRect viewFrame2 = self.view.frame;
        viewFrame2.size.height = self.imgContain_view.frame.origin.y + self.imgContain_view.frame.size.height;
        self.view.frame = viewFrame2;
        NSLog(@"%f", self.view.frame.size.height);
        
    }
    else
    {
        self.imgContain_view.hidden = YES;
        self.imgCollectionView.hidden = NO;
    }
    
    if(newmatnRec.imgList && newmatnRec.imgList.count > 0)
    {
        if([newmatnRec.Type isEqualToString:@"异常处理"] || [newmatnRec.Type isEqualToString:@"巡视"] || [newmatnRec.Type isEqualToString:@"机房管理"])
        {
            self.imgCollectionView.hidden = NO;
            self.imgContain_view.hidden = YES;
            [self reSizeCollectionView];
            [self.imgCollectionView reloadData];
        }
        else
        {
            self.imgContain_view.hidden = NO;
            self.imgCollectionView.hidden = YES;
            [self setImg];
        }
    }
    
    self.enginer_label.text = newmatnRec.Exec_Man;
    self.uploador_label.text = newmatnRec.Uploader;
    self.uploadtime_label.text = newmatnRec.UploadTime;
    self.servcetype_field.text = newmatnRec.Type;
    self.serviceproject_field.text = newmatnRec.Project;
    self.chucang_no_label.text = newmatnRec.OutFact_Num;
    self.engine_no_label.text = newmatnRec.AirCondUnit_Mode;
    
    if (newmatnRec.Exec_Date.length > 0)
    {
        
        NSString *timeStr = newmatnRec.Exec_Date;
        if([newmatnRec.Exec_Date rangeOfString:@" "].length > 0)
        {
            timeStr = [newmatnRec.Exec_Date substringToIndex:[newmatnRec.Exec_Date rangeOfString:@" "].location];
        }
        self.servicetime_field.text = timeStr;
    }
    if (newmatnRec.Exec_Date01 && newmatnRec.Exec_Date01.length > 0 && ![newmatnRec.Exec_Date01 isEqualToString:@"null"])
    {
        NSString *timeStr = newmatnRec.Exec_Date01;
        if([newmatnRec.Exec_Date01 rangeOfString:@" "].length > 0)
        {
            timeStr = [newmatnRec.Exec_Date01 substringToIndex:[newmatnRec.Exec_Date01 rangeOfString:@" "].location];
        }
        self.servicetime2_field.text = timeStr;
    }
    if (newmatnRec.Exec_Date02.length > 0)
    {
        NSString *timeStr = newmatnRec.Exec_Date02;
        if([newmatnRec.Exec_Date02 rangeOfString:@" "].length > 0)
        {
            timeStr = [newmatnRec.Exec_Date02 substringToIndex:[newmatnRec.Exec_Date02 rangeOfString:@" "].location];
        }
        self.servicetime3_field.text = timeStr;
    }
}

-(void) setImg
{
    int index = 0;
    if (newmatnRec.allfilename.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        if(img.Url && img.Url.length > 0)
        {
            [self.img1_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        }
        else
        {
            [self.img1_ImgView setImage:img.img];
        }
        
        self.img1_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename02.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        if(img.Url && img.Url.length > 0)
        {
            [self.img2_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        }
        else
        {
            [self.img2_ImgView setImage:img.img];
        }
        self.img2_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename03.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        
        if(img.Url && img.Url.length > 0)
        {
            [self.img3_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        }
        else
        {
            [self.img3_ImgView setImage:img.img];
        }
        self.img3_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename04.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img7_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img7_ImgView setImage:img.img];
            }
        }
        else
        {
            if(img.Url && img.Url.length > 0)
            {
                [self.img4_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img4_ImgView setImage:img.img];
            }
        }
        
        self.img4_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename05.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        
        if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img4_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img4_ImgView setImage:img.img];
            }
        }
        else
        {
            if(img.Url && img.Url.length > 0)
            {
                [self.img5_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img5_ImgView setImage:img.img];
            }
        }
        self.img5_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename06.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        
        if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img5_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img5_ImgView setImage:img.img];
            }
        }
        else
        {
            if(img.Url && img.Url.length > 0)
            {
                [self.img6_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img6_ImgView setImage:img.img];
            }
        }
        self.img6_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename07.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        
        if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img6_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img6_ImgView setImage:img.img];
            }
        }
        else
        {
            if(img.Url && img.Url.length > 0)
            {
                [self.img7_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img7_ImgView setImage:img.img];
            }
        }
        self.img7_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename08.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        
        if ([self.matnRec.Project isEqualToString:@"年2次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img9_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img9_ImgView setImage:img.img];
            }
        }
        else
        {
            if(img.Url && img.Url.length > 0)
            {
                [self.img8_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img8_ImgView setImage:img.img];
            }
        }
        self.img8_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename09.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        
        if ([self.matnRec.Project isEqualToString:@"年2次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img8_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img8_ImgView setImage:img.img];
            }
        }
        else if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img12_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img12_ImgView setImage:img.img];
            }
        }
        else
        {
            if(img.Url && img.Url.length > 0)
            {
                [self.img9_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img9_ImgView setImage:img.img];
            }
        }
        self.img9_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename10.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        
        if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img9_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img9_ImgView setImage:img.img];
            }
        }
        else
        {
            if(img.Url && img.Url.length > 0)
            {
                [self.img10_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img10_ImgView setImage:img.img];
            }
        }
        self.img10_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename11.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        
        if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img10_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img10_ImgView setImage:img.img];
            }
        }
        else
        {
            if(img.Url && img.Url.length > 0)
            {
                [self.img11_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img11_ImgView setImage:img.img];
            }
        }
        self.img11_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
    if (newmatnRec.allfilename12.length > 0)
    {
        Img *img = newmatnRec.imgList[index];
        
        if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
            if(img.Url && img.Url.length > 0)
            {
                [self.img11_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img11_ImgView setImage:img.img];
            }
        }
        else
        {
            if(img.Url && img.Url.length > 0)
            {
                [self.img12_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
            }
            else
            {
                [self.img12_ImgView setImage:img.img];
            }
        }
        self.img12_ImgView.tag = index;
        ++index;
        if (index >= newmatnRec.imgList.count)
        {
            return;
        }
    }
}

- (void)add
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    NSString *type = self.servcetype_field.text;
    NSString *project = self.serviceproject_field.text;
    NSString *time = self.servicetime_field.text;
    NSString *no = self.engine_no_label.text;
    if (type.length == 0)
    {
        hud.hidden = YES;
        [Tool showCustomHUD:@"请选择服务类型" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (project.length == 0)
    {
        hud.hidden = YES;
        [Tool showCustomHUD:@"请选择服务项目" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (time.length == 0)
    {
        hud.hidden = YES;
        [Tool showCustomHUD:@"请选择服务时间" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (no.length == 0)
    {
        hud.hidden = YES;
        [Tool showCustomHUD:@"请选择机组" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //    [self updateImg];
    //异步请求启动文件上传及后续写库操作！SQL无意义，只为启动提示稍后
    NSString *sql = @"select getdate() ";
    
    [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self updateImg];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self updateImg];
     }];
    
}

- (void)updateImg
{
    if([self.servcetype_field.text isEqualToString:@"年4次保养"])
    {
        for(NSString *key in imgDic)
        {
            UIImage *img = imgDic[key];
            
            if(img)
            {
                int y = (arc4random() % 501) + 500;
                
                NSString *project = self.serviceproject_field.text;
                
                if([key isEqualToString:@"1"])
                {
                    project = self.img1_label.text;
                }
                else if([key isEqualToString:@"2"])
                {
                    project = self.img2_label.text;
                }
                else if([key isEqualToString:@"3"])
                {
                    project = self.img3_label.text;
                }
                else if([key isEqualToString:@"4"])
                {
                    if ([self.serviceproject_field.text isEqualToString:@"年1次保养"])
                    {
                        project = self.img7_label.text;
                    }
                    else
                    {
                        project = self.img4_label.text;
                    }
                }
                else if([key isEqualToString:@"5"])
                {
                    if ([self.serviceproject_field.text isEqualToString:@"年1次保养"])
                    {
                        project = self.img4_label.text;
                    }
                    else
                    {
                        project = self.img5_label.text;
                    }
                }
                else if([key isEqualToString:@"6"])
                {
                    if ([self.serviceproject_field.text isEqualToString:@"年1次保养"])
                    {
                        project = self.img5_label.text;
                    }
                    else
                    {
                        project = self.img6_label.text;
                    }
                }
                else if([key isEqualToString:@"7"])
                {
                    if ([self.serviceproject_field.text isEqualToString:@"年1次保养"])
                    {
                        project = self.img6_label.text;
                    }
                    else
                    {
                        project = self.img7_label.text;
                    }
                }
                else if([key isEqualToString:@"8"])
                {
                    if ([self.serviceproject_field.text isEqualToString:@"年2次保养"])
                    {
                        project = self.img9_label.text;
                    }
                    else
                    {
                        project = self.img8_label.text;
                    }
                }
                else if([key isEqualToString:@"9"])
                {
                    if ([self.serviceproject_field.text isEqualToString:@"年2次保养"])
                    {
                        project = self.img8_label.text;
                    }
                    else if ([self.serviceproject_field.text isEqualToString:@"年4次保养"])
                    {
                        project = self.img12_label.text;
                    }
                    else
                    {
                        project = self.img9_label.text;
                    }
                }
                else if([key isEqualToString:@"10"])
                {
                    if ([self.serviceproject_field.text isEqualToString:@"年4次保养"])
                    {
                        project = self.img9_label.text;
                    }
                    else
                    {
                        project = self.img10_label.text;
                    }
                }
                else if([key isEqualToString:@"11"])
                {
                    if ([self.serviceproject_field.text isEqualToString:@"年4次保养"])
                    {
                        project = self.img10_label.text;
                    }
                    else
                    {
                        project = self.img11_label.text;
                    }
                }
                else if([key isEqualToString:@"12"])
                {
                    if ([self.serviceproject_field.text isEqualToString:@"年4次保养"])
                    {
                        project = self.img11_label.text;
                    }
                    else
                    {
                        project = self.img12_label.text;
                    }
                }
                NSString *reName = [NSString stringWithFormat:@"%@%@%i.jpg",project,[Tool getCurrentTimeStr:@"yyyy-MM-dd-HHmmss"],y];
                
                BOOL isOK = [self upload:img oldName:reName Index:[key intValue]];
                if(!isOK)
                {
                    [Tool showCustomHUD:@"图片上传失败..." andView:self.view andImage:nil andAfterDelay:1.2f];
                    return;
                }
            }
        }
    }
    else
    {
        //跳过第一个
        for(int i = 1; i < newmatnRec.imgList.count; ++i)
        {
            Img *img = newmatnRec.imgList[i];
            if(img.img)
            {
                int y = (arc4random() % 501) + 500;
                
                NSString *reName = [NSString stringWithFormat:@"%@%@%i.jpg",self.serviceproject_field.text,[Tool getCurrentTimeStr:@"yyyy-MM-dd-HHmmss"],y];
                BOOL isOK = [self upload:img.img oldName:reName Index:-1];
                if(!isOK)
                {
                    [Tool showCustomHUD:@"图片上传失败..." andView:self.view andImage:nil andAfterDelay:1.2f];
                    return;
                }
            }
        }
    }
    if(deleteImgStr.length > 0)
    {
        [self deleteImg];
    }
    
    [self insertData];
}

- (void)deleteImg
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DeleteMultFile",api_base_url]]];
    
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:deleteImgStr forKey:@"fileNames"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        XMLParserUtils *utils = [[XMLParserUtils alloc] init];
        utils.parserFail = ^()
        {
        };
        utils.parserOK = ^(NSString *string)
        {
        };
        
        [utils stringFromparserXML:response target:@"string"];
    }
}

- (BOOL)upload:(UIImage *)img oldName : (NSString *)reName Index:(NSInteger)index;
{
    static BOOL isOK = NO;
    if(img)
    {
        //        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[Tool generateTradeNO]];
        int y = (arc4random() % 501) + 500;
        NSString *fileName = [NSString stringWithFormat:@"%@%i.jpg",[Tool getCurrentTimeStr:@"yyyyMMddHHmmss"],y];
        
        NSString *base64Encoded = [UIImageJPEGRepresentation(img,0.8f) base64EncodedStringWithOptions:0];
        
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@UploadFile",api_base_url]]];
        
        [request setUseCookiePersistence:NO];
        [request setTimeOutSeconds:30];
        
        [request setPostValue:fileName forKey:@"fileName"];
        [request setPostValue:base64Encoded forKey:@"fileBytes"];
        [request setDefaultResponseEncoding:NSUTF8StringEncoding];
        [request startSynchronous];
        
        NSError *error = [request error];
        if (!error)
        {
            NSString *response = [request responseString];
            XMLParserUtils *utils = [[XMLParserUtils alloc] init];
            utils.parserFail = ^()
            {
                isOK = NO;
            };
            utils.parserOK = ^(NSString *string)
            {
                AppDelegate *app = [[UIApplication sharedApplication] delegate];
                NSString *sql = [NSString stringWithFormat:@"insert into ERPSaveFileName(NowName,OldName,Uploader,UploadTime,FileUrl) values('%@','%@','%@',getdate(),'%@')",fileName,reName,app.userinfo.UserName,string];
                ASIFormDataRequest *tworequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
                [tworequest setUseCookiePersistence:NO];
                [tworequest setTimeOutSeconds:30];
                [tworequest setDelegate:self];
                [tworequest setPostValue:sql forKey:@"sqlstr"];
                [tworequest setDefaultResponseEncoding:NSUTF8StringEncoding];
                [tworequest startSynchronous];
                
                NSError *error = [request error];
                if (!error)
                {
                    NSString *response = [tworequest responseString];
                    if([response rangeOfString:@"true"].length > 0)
                    {
                        isOK = YES;
                        haveUploadImage = YES;
                        if ([self.servcetype_field.text isEqualToString:@"年4次保养"])
                        {
                            switch (index)
                            {
                                case 1:
                                    newmatnRec.allfilename = [NSMutableString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 2:
                                    newmatnRec.allfilename02 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 3:
                                    newmatnRec.allfilename03 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 4:
                                    newmatnRec.allfilename04 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 5:
                                    newmatnRec.allfilename05 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 6:
                                    newmatnRec.allfilename06 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 7:
                                    newmatnRec.allfilename07 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 8:
                                    newmatnRec.allfilename08 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 9:
                                    newmatnRec.allfilename09 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 10:
                                    newmatnRec.allfilename10 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 11:
                                    newmatnRec.allfilename11 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 12:
                                    newmatnRec.allfilename12 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                            }
                        }
                        else
                        {
                            if(newsAllfilename == nil || [newsAllfilename isEqualToString:@"null"])
                            {
                                newsAllfilename = @"";
                            }
                            newmatnRec.allfilename = [NSString stringWithFormat:@"%@|%@",newmatnRec.allfilename,fileName];
                            newsAllfilename = [NSString stringWithFormat:@"%@|%@",newsAllfilename,fileName];
                            newsAllfilename = [newsAllfilename stringByReplacingOccurrencesOfString:@"null" withString:@""];
                        }
                    }
                }
            };
            
            [utils stringFromparserXML:response target:@"string"];
        }
    }
    
    return isOK;
}

- (void)insertData
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    NSString *time1 = self.servicetime2_field.text.length > 0?[NSString stringWithFormat:@"'%@'",self.servicetime2_field.text]:@"null";
    NSString *time2 = self.servicetime3_field.text.length > 0?[NSString stringWithFormat:@"'%@'",self.servicetime3_field.text]:@"null";
    if (haveUploadImage) {
        self.uploadtime_label.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
//        self.matnRec.UploadTime = self.uploadtime_label.text;
    }
    NSString *sql = @"";
    if ([newmatnRec.Type isEqualToString:@"年4次保养"]) {
        sql = [NSString stringWithFormat:@"update TB_CUST_ProjInf_MatnRec set UploadTime='%@', AirCondUnit_Mode='%@',OutFact_Num='%@',Exec_Date='%@', Exec_Date01=%@,Exec_Date02=%@,Type='%@',Project='%@',allfilename='%@',allfilename02='%@',allfilename03='%@',allfilename04='%@',allfilename05='%@',allfilename06='%@',allfilename07='%@',allfilename08='%@',allfilename09='%@',allfilename10='%@',allfilename11='%@',allfilename12='%@' where ID='%@'",self.uploadtime_label.text,self.engine_no_label.text,self.chucang_no_label.text,self.servicetime_field.text,time1,time2,self.servcetype_field.text,self.serviceproject_field.text,newmatnRec.allfilename,newmatnRec.allfilename02,newmatnRec.allfilename03,newmatnRec.allfilename04,newmatnRec.allfilename05,newmatnRec.allfilename06,newmatnRec.allfilename07,newmatnRec.allfilename08,newmatnRec.allfilename09,newmatnRec.allfilename10,newmatnRec.allfilename11,newmatnRec.allfilename12,newmatnRec.ID];
    }
    else
    {
        sql = [NSString stringWithFormat:@"update TB_CUST_ProjInf_MatnRec set AirCondUnit_Mode='%@',OutFact_Num='%@',Exec_Date='%@', Exec_Date01=%@,Exec_Date02=%@,Type='%@',Project='%@',allfilename='%@',allfilename02='%@',allfilename03='%@',allfilename04='%@',allfilename05='%@',allfilename06='%@',allfilename07='%@',allfilename08='%@',allfilename09='%@',allfilename10='%@',allfilename11='%@',allfilename12='%@' where ID='%@'",self.engine_no_label.text,self.chucang_no_label.text,self.servicetime_field.text,time1,time2,self.servcetype_field.text,self.serviceproject_field.text,newsAllfilename,newmatnRec.allfilename02,newmatnRec.allfilename03,newmatnRec.allfilename04,newmatnRec.allfilename05,newmatnRec.allfilename06,newmatnRec.allfilename07,newmatnRec.allfilename08,newmatnRec.allfilename09,newmatnRec.allfilename10,newmatnRec.allfilename11,newmatnRec.allfilename12,newmatnRec.ID];
        if([newsAllfilename isEqualToString:@"null"])
        {
            sql = [NSString stringWithFormat:@"update TB_CUST_ProjInf_MatnRec set AirCondUnit_Mode='%@',OutFact_Num='%@',Exec_Date='%@', Exec_Date01=%@,Exec_Date02=%@,Type='%@',Project='%@',allfilename=%@,allfilename02='%@',allfilename03='%@',allfilename04='%@',allfilename05='%@',allfilename06='%@',allfilename07='%@',allfilename08='%@',allfilename09='%@',allfilename10='%@',allfilename11='%@',allfilename12='%@' where ID='%@'",self.engine_no_label.text,self.chucang_no_label.text,self.servicetime_field.text,time1,time2,self.servcetype_field.text,self.serviceproject_field.text,newsAllfilename,newmatnRec.allfilename02,newmatnRec.allfilename03,newmatnRec.allfilename04,newmatnRec.allfilename05,newmatnRec.allfilename06,newmatnRec.allfilename07,newmatnRec.allfilename08,newmatnRec.allfilename09,newmatnRec.allfilename10,newmatnRec.allfilename11,newmatnRec.allfilename12,newmatnRec.ID];
            newsAllfilename = @"";
        }
    }
    
    sql = [sql stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        XMLParserUtils *utils = [[XMLParserUtils alloc] init];
        utils.parserFail = ^()
        {
            [Tool showCustomHUD:@"保存失败" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        };
        utils.parserOK = ^(NSString *string)
        {
            [Tool showCustomHUD:@"保存成功" andView:self.view andImage:nil andAfterDelay:1.2f];
            newmatnRec.UploadTime = self.uploadtime_label.text;
            newmatnRec.Exec_Date = self.servicetime_field.text;
            newmatnRec.Exec_Date01 = self.servicetime2_field.text;
            newmatnRec.Exec_Date02 = self.servicetime3_field.text;
            newmatnRec.AirCondUnit_Mode = self.engine_no_label.text;
            newmatnRec.OutFact_Num = self.chucang_no_label.text;
            newmatnRec.Type = self.servcetype_field.text;
            newmatnRec.Project = self.serviceproject_field.text;
            if([newmatnRec.Type isEqualToString:@"异常处理"] || [newmatnRec.Type isEqualToString:@"巡视"] || [newmatnRec.Type isEqualToString:@"机房管理"])
            {
                newmatnRec.allfilename = newsAllfilename;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notifire" object:nil userInfo:[NSDictionary dictionaryWithObject:newmatnRec forKey:@"matnRec"]];
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_WeiXiuListReLoad" object:nil];
            
            [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
        };
        
        [utils stringFromparserXML:response target:@"string"];
    }
}

//机组选择
- (void)enginChoice
{
    [SGActionView showSheetWithTitle:@"请选择机组:"
                          itemTitles:enginUnitModeArray
                       itemSubTitles:enginUnitNoArray
                       selectedIndex:selectedEnginIndex
                      selectedHandle:^(NSInteger index){
                          selectedEnginIndex = index;
                          EnginUnit *unit = [enginUnitArray objectAtIndex:index];
                          self.chucang_no_label.text = unit.OutFact_Num;
                          self.engine_no_label.text = unit.AirCondUnit_Mode;
                      }];
}

//服务类型、项目、时间等输入框不允许弹出输入法界面
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //服务类型
    if(textField.tag == 1)
    {
        if([newmatnRec.Type isEqualToString:@"年4次保养"])
        {
            [Tool showCustomHUD:@"年4次保养不允许修改类型" andView:self.view andImage:nil andAfterDelay:1.2f];
            return NO;
        }
        NSArray *items = @[@"异常处理",@"巡视",@"机房管理"];
        [SGActionView showSheetWithTitle:@"请选择服务类型:"
                              itemTitles:items
                           itemSubTitles:nil
                           selectedIndex:selectedServiceTypeIndex
                          selectedHandle:^(NSInteger index){
                              selectedServiceTypeIndex = index;
                              
                              textField.text = items[index];
                              
                              //异常处理
                              if (index == 0)
                              {
                                  self.imgContain_view.hidden = YES;
                                  self.serviceproject_field.enabled = YES;
                                  self.serviceproject_field.text = @"燃烧机";
                                  self.servcetype_field.text = @"异常处理";
                                  serviceProjects = @[@"燃烧机",@"真空",@"电器控制",@"水系统",@"其它"];
                                  
                                  self.imgCollectionView.hidden = NO;
                              }
                              //巡视
                              else if (index == 1)
                              {
                                  self.imgContain_view.hidden = YES;
                                  self.serviceproject_field.enabled = YES;
                                  self.serviceproject_field.text = @"巡视";
                                  self.servcetype_field.text = @"巡视";
                                  serviceProjects = @[@"巡视"];
                                  self.imgCollectionView.hidden = NO;
                              }
                              //机房管理
                              else if (index == 2)
                              {
                                  self.imgContain_view.hidden = YES;
                                  
                                  self.serviceproject_field.enabled = YES;
                                  self.serviceproject_field.text = @"机房管理";
                                  self.servcetype_field.text = @"机房管理";
                                  serviceProjects = @[@"机房管理"];
                                  self.imgCollectionView.hidden = NO;
                              }
                          }];
    }
    else if(textField.tag == 2)
    {
        if(self.servcetype_field.text.length == 0)
        {
            [Tool showCustomHUD:@"请先选择服务类型" andView:self.view andImage:nil andAfterDelay:1.2f];
            return NO;
        }
        
        [SGActionView showSheetWithTitle:@"请选择服务项目:"
                              itemTitles:serviceProjects
                           itemSubTitles:nil
                           selectedIndex:selectedServiceNameIndex
                          selectedHandle:^(NSInteger index){
                              selectedServiceNameIndex = index;
                              self.serviceproject_field.text = serviceProjects[index];
                          }];
    }
    else if(textField.tag == 3)
    {
        if(self.serviceproject_field.text.length == 0)
        {
            [Tool showCustomHUD:@"请先选择服务项目" andView:self.view andImage:nil andAfterDelay:1.2f];
            return NO;
        }
        HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
        selectTimeIndex = textField.tag;
        hsdpvc.delegate = self;
        if (serviceDate)
        {
            hsdpvc.date = serviceDate;
        }
        [self presentViewController:hsdpvc animated:YES completion:nil];
    }
    else if(textField.tag == 4 || textField.tag == 5)
    {
        HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
        selectTimeIndex = textField.tag;
        hsdpvc.delegate = self;
        if (serviceDate)
        {
            hsdpvc.date = serviceDate;
        }
        [self presentViewController:hsdpvc animated:YES completion:nil];
    }
    return NO;
}

#pragma mark - 动态调整scrollView的高度
- (void)reSizeCollectionView
{
    //这里根据小区个数自动调整高度
    NSInteger size = (newmatnRec.imgList.count)/3;
    
    NSInteger height = 0;
    if(size < 1)
    {
        height = 200;
    }
    else
    {
        height = size * 85 + 220;
    }
    
    float x = self.imgCollectionView.frame.origin.x;
    float y = self.imgCollectionView.frame.origin.y;
    float width = self.imgCollectionView.frame.size.width;
    self.imgCollectionView.hidden = NO;
    //调整网格布局高度
    self.imgCollectionView.frame = CGRectMake(x, y, width, height);
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.imgCollectionView.frame.origin.y + self.imgCollectionView.frame.size.height + 10);
//    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y,self.scrollView.frame.size.width, self.imgCollectionView.frame.origin.y + self.imgCollectionView.frame.size.height + 10);
}

#pragma mark - 图片集合
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger count = newmatnRec.imgList.count;
    return count;
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
    
    Img *img = [newmatnRec.imgList objectAtIndex:[indexPath row]];
    
    if(img.img)
    {
        [cell.repairImg setImage:img.img];
    }
    else
    {
        [cell.repairImg sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
    }
    cell.repairImg.frame = CGRectMake(0, 0, 85, 85);
    
    
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


//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexRow = [indexPath row];
    if(indexRow == 0)
    {
        UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        choiceSheet.tag = -1;
        selectPicIndex = -1;
        [choiceSheet showInView:self.view];
    }
    else
    {
        if (timeCha > 1.0) {
            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
        alert.tag = indexPath.row;
        [alert show];
    }
}

#pragma mark - HSDatePickerViewControllerDelegate
- (void)hsDatePickerPickedDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *targetDate = [dateFormatter stringFromDate:date];
    NSDateComponents *datec = [Tool getCurrentYear_Month_Day];
    NSInteger year = [datec year];
    
    //2016年底修改为:服务时间小于等于当前时间
    NSString *now = [dateFormatter stringFromDate:[[NSDate alloc] init]];
    
//    NSString *uploadTimeStr = [self.uploadtime_label.text substringToIndex:[self.uploadtime_label.text rangeOfString:@" "].location];
    
    if ([self.servcetype_field.text isEqualToString:@"年4次保养"])
    {
        NSString *start = nil;
        NSString *end = nil;
        
//        if ([self.serviceproject_field.text isEqualToString:@"年1次保养"])
//        {
//            start = [NSString stringWithFormat:@"%li-01-01",(long)year];
//            end = [NSString stringWithFormat:@"%li-04-01",(long)year];
//        }
//        else if ([self.serviceproject_field.text isEqualToString:@"年2次保养"])
//        {
//            start = [NSString stringWithFormat:@"%li-04-01",(long)year];
//            end = [NSString stringWithFormat:@"%li-07-01",(long)year];
//        }
//        else if ([self.serviceproject_field.text isEqualToString:@"年3次保养"])
//        {
//            start = [NSString stringWithFormat:@"%li-07-01",(long)year];
//            end = [NSString stringWithFormat:@"%li-10-01",(long)year];
//        }
//        else if ([self.serviceproject_field.text isEqualToString:@"年4次保养"])
//        {
//            start = [NSString stringWithFormat:@"%li-10-01",(long)year];
//            end = [NSString stringWithFormat:@"%li-01-01",(long)year+1];
//        }
        
        NSString *currentMonthDayStr = [Tool getCurrentTimeStr:@"MMdd"];
        long currentMonthDayLong = [currentMonthDayStr longLongValue];
        
        if ([self.serviceproject_field.text isEqualToString:@"年1次保养"])
        {
            if(currentMonthDayLong >= 1226)
            {
                start = [NSString stringWithFormat:@"%li-12-26",year];
                end = [NSString stringWithFormat:@"%li-03-25",year + 1];
            }
            else if (currentMonthDayLong <= 0325)
            {
                start = [NSString stringWithFormat:@"%li-12-26",year - 1];
                end = [NSString stringWithFormat:@"%li-03-25",year];
            }
        }
        else if ([self.serviceproject_field.text isEqualToString:@"年2次保养"])
        {
            start = [NSString stringWithFormat:@"%li-03-26",year];
            end = [NSString stringWithFormat:@"%li-06-25",year];
        }
        else if ([self.serviceproject_field.text isEqualToString:@"年3次保养"])
        {
            start = [NSString stringWithFormat:@"%li-06-26",year];
            end = [NSString stringWithFormat:@"%li-09-25",year];
        }
        else if ([self.serviceproject_field.text isEqualToString:@"年4次保养"])
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
                if(selectTimeIndex == 4)
                {
                    int tag = [Tool compareOneDay:targetDate withAnotherDay:now];
                    //如果为0则两个日期相等,如果为1则服务时间大于起始时间
                    if(tag == 0 || tag == -1)
                    {
                        self.servicetime2_field.text = targetDate;
                    }
                    else
                    {
                        [Tool showCustomHUD:@"服务时间 <= 上传时间" andView:self.view andImage:nil andAfterDelay:1.2f];
                        return;
                    }
                }
                else if(selectTimeIndex == 5)
                {
                    int tag = [Tool compareOneDay:targetDate withAnotherDay:now];
                    //如果为0则两个日期相等,如果为1则服务时间大于起始时间
                    if(tag == 0 || tag == -1)
                    {
                        self.servicetime3_field.text = targetDate;
                    }
                    else
                    {
                        [Tool showCustomHUD:@"服务时间 <= 上传时间" andView:self.view andImage:nil andAfterDelay:1.2f];
                        return;
                    }
                }
                else
                {
                    self.servicetime_field.text = targetDate;
                }
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示:" message:[NSString stringWithFormat:@"服务时间必须在%@到%@之间",start,end] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                alertView.tag = -10;
                [alertView show];
                return;
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示:" message:[NSString stringWithFormat:@"服务时间必须在%@到%@之间",start,end] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertView.tag = -10;
            [alertView show];
            return;
        }
    }
    else
    {
        int tag1 = [Tool compareOneDay:targetDate withAnotherDay:now];
        //如果为0则两个日期相等,如果为-1则服务时间小于于起始时间
        if(tag1 == 0 || tag1 == -1)
        {
            if(selectTimeIndex == 4)
            {
                
                int tag = [Tool compareOneDay:targetDate withAnotherDay:now];
                //如果为0则两个日期相等,如果为1则服务时间大于起始时间
                if(tag == 0 || tag == -1)
                {
                    self.servicetime2_field.text = targetDate;
                }
                else
                {
                    [Tool showCustomHUD:@"服务时间 <= 上传时间" andView:self.view andImage:nil andAfterDelay:1.2f];
                    return;
                }
                
            }
            else if(selectTimeIndex == 5)
            {
                int tag = [Tool compareOneDay:targetDate withAnotherDay:now];
                //如果为0则两个日期相等,如果为1则服务时间大于起始时间
                if(tag == 0 || tag == -1)
                {
                    self.servicetime3_field.text = targetDate;
                }
                else
                {
                    [Tool showCustomHUD:@"服务时间 <= 上传时间" andView:self.view andImage:nil andAfterDelay:1.2f];
                    return;
                }
            }
        }
        else
        {
            [Tool showCustomHUD:@"服务时间 <= 上传时间" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
    }
    serviceDate = date;
}
//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker did dismiss with %lu", (unsigned long)method);
    if(method == 1)
    {
        if (selectTimeIndex == 4)
        {
            self.servicetime2_field.text = @"";;
        }
        else if (selectTimeIndex == 5)
        {
            self.servicetime3_field.text = @"";;
        }
    }
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker will dismiss with %lu", (unsigned long)method);
}

- (void)initData
{
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sql = [NSString stringWithFormat:@"select * From Tb_CUST_ProjInf_AirCondUnit Where PROJ_ID='%@'",app.depart.PROJ_ID];
    [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
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
             
             enginUnitArray = [Tool readJsonToObjArray:table andObjClass:[EnginUnit class]];
             if(enginUnitArray && enginUnitArray.count > 0)
             {
                 enginUnitNoArray = [[NSMutableArray alloc] init];
                 enginUnitModeArray = [[NSMutableArray alloc] init];
                 for(EnginUnit *engin in enginUnitArray)
                 {
                     [enginUnitNoArray addObject:[NSString stringWithFormat:@"出厂编号:%@",engin.OutFact_Num ]];
                     [enginUnitModeArray addObject:[NSString stringWithFormat:@"机组型号:%@",engin.AirCondUnit_Mode ]];
                 }
                 [[AFOSCClient  sharedClient] getPath:[NSString stringWithFormat:@"%@GetNowDateTime",api_base_url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
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
                          hud.hidden = YES;
                          NSString *timeStr = [string substringToIndex:[string rangeOfString:@" "].location];
                          //                          self.uploadtime_label.text = timeStr;
                      };
                      
                      [utils stringFromparserXML:operation.responseString target:@"string"];
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                  {
                      hud.hidden = YES;
                      [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                      [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                      
                  }];
             }
             else
             {
                 hud.hidden = YES;
                 [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                 [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
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

- (void)checkImgUploadTime:(NSString *)fileName andImgTag:(NSInteger )imgTag
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url]]];
    
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"|" withString:@""];

    NSString *sql = [NSString stringWithFormat:@"SELECT ROW_NUMBER() OVER (ORDER BY UploadTime desc) AS ROWID,ID,OldName,UploadTime,NowName,IsMany,UploadUser =Case when Uploader is null Then '' Else Uploader End FROM ERPSaveFileName where NowName in ('%@')", fileName];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        XMLParserUtils *utils = [[XMLParserUtils alloc] init];
        utils.parserFail = ^()
        {
            [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
        };
        utils.parserOK = ^(NSString *string)
        {
            NSError *error;
            NSLog(@"%@",string);
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (array && array.count > 0) {
                NSDictionary *dic = array[0];
                NSString *uploadTime = [dic objectForKey:@"UploadTime"];
                double uploadTimeCha = [self intervalSinceNow:uploadTime];
                if (uploadTimeCha > 1.0) {
                    [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
                    return;
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
                alert.tag = imgTag;
                [alert show];
            }
        };
//        NSLog(@"%@", response);
        [utils stringFromparserXML:response target:@"string"];
    }
}

- (void)imgChoiceAction1
{
    targetImg = self.img1_ImgView;
    targetImg.tag = 1;
    //如果存在图片
    if((newmatnRec.allfilename && newmatnRec.allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:newmatnRec.allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改", @"删除图片", nil];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img1_ImgView.tag;
//        [alert show];
        
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        selectPicIndex = self.img1_ImgView.tag;
        
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction2
{
    targetImg = self.img2_ImgView;
    targetImg.tag = 2;
    //如果存在图片
    if((newmatnRec.allfilename02 && newmatnRec.allfilename02.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:newmatnRec.allfilename02 andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img2_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img2_ImgView.tag;
        selectPicIndex = self.img2_ImgView.tag;
        
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction3
{
    targetImg = self.img3_ImgView;
    targetImg.tag = 3;
    //如果存在图片
    if((newmatnRec.allfilename03 && newmatnRec.allfilename03.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:newmatnRec.allfilename03 andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改", @"删除图片", nil];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img3_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img3_ImgView.tag;
        selectPicIndex = self.img3_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction4
{
    targetImg = self.img4_ImgView;
    NSString *allfilename = newmatnRec.allfilename04;
    
    if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
        targetImg.tag = 5;
        allfilename = newmatnRec.allfilename05;
    }
    else{
        targetImg.tag = 4;
    }
    //如果存在图片
    if((allfilename && allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img4_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img4_ImgView.tag;
        selectPicIndex = self.img4_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction5
{
    targetImg = self.img5_ImgView;
    NSString *allfilename = newmatnRec.allfilename05;
    
    if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
        targetImg.tag = 6;
        allfilename = newmatnRec.allfilename06;
    }
    else{
        targetImg.tag = 5;
    }
    //如果存在图片
    if((allfilename && allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img5_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img5_ImgView.tag;
        selectPicIndex = self.img5_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction6
{
    targetImg = self.img6_ImgView;
    NSString *allfilename = newmatnRec.allfilename06;
    
    if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
        targetImg.tag = 7;
        allfilename = newmatnRec.allfilename07;
    }
    else{
        targetImg.tag = 6;
    }
    //如果存在图片
    if((allfilename && allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img6_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img6_ImgView.tag;
        selectPicIndex = self.img6_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction7
{
    targetImg = self.img7_ImgView;
    NSString *allfilename = newmatnRec.allfilename07;
    
    if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
        targetImg.tag = 4;
        allfilename = newmatnRec.allfilename04;
    }
    else{
        targetImg.tag = 7;
    }
    //如果存在图片
    if((allfilename && allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img7_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img7_ImgView.tag;
        selectPicIndex = self.img7_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction8
{
    targetImg = self.img8_ImgView;
    NSString *allfilename = newmatnRec.allfilename08;
    
    if ([self.matnRec.Project isEqualToString:@"年2次保养"]) {
        targetImg.tag = 9;
        allfilename = newmatnRec.allfilename09;
    }
    else{
        targetImg.tag = 8;
    }
    //如果存在图片
    if((allfilename && allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img8_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img8_ImgView.tag;
        selectPicIndex = self.img8_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction9
{
    targetImg = self.img9_ImgView;
    NSString *allfilename = newmatnRec.allfilename09;
    
    if ([self.matnRec.Project isEqualToString:@"年2次保养"]) {
        targetImg.tag = 8;
        allfilename = newmatnRec.allfilename08;
    }
    else if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
        targetImg.tag = 10;
        allfilename = newmatnRec.allfilename10;
    }
    else{
        targetImg.tag = 9;
    }
    //如果存在图片
    if((allfilename && allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img9_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img9_ImgView.tag;
        selectPicIndex = self.img9_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction10
{
    targetImg = self.img10_ImgView;
    NSString *allfilename = newmatnRec.allfilename10;
    
    if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
        targetImg.tag = 11;
        allfilename = newmatnRec.allfilename11;
    }
    else{
        targetImg.tag = 10;
    }
    //如果存在图片
    if((allfilename && allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img10_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img10_ImgView.tag;
        selectPicIndex = self.img10_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction11
{
    targetImg = self.img11_ImgView;
    NSString *allfilename = newmatnRec.allfilename11;
    
    if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
        targetImg.tag = 12;
        allfilename = newmatnRec.allfilename12;
    }
    else{
        targetImg.tag = 11;
    }
    //如果存在图片
    if((allfilename && allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img11_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img11_ImgView.tag;
        selectPicIndex = self.img11_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)imgChoiceAction12
{
    targetImg = self.img12_ImgView;
    NSString *allfilename = newmatnRec.allfilename12;
    
    if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
        targetImg.tag = 9;
        allfilename = newmatnRec.allfilename09;
    }
    else{
        targetImg.tag = 12;
    }
    //如果存在图片
    if((allfilename && allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:allfilename andImgTag:targetImg.tag];
//        if (timeCha > 1.0) {
//            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
//        alert.tag = self.img12_ImgView.tag;
//        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = self.img12_ImgView.tag;
        selectPicIndex = self.img12_ImgView.tag;
        [cameraSheet showInView:self.view];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"取消"]) {
        return;
    }
    if(alertView.tag == -10)
    {
        return;
    }
    if(buttonIndex == 0)
    {
        if(self.imgContain_view.hidden == YES)
        {
            Img *img = [newmatnRec.imgList objectAtIndex:alertView.tag];
            NSString *allfilename = [NSString stringWithFormat:@"|%@", [img.Url lastPathComponent]];
            
            if(newsAllfilename.length > 30)
            {
                newsAllfilename = [newsAllfilename stringByReplacingOccurrencesOfString:allfilename withString:@""];
            }
            else
            {
                newsAllfilename = @"null";
            }
            
            deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,allfilename];
            [newmatnRec.imgList removeObjectAtIndex:alertView.tag];
            [self.imgCollectionView reloadData];
        }
        else
        {
            [targetImg setImage:[UIImage imageNamed:@"camera_tag"]];
            [imgDic removeObjectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]];
            switch(targetImg.tag)
            {
                case 1:
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename];
                    newmatnRec.allfilename = @"";
                    break;
                case 2:
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename02];
                    newmatnRec.allfilename02 = @"";
                    break;
                case 3:
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename03];
                    newmatnRec.allfilename03 = @"";
                    break;
                case 4:
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename04];
                    newmatnRec.allfilename04 = @"";
                    break;
                case 5:
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename05];
                    newmatnRec.allfilename05 = @"";
                    break;
                case 6:
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename06];
                    newmatnRec.allfilename06 = @"";
                    break;
                case 7:
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename07];
                    newmatnRec.allfilename07 = @"";
                    break;
                case 8:
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename08];
                    newmatnRec.allfilename08 = @"";
                    break;
                case 9:
                    
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename09];
                    newmatnRec.allfilename09 = @"";
                    break;
                case 10:
                    
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename10];
                    newmatnRec.allfilename10 = @"";
                    break;
                case 11:
                    
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename11];
                    newmatnRec.allfilename11 = @"";
                    break;
                case 12:
                    
                    deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newmatnRec.allfilename12];
                    newmatnRec.allfilename12 = @"";
                    break;
                    
            }
        }
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0)
    {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos])
        {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            
            fromCamera = YES;
            
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
    else if (buttonIndex == 1)
    {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            
            fromCamera = NO;
            
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^()
     {
         UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
         UIImage *smallImage = nil;
         if (selectPicIndex != -1) {
             if (selectPicIndex == 9) {
                 smallImage = [self imageByScalingToMaxSize2:portraitImg];
             }
             else
             {
                 smallImage = [self imageByScalingToMaxSize:portraitImg];
             }
         }
         else
         {
             smallImage = [self imageByScalingToMaxSize2:portraitImg];
         }
         NSData *imageData = UIImageJPEGRepresentation(smallImage,0.8f);
         if (fromCamera) {
             [self saveImageToPhotos:portraitImg];
         }
         UIImage *tImg = [UIImage imageWithData:imageData];
         if(selectPicIndex != -1)
         {
             switch (selectPicIndex)
             {
                 case 1:
                     [self.img1_ImgView setImage:tImg];
                     break;
                 case 2:
                     [self.img2_ImgView setImage:tImg];
                     break;
                 case 3:
                     [self.img3_ImgView setImage:tImg];
                     break;
                 case 4:
                     if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
                         [self.img7_ImgView setImage:tImg];
                     }
                     else
                     {
                         [self.img4_ImgView setImage:tImg];
                     }
                     break;
                 case 5:
                     if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
                         [self.img4_ImgView setImage:tImg];
                     }
                     else
                     {
                         [self.img5_ImgView setImage:tImg];
                     }
                     break;
                 case 6:
                     if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
                         [self.img5_ImgView setImage:tImg];
                     }
                     else
                     {
                         [self.img6_ImgView setImage:tImg];
                     }
                     break;
                 case 7:
                     if ([self.matnRec.Project isEqualToString:@"年1次保养"]) {
                         [self.img6_ImgView setImage:tImg];
                     }
                     else
                     {
                         [self.img7_ImgView setImage:tImg];
                     }
                     break;
                 case 8:
                     if ([self.matnRec.Project isEqualToString:@"年2次保养"]) {
                         [self.img9_ImgView setImage:tImg];
                     }
                     else
                     {
                         [self.img8_ImgView setImage:tImg];
                     }
                     break;
                 case 9:
                     if ([self.matnRec.Project isEqualToString:@"年2次保养"]) {
                         [self.img8_ImgView setImage:tImg];
                     }
                     else if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
                         [self.img12_ImgView setImage:tImg];
                     }
                     else
                     {
                         [self.img9_ImgView setImage:tImg];
                     }
                     break;
                 case 10:
                     if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
                         [self.img9_ImgView setImage:tImg];
                     }
                     else
                     {
                         [self.img10_ImgView setImage:tImg];
                     }
                     break;
                 case 11:
                     if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
                         [self.img10_ImgView setImage:tImg];
                     }
                     else
                     {
                         [self.img11_ImgView setImage:tImg];
                     }
                     break;
                 case 12:
                     if ([self.matnRec.Project isEqualToString:@"年4次保养"]) {
                         [self.img11_ImgView setImage:tImg];
                     }
                     else
                     {
                         [self.img12_ImgView setImage:tImg];
                     }
                     break;
             }
             [imgDic setObject:tImg forKey:[NSString stringWithFormat:@"%li",(long)selectPicIndex]];
         }
         else
         {
             Img *tem = [[Img alloc] init];
             tem.img = tImg;
             [newmatnRec.imgList addObject:tem];
             [self reSizeCollectionView];
             [self.imgCollectionView reloadData];
         }
     }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingToMaxSize2:(UIImage *)sourceImage {
    if (sourceImage.size.width < 700) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = 700;
        btWidth = sourceImage.size.width * (700 / sourceImage.size.height);
    } else {
        btWidth = 700;
        btHeight = sourceImage.size.height * (700 / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
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
