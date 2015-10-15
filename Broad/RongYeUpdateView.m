//
//  WeiXiuAddView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "IQAssetsPickerController.h"
#import "HSDatePickerViewController.h"
#import "RongYeUpdateView.h"
#import "EnginUnit.h"
#import "SGActionView.h"
#import "MatnRec.h"
#import "RepairImgCell.h"
#import "Img.h"

@interface RongYeUpdateView ()<UICollectionViewDataSource, UICollectionViewDelegate,UITextFieldDelegate,IQAssetsPickerControllerDelegate,HSDatePickerViewControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    Solution *newsolution;
    
    NSMutableArray *imgArray;
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
}


@end

@implementation RongYeUpdateView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    newsolution = [[Solution alloc] init];
    [newsolution initWithSolution:self.solution];
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
    [addBtn setTitle:@"保存记录" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    
    self.imgCollectionView.delegate = self;
    self.imgCollectionView.dataSource = self;
    
    self.servicetime_field.delegate = self;
    self.servicetime_field.tag = 3;
    
    Img *img = [[Img alloc] init];
    img.img = [UIImage imageNamed:@"camera_tag"];
    [newsolution.imgList insertObject:img atIndex:0];
    
    [self.imgCollectionView registerClass:[RepairImgCell class] forCellWithReuseIdentifier:@"RepairImgCell"];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.imgCollectionView.hidden = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enginChoice)];
    [self.engine_choice_view addGestureRecognizer:tap];
    
//    self.uploadtime_field.delegate = self;
//    self.uploadtime_field.tag = 3;
    //删除图片用
    newsAllfilename = self.solution.allfilename;
    
    [self bindData];
    [self initData];
    [self reSizeCollectionView];
}

-(void) bindData
{
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.enginer_field.text = newsolution.ExecMan;
    self.user_field.text = app.depart.CustShortName_CN;
    self.uploador_field.text = newsolution.Uploader;
    self.uploadtime_field.text = newsolution.UploadTime;
    self.chucang_no_label.text = newsolution.OutFactNum;
    self.engine_no_label.text = newsolution.AirCondUnitMode;
    self.create_no_label.text = newsolution.ProdNum;
    if (newsolution.ExecDate.length > 0)
    {
        NSString *timeStr = [newsolution.ExecDate substringToIndex:[newsolution.ExecDate rangeOfString:@" "].location];
        
        if(timeStr)
        {
            self.servicetime_field.text = timeStr;
        }
        else
        {
            self.servicetime_field.text = @"未知";
        }
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)add
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //异步请求启动文件上传及后续写库操作！SQL无意义，只为启动提示稍后
//    [self updateImg];
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
    
    //跳过第一个
    for(int i = 1; i < newsolution.imgList.count; ++i)
    {
        Img *img = newsolution.imgList[i];
        if(img.img)
        {
            int y = (arc4random() % 501) + 500;
                
            NSString *reName = [NSString stringWithFormat:@"%@%@%i.jpg",@"溶液取样",[Tool getCurrentTimeStr:@"yyyy-MM-dd-hh:mm"],y];
            BOOL isOK = [self upload:img.img oldName:reName Index:-1];
            if(!isOK)
            {
                    [Tool showCustomHUD:@"图片上传失败..." andView:self.view andImage:nil andAfterDelay:1.2f];
                    return;
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
        NSString *fileName = [NSString stringWithFormat:@"%@%i.jpg",[Tool getCurrentTimeStr:@"yyyyMMddhhmm"],y];
        
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
//                    if([response containsString:@"true"])
                    if ([response rangeOfString:@"true"].length > 0)
                    {
                        isOK = YES;
                        
                        newsolution.allfilename = [NSString stringWithFormat:@"%@|%@",newsolution.allfilename,fileName];
                        newsAllfilename = [NSString stringWithFormat:@"%@|%@",newsAllfilename,fileName];
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
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sql = [NSString stringWithFormat:@"update SolutionSample set ProjID='%@',ExecMan='%@',ExecDate='%@',Uploader='%@',UploadTime='%@',OutFactNum='%@',AirCondUnitMode='%@',ProdNum='%@',allfilename='%@' where ID='%@'",app.depart.PROJ_ID,self.enginer_field.text,self.servicetime_field.text,self.uploador_field.text,self.uploadtime_field.text,self.chucang_no_label.text,self.engine_no_label.text,self.create_no_label.text,newsAllfilename,newsolution.ID];
    if([newsAllfilename isEqualToString:@"null"])
    {
        sql = [NSString stringWithFormat:@"update SolutionSample set ProjID='%@',ExecMan='%@',ExecDate='%@',Uploader='%@',UploadTime='%@',OutFactNum='%@',AirCondUnitMode='%@',ProdNum='%@',allfilename=%@ where ID='%@'",app.depart.PROJ_ID,self.enginer_field.text,self.servicetime_field.text,self.uploador_field.text,self.uploadtime_field.text,self.chucang_no_label.text,self.engine_no_label.text,self.create_no_label.text,newsAllfilename,newsolution.ID];
        newsAllfilename = @"";
    }
    
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
            newsolution.ExecMan = self.enginer_field.text;
            newsolution.Uploader = self.uploador_field.text;
            newsolution.UploadTime = self.uploadtime_field.text;
            newsolution.OutFactNum = self.chucang_no_label.text;
            newsolution.AirCondUnitMode = self.engine_no_label.text;
            newsolution.ProdNum = self.create_no_label.text;
            newsolution.allfilename = newsAllfilename;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notifireSolution" object:nil userInfo:[NSDictionary dictionaryWithObject:newsolution forKey:@"solution"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_RongYeListReLoad" object:nil];
            
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
    if(textField.tag == 3)
    {
        HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
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
    NSInteger size = (newsolution.imgList.count)/3;
    
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
    
    //调整网格布局高度
    self.imgCollectionView.frame = CGRectMake(x, y, width, height);
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.imgCollectionView.frame.origin.y + self.imgCollectionView.frame.size.height + 10);
}

#pragma mark - 图片集合
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return newsolution.imgList.count;
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
    
    Img *img = [newsolution.imgList objectAtIndex:[indexPath row]];
    
    if(img.img)
    {
        [cell.repairImg setImage:img.img];
    }
    else
    {
        [cell.repairImg sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
    }
    
    cell.repairImg.frame = CGRectMake(0, 0, 85, 85);
    
    cell.deleteBtn.hidden = YES;
    
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
        [choiceSheet showInView:self.view];
    }
    else
    {
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
    int tag = [Tool compareOneDay:targetDate withAnotherDay:self.uploadtime_field.text];
    //如果为0则两个日期相等,如果为-1则服务时间小于于起始时间
    if(tag == 0 || tag == -1)
    {
        self.servicetime_field.text = targetDate;
        serviceDate = date;
    }
    else
    {
        [Tool showCustomHUD:@"取样时间必须小于上传时间" andView:self.view andImage:nil andAfterDelay:3.8f];
        return;
    }
}
//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker did dismiss with %lu", (unsigned long)method);
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
                          self.uploadtime_field.text = timeStr;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        Img *img = [newsolution.imgList objectAtIndex:alertView.tag];
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
        [newsolution.imgList removeObjectAtIndex:alertView.tag];
        [self.imgCollectionView reloadData];
    }
    if(buttonIndex == 2)
    {
        Img *img = [newsolution.imgList objectAtIndex:alertView.tag];
        NSString *allfilename = [NSString stringWithFormat:@"|%@", [img.Url lastPathComponent]];
        
        if(newsAllfilename.length > 30)
        {
            newsAllfilename = [newsAllfilename stringByReplacingOccurrencesOfString:allfilename withString:@""];
        }
        else
        {
            newsAllfilename = @" ";
        }
        
        deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,allfilename];
        [newsolution.imgList removeObjectAtIndex:alertView.tag];
        [self.imgCollectionView reloadData];
    }
    else if(buttonIndex == 1)
    {
//        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                 delegate:self
//                                                        cancelButtonTitle:@"取消"
//                                                   destructiveButtonTitle:nil
//                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
//        selectPicIndex = alertView.tag;
//        [cameraSheet showInView:self.view];
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
//        IQAssetsPickerController *controller = [[IQAssetsPickerController alloc] init];
//        if(actionSheet.tag == 0)
//        {
//            controller.allowsPickingMultipleItems = NO;
//        }
//        else if(actionSheet.tag == 1)
//        {
//            controller.allowsPickingMultipleItems = YES;
//        }
//        if(selectPicIndex == -1)
//        {
//            controller.pickCount = 9;
//        }
//        else
//        {
//            controller.pickCount = 1;
//        }
//        
//        controller.delegate = self;
//        controller.pickerType = IQAssetsPickerControllerAssetTypePhoto;
//        
//        [self.navigationController pushViewController:controller animated:YES];
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
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
         UIImage *smallImage = [self imageByScalingToMaxSize:portraitImg];
         NSData *imageData = UIImageJPEGRepresentation(smallImage,0.8f);
         
         UIImage *tImg = [UIImage imageWithData:imageData];
         
         Img *tem = [[Img alloc] init];
         tem.img = tImg;
         
         [newsolution.imgList addObject:tem];
         
        [imgArray addObject:tImg];
        [self reSizeCollectionView];
        [self.imgCollectionView reloadData];
         
     }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - IQAssetsPickerControllerDelegate
- (void)assetsPickerController:(IQAssetsPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info
{
    NSMutableArray *views = [[NSMutableArray alloc] initWithArray:[controller.navigationController viewControllers]];
    [views removeLastObject];
    controller.navigationController.viewControllers = views;
    [controller.navigationController popViewControllerAnimated:YES];
    if(info)
    {
        NSArray *imgd = info[@"IQMediaTypeImage"];
        for(int i = 0; i < imgd.count; ++i)
        {
            NSDictionary *imgdic = imgd[i];
            UIImage *img = imgdic[@"IQMediaImage"];
            if(img)
            {
                UIImage *smallImage = [self imageByScalingToMaxSize:img];
                NSData *imageData = UIImageJPEGRepresentation(smallImage,0.8f);
//                NSData *imageData = UIImageJPEGRepresentation(img,0.8f);
                img = [UIImage imageWithData:imageData];
                Img *tem = [[Img alloc] init];
                tem.img = img;
                [newsolution.imgList addObject:tem];
                [imgArray addObject:img];
                [self reSizeCollectionView];
                [self.imgCollectionView reloadData];
                
            }
        }
    }
}

- (void)assetsPickerControllerDidCancel:(IQAssetsPickerController *)controller
{
    
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

@end
