//
//  RongYeUpdate2017View.m
//  Broad
//
//  Created by Seven on 17/2/8.
//  Copyright © 2017年 greenorange. All rights reserved.
//

#import "RongYeUpdate2017View.h"
#import "HSDatePickerViewController.h"
#import "RongYeUpdateView.h"
#import "EnginUnit.h"
#import "SGActionView.h"
#import "MatnRec.h"
#import "Img.h"

#define ORIGINAL_MAX_WIDTH 700.0f

@interface RongYeUpdate2017View ()<UITextFieldDelegate,HSDatePickerViewControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    Solution *newsolution;
    
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
    NSString *create_no_labelStr;
    
    
    NSString *deleteImgStr;
    NSString *newsAllfilename;
    NSString *sysTimeStr;
    double timeCha;
    
    BOOL fromCamera;
}

@end

@implementation RongYeUpdate2017View

- (void)viewDidLoad {
    [super viewDidLoad];
    fromCamera = NO;
    
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
    [addBtn setTitle:@"提交" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    
    self.servicetime_field.delegate = self;
    self.servicetime_field.tag = 3;
    
    //初始化图片集合
    imgDic = [[NSMutableDictionary alloc] init];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enginChoice)];
    [self.engine_choice_view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *imgTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgChoiceAction1)];
    [self.quyang_ImgView addGestureRecognizer:imgTap1];
    
    //    self.uploadtime_field.delegate = self;
    //    self.uploadtime_field.tag = 3;
    //删除图片用
    newsAllfilename = self.solution.allfilename;
    
    [self bindData];
    [self initData];
}

-(void) bindData
{
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.enginer_field.text = newsolution.ExecMan;
    self.uploador_field.text = newsolution.Uploader;
    self.uploadtime_field.text = newsolution.UploadTime;
    self.chucang_no_label.text = newsolution.OutFactNum;
    self.engine_no_label.text = newsolution.AirCondUnitMode;
    create_no_labelStr = newsolution.ProdNum;
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
    [self setImg];
}

-(void) setImg
{
    int index = 0;
    if (newsolution.allfilename.length > 0)
    {
        Img *img = newsolution.imgList[index];
        if(img.Url && img.Url.length > 0)
        {
            [self.quyang_ImgView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        }
        else
        {
            [self.quyang_ImgView setImage:img.img];
        }
        
        self.quyang_ImgView.tag = index;
        ++index;
        if (index >= newsolution.imgList.count)
        {
            return;
        }
    }
}

- (void)submit
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
    for(NSString *key in imgDic)
    {
        UIImage *imgbegin = [[UIImage alloc] init];
        imgbegin = nil;
        imgbegin = imgDic[key];
        
        if(imgbegin)
        {
            int y = (arc4random() % 501) + 500;
            
            NSString *project = @"";
            
            if([key isEqualToString:@"1"])
            {
                project = self.quyang_label.text;
            }
            
            NSString *reName = [[NSString alloc] init];
            reName = nil;
            reName = [NSString stringWithFormat:@"%@%@%@%i%@.jpg",self.chucang_no_label.text, project, [Tool getCurrentTimeStr:@"yyyy-MM-dd-HHmmss"],y, @"I"];
            
            BOOL isOK = [self upload:imgbegin oldName:reName Index:[key intValue]];
            if(!isOK)
            {
                if (hud) {
                    [hud hide:YES];
                }
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
                    //                    if([response containsString:@"true"])
                    if ([response rangeOfString:@"true"].length > 0)
                    {
                        isOK = YES;
                        if(newsAllfilename == nil || [newsAllfilename isEqualToString:@"null"])
                        {
                            newsAllfilename = @"";
                        }
                        newsolution.allfilename = [NSString stringWithFormat:@"|%@",fileName];
                        newsAllfilename = [NSString stringWithFormat:@"|%@",fileName];
                        newsAllfilename = [newsAllfilename stringByReplacingOccurrencesOfString:@"null" withString:@""];
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
    NSString *sql = [NSString stringWithFormat:@"update SolutionSample set ProjID='%@',ExecMan='%@',ExecDate='%@',Uploader='%@',UploadTime='%@',OutFactNum='%@',AirCondUnitMode='%@',ProdNum='%@',allfilename='%@' where ID='%@'",app.depart.PROJ_ID,self.enginer_field.text,self.servicetime_field.text,self.uploador_field.text,self.uploadtime_field.text,self.chucang_no_label.text,self.engine_no_label.text,create_no_labelStr,newsAllfilename,newsolution.ID];
    if([newsAllfilename isEqualToString:@"null"])
    {
        sql = [NSString stringWithFormat:@"update SolutionSample set ProjID='%@',ExecMan='%@',ExecDate='%@',Uploader='%@',UploadTime='%@',OutFactNum='%@',AirCondUnitMode='%@',ProdNum='%@',allfilename=%@ where ID='%@'",app.depart.PROJ_ID,self.enginer_field.text,self.servicetime_field.text,self.uploador_field.text,self.uploadtime_field.text,self.chucang_no_label.text,self.engine_no_label.text,create_no_labelStr,newsAllfilename,newsolution.ID];
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
            newsolution.allfilename = newsAllfilename;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notifireSolution" object:nil userInfo:[NSDictionary dictionaryWithObject:newsolution forKey:@"solution"]];
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_RongYeListReLoad" object:nil];
            
            [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
        };
        
        [utils stringFromparserXML:response target:@"string"];
    }
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
                          sysTimeStr = string;
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

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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
                          create_no_labelStr = unit.Prod_Num;
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
        [Tool showCustomHUD:@"取样时间 <= 上传时间" andView:self.view andImage:nil andAfterDelay:3.8f];
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

- (void)imgChoiceAction1
{
    targetImg = self.quyang_ImgView;
    targetImg.tag = 1;
    //如果存在图片
    if((newsolution.allfilename && newsolution.allfilename.length > 0) || [imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]])
    {
        [self checkImgUploadTime:newsolution.allfilename andImgTag:targetImg.tag];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        selectPicIndex = self.quyang_ImgView.tag;
        
        [cameraSheet showInView:self.view];
    }
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

- (double)intervalSinceNow: (NSString *) theDate
{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate *nowdate=[date dateFromString:sysTimeStr];
    NSTimeInterval now=[nowdate timeIntervalSince1970]*1;
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
        [targetImg setImage:[UIImage imageNamed:@"camera_tag"]];
        [imgDic removeObjectForKey:[NSString stringWithFormat:@"%li",targetImg.tag]];
        switch(targetImg.tag)
        {
            case 1:
                deleteImgStr = [NSString stringWithFormat:@"%@%@",deleteImgStr,newsolution.allfilename];
                newsolution.allfilename = @"";
                break;
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
         smallImage = [self imageByScalingToMaxSize:portraitImg];
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
                     [self.quyang_ImgView setImage:tImg];
                     break;
             }
             [imgDic setObject:tImg forKey:[NSString stringWithFormat:@"%li",(long)selectPicIndex]];
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
