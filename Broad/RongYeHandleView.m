//
//  RongYeHandleView.m
//  Broad
//
//  Created by Seven on 17/2/7.
//  Copyright © 2017年 greenorange. All rights reserved.
//

#import "RongYeHandleView.h"
#import "SolutionMgmt.h"
#import "ProjInf.h"
#import "SGActionView.h"
#import "HSDatePickerViewController.h"
#import "Img.h"
#import "SGActionView.h"

#define ORIGINAL_MAX_WIDTH 700.0f

@interface RongYeHandleView ()<UIAlertViewDelegate,UITextFieldDelegate,HSDatePickerViewControllerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    SolutionMgmt *solutionMgmt;
    NSString *systemTime;
    
    NSArray *seArray;
    NSArray *se2Array;
    
    NSArray *imgArray;
    
    MBProgressHUD *hud;
    NSDate *handleDate;
    NSMutableDictionary *imgDic;
    
    UIButton *targetImgBtn;
    
    BOOL fromCamera;
}

@end

@implementation RongYeHandleView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"溶液处理";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.HandleTime_field.delegate = self;
    self.HandleTime_field.tag = 3;
    
    //初始化图片集合
    imgDic = [[NSMutableDictionary alloc] init];
    
    [self initData];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitAction
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    NSString *handleTime = self.HandleTime_field.text;
    NSString *lithiumByEngineer = self.LithiumByEngineer_field.text;
    if (![solutionMgmt.Result isEqualToString:@"正常使用"])
    {
        if (handleTime.length == 0)
        {
            hud.hidden = YES;
            [Tool showCustomHUD:@"请选择处理时间" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        if([imgDic count] == 0)
        {
            hud.hidden = YES;
            [Tool showCustomHUD:@"请上传处理照片" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
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
                project = self.Handle_label.text;
            }
            
            NSString *reName = [[NSString alloc] init];
            reName = nil;
            reName = [NSString stringWithFormat:@"%@%@%@%i%@.jpg",self.OutFact_Num_field.text, project, [Tool getCurrentTimeStr:@"yyyy-MM-dd-HHmmss"],y, @"I"];
            
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
    
    [self insertData];
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
            if([response rangeOfString:@"UploadFile"].length > 0)
            {
                NSRange range = [response rangeOfString:@"/UploadFile"];//匹配得到的下标
                range.length = range.length + 10;
                NSString *string = [response substringWithRange:range];//截取范围类的字符串
                NSLog(@"截取的值为：%@",response);
                
                //                NSString *string = [NSString stringWithFormat:@"/UploadFile/%@/", [Tool getCurrentTimeStr:@"yyyyMMdd"]];
                img = nil;
                base64Encoded = nil;
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
                        if(solutionMgmt.allfilename == nil || [solutionMgmt.allfilename isEqualToString:@"null"])
                        {
                            solutionMgmt.allfilename = @"";
                        }
                        solutionMgmt.allfilename = [NSString stringWithFormat:@"|%@",fileName];
                        solutionMgmt.allfilename = [solutionMgmt.allfilename stringByReplacingOccurrencesOfString:@"null" withString:@""];
                    }
                }
            }
        }
        else
        {
            isOK = NO;
        }
    }
    return isOK;
}

- (void)insertData
{
    NSString *HandleTime = self.HandleTime_field.text;
    NSString *LithiumByEngineer = self.LithiumByEngineer_field.text;
    NSString *Other = self.Other_field.text;
    if (HandleTime == nil || HandleTime.length == 0) {
        HandleTime = @"";
    }
    if (LithiumByEngineer == nil || LithiumByEngineer.length == 0) {
        LithiumByEngineer = @"";
    }
    if (Other == nil || Other.length == 0) {
        Other = @"";
    }
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE [TB_CUST_ProjInf_SolutionMgmt] SET HandleTime='%@',LithiumByEngineer='%@',Other='%@',allfilename='%@',HandleUpdateTime=CONVERT(varchar(100), GETDATE(), 20) where id=%@", HandleTime, LithiumByEngineer, Other, solutionMgmt.allfilename, solutionMgmt.ID];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        NSLog(response);
        if (hud) {
            [hud hide:YES];
        }
        if([response rangeOfString:@"true"].length > 0)
        {
            [Tool showCustomHUD:@"上传成功" andView:self.view andImage:nil andAfterDelay:1.2f];
            [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
            
            NSMutableArray *titles = [[NSMutableArray alloc] init];
            NSMutableArray *stitles = [[NSMutableArray alloc] init];
            for(int i = 0; i < seArray.count; ++i)
            {
                NSDictionary *dic = seArray[i];
                [titles addObject:[dic objectForKey:@"StepName"]];
                [stitles addObject:[dic objectForKey:@"NextUserName"]];
            }
            //            [SGActionView showSheetWithTitle:@"请选择:"
            //                                  itemTitles:titles
            //                               itemSubTitles:stitles
            //                               selectedIndex:-1
            //                              selectedHandle:^(NSInteger index){
            //
            //                                  NSDictionary *dic = seArray[index];
            AppDelegate *app = [[UIApplication sharedApplication] delegate];
            NSString *sql = [NSString stringWithFormat:@"SP_FlowSubmit '%@',1,'','%@','溶液管理录入','办结成功'",app.userinfo.UserName,self.Mark];
            hud.hidden = NO;
            [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
            [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 NSLog(@"%@", operation.responseString);
                 XMLParserUtils *utils = [[XMLParserUtils alloc] init];
                 utils.parserFail = ^()
                 {
                     hud.hidden = YES;
                     [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                     [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                 };
                 utils.parserOK = ^(NSString *string)
                 {
                     if([string isEqualToString:@"true"])
                     {
                         [Tool showCustomHUD:@"办理成功" andView:self.view andImage:nil andAfterDelay:1.2f];
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_FlowListReLoad" object:nil];
                         [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                     }
                     else
                     {
                         [Tool showCustomHUD:@"办理失败" andView:self.view andImage:nil andAfterDelay:1.2f];
                         self.navigationItem.rightBarButtonItem.enabled = YES;
                     }
                 };
                 
                 [utils stringFromparserXML:operation.responseString target:@"string"];
             } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 hud.hidden = YES;
                 self.navigationItem.rightBarButtonItem.enabled = YES;
                 [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                 [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
             }];
            
            
            //                              }];
        }
        else
        {
            [Tool showCustomHUD:@"办理失败" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
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
             long execTimeLong = [[Tool transformDateFormat:self.Exec_Date_field.text andFromFormatterStr:@"yyyy-MM-dd" andToFormatterStr:@"yyyy"] longLongValue];
             if ((execTimeLong == systemYearLong) && systemTimeLong <= 930) {
                 UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                 addBtn.frame = CGRectMake(0, 0, 78, 44);
                 [addBtn setTitle:@"提交" forState:UIControlStateNormal];
                 [addBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
                 UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
                 self.navigationItem.rightBarButtonItem = addItem;
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
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT a.*,b.* from [TB_CUST_ProjInf_SolutionMgmt] as a LEFT OUTER JOIN SolutionSample as b ON a.OutFact_Num=b.OutFactNum and a.Exec_Date=b.ExecDate where Mark='%@'",self.Mark];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSer:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
}

- (void)requestSer:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSDictionary *jsonDic = [jsonArray objectAtIndex:0];
        
        solutionMgmt = [Tool readJsonDicToObj:jsonDic andObjClass:[SolutionMgmt class]];
        if(solutionMgmt)
        {
            self.CUST_Name_field.text = solutionMgmt.CUST_Name;
            self.Exec_Man_field.text = solutionMgmt.Exec_Man;
            self.Exec_Date_field.text = [Tool DateTimeRemoveTime:solutionMgmt.Exec_Date andSeparated:@" "];
            self.UploadTime1_field.text = [Tool DateTimeRemoveTime:solutionMgmt.UploadTime1 andSeparated:@" "];
            self.Uploader1_field.text = solutionMgmt.Uploader1;
            self.OutFact_Num_field.text = solutionMgmt.OutFact_Num;
            self.AirCondUnit_Mode_field.text = solutionMgmt.AirCondUnit_Mode;
            self.ReceiveDate_field.text = [Tool DateTimeRemoveTime:solutionMgmt.ReceiveDate andSeparated:@" "];
            self.HandleOpinion_field.text = solutionMgmt.HandleOpinion;
            
            self.LiBr_field.text = solutionMgmt.LiBr;
            self.LiBr_R_lb.text = solutionMgmt.LiBrResult;
            self.Density_field.text = solutionMgmt.Density;
            self.Temp_field.text = solutionMgmt.Temp;
            self.SolutionOutward_field.text = solutionMgmt.SolutionOutward;
            self.SolutionOutward_R_lb.text = solutionMgmt.OutwardResult;
            self.PH_field.text = solutionMgmt.PH;
            self.PH_R_lb.text = solutionMgmt.PHResult;
            self.CU2_field.text = solutionMgmt.CU2;
            self.CU2_R_lb.text = solutionMgmt.CU2Result;
            self.Fe_field.text = solutionMgmt.Fe;
            self.Fe_R_lb.text = solutionMgmt.FeResult;
            self.Licro4_field.text = solutionMgmt.Licro4;
            self.Licro4_R_lb.text = solutionMgmt.Licro4Result;
            self.Precipitation_field.text = solutionMgmt.Precipitation;
            self.Precipitation_R_lb.text = solutionMgmt.PrecipitationResult;
            self.Cl_field.text = solutionMgmt.Cl;
            self.Cl_R_lb.text = solutionMgmt.ClResult;
            self.Result_field.text = solutionMgmt.Result;
            
            if (solutionMgmt.allfilename1.length > 0) {
                [self getImg:solutionMgmt.allfilename1];
            }
            
            NSString *sqlStr = nil;
            sqlStr = [NSString stringWithFormat:@"Sp_GetFlowNextInfo '%@'",self.Mark];
            NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
            
            NSURL *url = [NSURL URLWithString: urlStr];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setUseCookiePersistence:NO];
            [request setTimeOutSeconds:30];
            [request setPostValue:sqlStr forKey:@"sqlstr"];
            [request setDelegate:self];
            [request setDefaultResponseEncoding:NSUTF8StringEncoding];
            [request setDidFailSelector:@selector(requestFailed:)];
            [request setDidFinishSelector:@selector(requestOK:)];
            [request startAsynchronous];
            request.hud = [[MBProgressHUD alloc] initWithView:self.view];
            [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
        }
        else
        {
            [Tool showCustomHUD:@"获取信息失败..." andView:self.view andImage:nil andAfterDelay:1.2f];
        }
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)requestOK:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        
        seArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        [self getSystemTime];
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
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
                 [self.photos removeAllObjects];
                 [self setImg];
             }
             else
             {
                 [self.photos removeAllObjects];
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
    if (solutionMgmt.allfilename1.length > 0)
    {
        Img *img = imgArray[index];
        [self.quyangfilename_image sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.quyangfilename_image.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.quyangfilename_image addGestureRecognizer:imgTap];
        
        ++index;
        if (index >= imgArray.count)
        {
            return;
        }
    }
}

- (void)imgTapClick:(UITapGestureRecognizer *)sender
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
    [browser setCurrentPhotoIndex:sender.view.tag];
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

//服务类型、项目、时间等输入框不允许弹出输入法界面
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag == 3)
    {
        HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
        hsdpvc.delegate = self;
        if (handleDate)
        {
            hsdpvc.date = handleDate;
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
    int tag = [Tool compareOneDay:targetDate withAnotherDay:self.ReceiveDate_field.text];
    //如果为0则两个日期相等,如果为-1则服务时间小于于起始时间
    if(tag == 0 || tag == -1)
    {
        [Tool showCustomHUD:@"处理时间应大于取样时间" andView:self.view andImage:nil andAfterDelay:3.8f];
        return;
    }
    else
    {
        tag = [Tool compareOneDay:targetDate withAnotherDay:systemTime];
        //如果为0则两个日期相等,如果为-1则服务时间小于于起始时间
        if(tag == 1)
        {
            [Tool showCustomHUD:@"处理时间应小于等于当前时间" andView:self.view andImage:nil andAfterDelay:3.8f];
            return;
        }
        else
        {
            self.HandleTime_field.text = targetDate;
            handleDate = date;
        }
    }
}

//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker did dismiss with %lu", (unsigned long)method);
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker will dismiss with %lu",(unsigned long)method);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)imgChoiceAction:(id)sender
{
    targetImgBtn = nil;
    targetImgBtn = sender;
    //如果存在图片
    if([imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
        alert.tag = -11;
        [alert show];
    }
    else
    {
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = 0;
        [cameraSheet showInView:self.view];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == -10)
    {
        return;
    }
    if(buttonIndex == 0)
    {
        if(alertView.tag == -11)
        {
            [imgDic removeObjectForKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]];
            [targetImgBtn setImage:[UIImage imageNamed:@"camera_tag"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
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
         
         [targetImgBtn setImage:tImg forState:UIControlStateNormal];
         [imgDic removeObjectForKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]];
         [imgDic setObject:tImg forKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
