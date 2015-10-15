//
//  WeiXiuAddView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "WeiXiuAddView.h"
#import "HSDatePickerViewController.h"
#import "EnginUnit.h"
#import "SGActionView.h"
#import "MatnRec.h"
#import "RepairImgCell.h"

@interface WeiXiuAddView ()<UICollectionViewDataSource, UICollectionViewDelegate,UITextFieldDelegate,HSDatePickerViewControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    MatnRec *matnRec;
    NSMutableDictionary *imgDic;
    NSMutableArray *imgArray;
    NSArray *enginUnitArray;
    NSMutableArray *enginUnitNoArray;
    NSMutableArray *enginUnitModeArray;
    NSArray *serviceProjects;
    NSInteger selectedServiceTypeIndex;
    NSInteger selectedServiceNameIndex;
    NSInteger selectedEnginIndex;
    MBProgressHUD *hud;
    NSDate *serviceDate;
    UIButton *targetImgBtn;
    
    MBProgressHUD *hud2;
}

@end

@implementation WeiXiuAddView

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedServiceTypeIndex = -1;
    selectedServiceNameIndex = -1;
    selectedEnginIndex = -1;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"新增";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 78, 44);
    [addBtn setTitle:@"上传记录" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    
    self.imgCollectionView.delegate = self;
    self.imgCollectionView.dataSource = self;
    
    self.servcetype_field.delegate = self;
    self.servcetype_field.tag = 1;
    
    self.serviceproject_field.delegate = self;
    self.serviceproject_field.tag = 2;
    
    self.servicetime_field.delegate = self;
    self.servicetime_field.tag = 3;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    self.enginer_label.text = app.depart.Duty_Engineer;
    self.uploador_label.text = app.userinfo.UserName;
    
    //初始化图片集合
    imgDic = [[NSMutableDictionary alloc] init];
    imgArray = [[NSMutableArray alloc] init];
    [imgArray addObject:[UIImage imageNamed:@"camera_tag"]];
    [self.imgCollectionView registerClass:[RepairImgCell class] forCellWithReuseIdentifier:@"RepairImgCell"];
    
    self.imgCollectionView.hidden = YES;
    self.imgContain_view.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enginChoice)];
    [self.engine_choice_view addGestureRecognizer:tap];
    [self initData];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)publishAction
{
    NSString *updateUrl = @"http://www.baidu.com";
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:updateUrl]];
    [request setUseCookiePersistence:[[UserModel Instance] isLogin]];
    
    request.delegate = self;
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSubmit:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"提交发帖" andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}
- (void)requestSubmit:(ASIHTTPRequest *)request
{
}

- (void)add
{
    [self publishAction];
    hud2 = [[MBProgressHUD alloc] initWithView:self.view];
    
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud2];
    
    NSString *type = self.servcetype_field.text;
    NSString *project = self.serviceproject_field.text;
    NSString *time = self.servicetime_field.text;
    NSString *no = self.engine_no_label.text;
    if (type.length == 0)
    {
        if (hud2) {
            [hud2 hide:YES];
        }
        [Tool showCustomHUD:@"请选择服务类型" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (project.length == 0)
    {
        if (hud2) {
            [hud2 hide:YES];
        }
        [Tool showCustomHUD:@"请选择服务项目" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (time.length == 0)
    {
        if (hud2) {
            [hud2 hide:YES];
        }
        [Tool showCustomHUD:@"请选择服务时间" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (no.length == 0)
    {
        if (hud2) {
            [hud2 hide:YES];
        }
        [Tool showCustomHUD:@"请选择机组" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    if([self.servcetype_field.text isEqualToString:@"年4次保养"])
    {
        if([imgDic count] == 0)
        {
            if (hud2) {
                [hud2 hide:YES];
            }
            [Tool showCustomHUD:@"请上传附件" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
    }
    else
    {
        if([imgArray count] == 0)
        {
            if (hud2) {
                [hud2 hide:YES];
            }
            [Tool showCustomHUD:@"请上传附件" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
    }
    
    if([self.serviceproject_field.text isEqualToString:@"年1次保养"])
    {
        if([imgDic objectForKey:@"4"] == nil)
        {
            if (hud2) {
                [hud2 hide:YES];
            }
            [Tool showCustomHUD:@"请上传售后服务单" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
    }
    if([self.serviceproject_field.text isEqualToString:@"年2次保养"])
    {
        if([imgDic objectForKey:@"8"] == nil)
        {
            if (hud2) {
                [hud2 hide:YES];
            }
            [Tool showCustomHUD:@"请上传售后服务单" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
    }
    if([self.serviceproject_field.text isEqualToString:@"年3次保养"])
    {
        if([imgDic objectForKey:@"6"] == nil)
        {
            if (hud2) {
                [hud2 hide:YES];
            }
            [Tool showCustomHUD:@"请上传售后服务单" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
    }
    if([self.serviceproject_field.text isEqualToString:@"年4次保养"])
    {
        if([imgDic objectForKey:@"9"] == nil)
        {
            if (hud2) {
                [hud2 hide:YES];
            }
            [Tool showCustomHUD:@"请上传售后服务单" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    matnRec = [[MatnRec alloc] init];
    matnRec.allfilename = @"";
    matnRec.allfilename02 = @"";
    matnRec.allfilename03 = @"";
    matnRec.allfilename04 = @"";
    matnRec.allfilename05 = @"";
    matnRec.allfilename06 = @"";
    matnRec.allfilename07 = @"";
    matnRec.allfilename08 = @"";
    matnRec.allfilename09 = @"";
    
    NSDateComponents *datec = [Tool getCurrentYear_Month_Day];
    NSInteger year = [datec year];
    
    if ([self.servcetype_field.text isEqualToString:@"年4次保养"])
    {
        NSString *start = nil;
        NSString *end = nil;
        
        if ([self.serviceproject_field.text isEqualToString:@"年1次保养"])
        {
            start = [NSString stringWithFormat:@"%li-01-01  00:00:00",year];
            end = [NSString stringWithFormat:@"%li-04-01  00:00:00",year];
        }
        else if ([self.serviceproject_field.text isEqualToString:@"年2次保养"])
        {
            start = [NSString stringWithFormat:@"%li-04-01  00:00:00",year];
            end = [NSString stringWithFormat:@"%li-07-01  00:00:00",year];
        }
        else if ([self.serviceproject_field.text isEqualToString:@"年3次保养"])
        {
            start = [NSString stringWithFormat:@"%li-07-01  00:00:00",year];
            end = [NSString stringWithFormat:@"%li-10-01  00:00:00",year];
        }
        else if ([self.serviceproject_field.text isEqualToString:@"年4次保养"])
        {
            start = [NSString stringWithFormat:@"%li-10-01  00:00:00",year];
            end = [NSString stringWithFormat:@"%li-01-01  00:00:00",year+1];
        }
        
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        EnginUnit *enginUnit = enginUnitArray[selectedEnginIndex];
        NSString *sql = [NSString stringWithFormat:@"Select COUNT(*)  From TB_CUST_ProjInf_MatnRec Where Project='%@' and Proj_ID='%@' and OutFact_Num='%@' and UploadTime <'%@' and UploadTime >='%@'",self.serviceproject_field.text,app.depart.PROJ_ID,enginUnit.OutFact_Num,end,start];
        
        [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             XMLParserUtils *utils = [[XMLParserUtils alloc] init];
             utils.parserFail = ^()
             {
                 if (hud2) {
                     [hud2 hide:YES];
                 }
                 [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                 [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
             };
             utils.parserOK = ^(NSString *string)
             {
                 NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
                 NSError *error;
                 
                 NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                 NSDictionary *dic = table[0];
                 NSString *count = [dic objectForKey:@"Column1"];
                 if([count intValue] > 0)
                 {
                     if (hud2) {
                         [hud2 hide:YES];
                     }
                     [Tool showCustomHUD:@"已存在该保养记录,不能重复提交" andView:self.view andImage:nil andAfterDelay:1.2f];
                     self.navigationItem.rightBarButtonItem.enabled = YES;
                     return;
                 }
                 else
                 {
                     [self updateImg];
                 }
             };
             
             [utils stringFromparserXML:operation.responseString target:@"string"];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if (hud2) {
                 [hud2 hide:YES];
             }
             self.navigationItem.rightBarButtonItem.enabled = YES;
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         }];
    }
    else
    {
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
    
}

- (void)updateImg
{
    if([self.servcetype_field.text isEqualToString:@"年4次保养"])
    {
        for(NSString *key in imgDic)
        {
            UIImage *imgbegin = [[UIImage alloc] init];
            imgbegin = nil;
            imgbegin = imgDic[key];
            
            if(imgbegin)
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
                    project = self.img4_label.text;
                }
                else if([key isEqualToString:@"5"])
                {
                    project = self.img5_label.text;
                }
                else if([key isEqualToString:@"6"])
                {
                    project = self.img6_label.text;
                }
                else if([key isEqualToString:@"7"])
                {
                    project = self.img7_label.text;
                }
                else if([key isEqualToString:@"8"])
                {
                    project = self.img8_label.text;
                }
                else if([key isEqualToString:@"9"])
                {
                    project = self.img9_label.text;
                }
                NSString *reName = [[NSString alloc] init];
                reName = nil;
                reName = [NSString stringWithFormat:@"%@%@%i.jpg",project,[Tool getCurrentTimeStr:@"yyyy-MM-dd-hh:mm"],y];
                
                BOOL isOK = [self upload:imgbegin oldName:reName Index:[key intValue]];
                if(!isOK)
                {
                    if (hud2) {
                        [hud2 hide:YES];
                    }
                    [Tool showCustomHUD:@"图片上传失败..." andView:self.view andImage:nil andAfterDelay:1.2f];
                    return;
                }
            }
        }
    }
    else
    {
        //跳过第一个
        for(int i = 1; i < imgArray.count; ++i)
        {
            UIImage *img = [[UIImage alloc] init];
            img = imgArray[i];
            int y = (arc4random() % 501) + 500;
            
            NSString *reName = [NSString stringWithFormat:@"%@%@%i.jpg",self.serviceproject_field.text,[Tool getCurrentTimeStr:@"yyyy-MM-dd-hh:mm"],y];
            BOOL isOK = [self upload:img oldName:reName Index:-1];
            if(!isOK)
            {
                if (hud2) {
                    [hud2 hide:YES];
                }
                [Tool showCustomHUD:@"图片上传失败..." andView:self.view andImage:nil andAfterDelay:1.2f];
                return;
            }
        }
    }
    
    [self insertData];
}

- (BOOL)upload:(UIImage *)img oldName:(NSString *)reName Index:(NSInteger)index;
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
            if([response rangeOfString:@"UploadFile"].length > 0)
            {
                NSString *string = [NSString stringWithFormat:@"/UploadFile/%@/", [Tool getCurrentTimeStr:@"yyyyMMdd"]];
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
                    NSString *response2 = [tworequest responseString];
                    
                    //                    if([response containsString:@"true"])
                    if([response2 rangeOfString:@"true"].length > 0)
                    {
                        isOK = YES;
                        if ([self.servcetype_field.text isEqualToString:@"年4次保养"])
                        {
                            switch (index)
                            {
                                case 1:
                                    matnRec.allfilename = [NSString stringWithFormat:@"|%@",fileName];
                                    
                                    break;
                                case 2:
                                    matnRec.allfilename02 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 3:
                                    matnRec.allfilename03 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 4:
                                    matnRec.allfilename04 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 5:
                                    matnRec.allfilename05 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 6:
                                    matnRec.allfilename06 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 7:
                                    matnRec.allfilename07 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 8:
                                    matnRec.allfilename08 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                                case 9:
                                    matnRec.allfilename09 = [NSString stringWithFormat:@"|%@",fileName];
                                    break;
                            }
                        }
                        else
                        {
                            matnRec.allfilename = [NSString stringWithFormat:@"%@|%@",matnRec.allfilename,fileName];
                        }
                    }
                }
            }
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
    NSString *sql = [NSString stringWithFormat:@"insert into TB_CUST_ProjInf_MatnRec(Proj_ID,Exec_Man,Exec_Date,AirCondUnit_Mode,OutFact_Num,Type,Project,Uploader,UploadTime,allfilename,allfilename02,allfilename03,allfilename04,allfilename05,allfilename06,allfilename07,allfilename08,allfilename09) values('%@','%@','%@','%@','%@','%@','%@','%@',getdate(),'%@','%@','%@','%@','%@','%@','%@','%@','%@')",app.depart.PROJ_ID,self.enginer_label.text,self.servicetime_field.text,self.engine_no_label.text,self.chucang_no_label.text,self.servcetype_field.text,self.serviceproject_field.text,self.uploador_label.text,matnRec.allfilename,matnRec.allfilename02,matnRec.allfilename03,matnRec.allfilename04,matnRec.allfilename05,matnRec.allfilename06,matnRec.allfilename07,matnRec.allfilename08,matnRec.allfilename09];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        NSLog(response);
        if (hud2) {
            [hud2 hide:YES];
        }
        if([response rangeOfString:@"true"].length > 0)
        {
            [Tool showCustomHUD:@"上传成功" andView:self.view andImage:nil andAfterDelay:1.2f];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_WeiXiuListReLoad" object:nil];
            [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
        }
        else
        {
            [Tool showCustomHUD:@"上传失败" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
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
        NSArray *items = @[ @"年4次保养",@"异常处理",@"巡视",@"机房管理"];
        [SGActionView showSheetWithTitle:@"请选择服务类型:"
                              itemTitles:items
                           itemSubTitles:nil
                           selectedIndex:selectedServiceTypeIndex
                          selectedHandle:^(NSInteger index){
                              selectedServiceTypeIndex = index;
                              self.servicetime_field.text = @"";
                              textField.text = items[index];
                              if(index == 0)
                              {
                                  matnRec.Type = @"年4次保养";
                                  [imgDic removeAllObjects];
                                  [imgArray removeAllObjects];
                                  [self.imgCollectionView reloadData];
                                  self.imgCollectionView.hidden = YES;
                                  self.imgContain_view.hidden = NO;
                                  NSDateComponents *datec = [Tool getCurrentYear_Month_Day];
                                  NSInteger month = [datec month];
                                  //年1次保养
                                  if (month >= 1 && month < 4)
                                  {
                                      self.serviceproject_field.text = @"年1次保养";
                                      
                                      self.img1_label.text = @"蒸发器开盖检查";
                                      self.img2_label.text = @"吸收器、冷凝器开盖检查";
                                      self.img3_label.text = @"机组外观";
                                      self.img4_label.text = @"售后服务单";
                                      self.img5_view.hidden = YES;
                                      self.img6_view.hidden = YES;
                                      self.img7_view.hidden = YES;
                                      self.img8_view.hidden = YES;
                                      self.img9_view.hidden = YES;
                                      
                                      self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.img5_view.frame.origin.y + self.img5_view.frame.size.height + 460);
                                  }
                                  //年2次保养
                                  else if (month >= 4 && month < 7)
                                  {
                                      self.serviceproject_field.text = @"年2次保养";
                                      self.img1_label.text = @"冷却塔检查检查";
                                      self.img2_label.text = @"烟管";
                                      self.img3_label.text = @"油泵过滤器清洗";
                                      self.img4_label.text = @"点火电极清理";
                                      self.img5_label.text = @"燃料过滤器清洗";
                                      self.img6_label.text = @"软水器";
                                      self.img7_label.text = @"靶片长度";
                                      self.img8_label.text = @"售后服务单";
                                      self.img9_view.hidden = YES;
                                      self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.img9_view.frame.origin.y + self.img9_view.frame.size.height + 460);
                                  }
                                  //年3次保养
                                  else if (month >= 7 && month < 10)
                                  {
                                      self.serviceproject_field.text = @"年3次保养";
                                      self.img1_label.text = @"盐箱盐量";
                                      self.img2_label.text = @"水质药剂";
                                      self.img3_label.text = @"烟管结垢";
                                      self.img4_label.text = @"冷却塔布水";
                                      self.img5_label.text = @"冷却塔填料";
                                      self.img6_label.text = @"售后服务单";
                                      
                                      self.img7_view.hidden = YES;
                                      self.img8_view.hidden = YES;
                                      self.img9_view.hidden = YES;
                                      self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.img6_view.frame.origin.y + self.img6_view.frame.size.height + 460);
                                  }
                                  //年4次保养
                                  else if (month >= 10 && month < 13)
                                  {
                                      self.serviceproject_field.text = @"年4次保养";
                                      self.img1_label.text = @"高发液位";
                                      self.img2_label.text = @"烟管检查";
                                      self.img3_label.text = @"热水器铜管";
                                      self.img4_label.text = @"燃料过滤器清洗";
                                      self.img5_label.text = @"油泵过滤器清洗";
                                      self.img6_label.text = @"雾化盘清理";
                                      self.img7_label.text = @"风轮清理";
                                      self.img8_label.text = @"主机水侧排水";
                                      self.img9_label.text = @"售后服务单";
                                      self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.img9_view.frame.origin.y + self.img9_view.frame.size.height + 460);
                                  }
                                  
                                  self.imgContain_view.userInteractionEnabled = YES;
                                  self.img6_view.userInteractionEnabled = YES;
                                  self.img6_button.enabled = YES;
                                  self.serviceproject_field.enabled = NO;
                              }
                              //异常处理
                              else if (index == 1)
                              {
                                  matnRec.Type = @"异常处理";
                                  self.imgContain_view.hidden = YES;
                                  [imgDic removeAllObjects];
                                  [imgArray removeAllObjects];
                                  [imgArray addObject:[UIImage imageNamed:@"camera_tag"]];
                                  [self reSizeCollectionView];
                                  [self.imgCollectionView reloadData];
                                  self.imgCollectionView.hidden = YES;
                                  
                                  self.serviceproject_field.enabled = YES;
                                  self.serviceproject_field.text = @"燃烧机";
                                  self.servcetype_field.text = @"异常处理";
                                  serviceProjects = @[@"燃烧机",@"真空",@"电器控制",@"水系统",@"其它"];
                                  
                                  self.imgCollectionView.hidden = NO;
                              }
                              //巡视
                              else if (index == 2)
                              {
                                  matnRec.Type = @"巡视";
                                  self.imgContain_view.hidden = YES;
                                  [imgDic removeAllObjects];
                                  [imgArray removeAllObjects];
                                  [imgArray addObject:[UIImage imageNamed:@"camera_tag"]];
                                  [self reSizeCollectionView];
                                  [self.imgCollectionView reloadData];
                                  self.serviceproject_field.enabled = YES;
                                  self.serviceproject_field.text = @"巡视";
                                  self.servcetype_field.text = @"巡视";
                                  serviceProjects = @[@"巡视"];
                                  self.imgCollectionView.hidden = NO;
                              }
                              //机房管理
                              else if (index == 3)
                              {
                                  matnRec.Type = @"机房管理";
                                  self.imgContain_view.hidden = YES;
                                  [imgDic removeAllObjects];
                                  [imgArray removeAllObjects];
                                  [imgArray addObject:[UIImage imageNamed:@"camera_tag"]];
                                  [self reSizeCollectionView];
                                  [self.imgCollectionView reloadData];
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
        hsdpvc.delegate = self;
        if (serviceDate) {
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
    NSInteger size = (imgArray.count)/3;
    
    NSInteger height = size * 70 + 120;
    
    float x = self.imgCollectionView.frame.origin.x;
    float y = self.imgCollectionView.frame.origin.y;
    float width = self.imgCollectionView.frame.size.width;
    
    //调整网格布局高度
    self.imgCollectionView.frame = CGRectMake(x, y, width, height);
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.imgCollectionView.frame.origin.y + self.imgCollectionView.frame.size.height + 150);
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
    UIImage *image = [imgArray objectAtIndex:[indexPath row]];
    [cell bindImg:(UIImage *)image andIndex:indexPath.row];
    
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
        choiceSheet.tag = 1;
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
    NSDateComponents *datec = [Tool getCurrentYear_Month_Day];
    NSInteger year = [datec year];
    
    if ([self.servcetype_field.text isEqualToString:@"年4次保养"])
    {
        NSString *start = nil;
        NSString *end = nil;
        
        if ([self.serviceproject_field.text isEqualToString:@"年1次保养"])
        {
            start = [NSString stringWithFormat:@"%li-01-01",year];
            end = [NSString stringWithFormat:@"%li-04-01",year];
        }
        else if ([self.serviceproject_field.text isEqualToString:@"年2次保养"])
        {
            start = [NSString stringWithFormat:@"%li-04-01",year];
            end = [NSString stringWithFormat:@"%li-07-01",year];
        }
        else if ([self.serviceproject_field.text isEqualToString:@"年3次保养"])
        {
            start = [NSString stringWithFormat:@"%li-07-01",year];
            end = [NSString stringWithFormat:@"%li-10-01",year];
        }
        else if ([self.serviceproject_field.text isEqualToString:@"年4次保养"])
        {
            start = [NSString stringWithFormat:@"%li-10-01",year];
            end = [NSString stringWithFormat:@"%li-01-01",year+1];
        }
        
        int tag = [Tool compareOneDay:targetDate withAnotherDay:self.uploadtime_label.text];
        if(tag == 0 || tag == -1)
        {
            int tag = [Tool compareOneDay:targetDate withAnotherDay:start];
            //如果为0则两个日期相等,如果为1则服务时间大于起始时间
            if(tag == 0 || tag == 1)
            {
                int tag = [Tool compareOneDay:targetDate withAnotherDay:end];
                //如果为0则两个日期相等,如果为-1则服务时间小于起始时间
                if(tag == 0 || tag == -1)
                {
                    self.servicetime_field.text = targetDate;
                }
                else
                {
                    //                [Tool showCustomHUD:[NSString stringWithFormat:@"服务时间必须在%@到%@之间",start,end] andView:self.view andImage:nil andAfterDelay:3.8f];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示:" message:[NSString stringWithFormat:@"服务时间必须在%@到%@之间",start,end] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    alertView.tag = -10;
                    [alertView show];
                    return;
                }
            }
            else
            {
                //            [Tool showCustomHUD:[NSString stringWithFormat:@"服务时间必须在%@到%@之间",start,end] andView:self.view andImage:nil andAfterDelay:3.8f];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示:" message:[NSString stringWithFormat:@"服务时间必须在%@到%@之间",start,end] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                alertView.tag = -10;
                [alertView show];
                return;
            }
        }
        else
        {
            [Tool showCustomHUD:@"服务时间必须小于上传时间" andView:self.view andImage:nil andAfterDelay:3.8f];
            return;
        }
    }
    else
    {
        int tag = [Tool compareOneDay:targetDate withAnotherDay:self.uploadtime_label.text];
        //如果为0则两个日期相等,如果为-1则服务时间小于于起始时间
        if(tag == 0 || tag == -1)
        {
            self.servicetime_field.text = targetDate;
        }
        else
        {
            [Tool showCustomHUD:@"服务时间必须小于上传时间" andView:self.view andImage:nil andAfterDelay:3.8f];
            return;
        }
    }
    serviceDate = date;
}
//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker did dismiss with %lu", method);
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker will dismiss with %lu", method);
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
             if (hud) {
                 [hud hide:YES];
             }
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
                          if (hud) {
                              [hud hide:YES];
                          }
                          [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                          [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                      };
                      utils.parserOK = ^(NSString *string)
                      {
                          if (hud) {
                              [hud hide:YES];
                          }
                          NSString *timeStr = [string substringToIndex:[string rangeOfString:@" "].location];
                          self.uploadtime_label.text = timeStr;
                      };
                      
                      [utils stringFromparserXML:operation.responseString target:@"string"];
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                  {
                      if (hud) {
                          [hud hide:YES];
                      }
                      [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                      [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                      
                  }];
             }
             else
             {
                 if (hud) {
                     [hud hide:YES];
                 }
                 [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
                 [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
             }
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (hud) {
             [hud hide:YES];
         }
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)imgChoiceAction:(id)sender
{
    targetImgBtn = nil;
    targetImgBtn = sender;
    //如果存在图片
    if([imgDic objectForKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"修改",@"取消", nil];
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
            [targetImgBtn setImage:[UIImage imageNamed:@"camera_tag"] forState:UIControlStateNormal];
            [imgDic removeObjectForKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]];
        }
        else
        {
            [imgArray removeObjectAtIndex:alertView.tag];
            [self.imgCollectionView reloadData];
        }
    }
    else if(buttonIndex == 1)
    {
        
        if(alertView.tag != -11)
        {
            return;
        }
        
        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        cameraSheet.tag = 0;
        [cameraSheet showInView:self.view];
        
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
        //        controller.pickCount = 9;
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
         if(targetImgBtn)
         {
             
             [targetImgBtn setImage:tImg forState:UIControlStateNormal];
             [imgDic removeObjectForKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]];
             [imgDic setObject:tImg forKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]];
         }
         else
         {
             [imgArray addObject:tImg];
             [self reSizeCollectionView];
             [self.imgCollectionView reloadData];
         }
     }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - IQAssetsPickerControllerDelegate
//- (void)assetsPickerController:(IQAssetsPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info
//{
//    NSMutableArray *views = [[NSMutableArray alloc] initWithArray:[controller.navigationController viewControllers]];
//    [views removeLastObject];
//    controller.navigationController.viewControllers = views;
//    [controller.navigationController popViewControllerAnimated:YES];
//    if(info)
//    {
//        NSArray *imgd = info[@"IQMediaTypeImage"];
//        for(int i = 0; i < imgd.count; ++i)
//        {
//            NSDictionary *imgdic = imgd[i];
//            UIImage *img = imgdic[@"IQMediaImage"];
//            if(img)
//            {
//                UIImage *smallImage = [self imageByScalingToMaxSize:img];
//                NSData *imageData = UIImageJPEGRepresentation(smallImage,0.8f);
//                img = [UIImage imageWithData:imageData];
//                if(targetImgBtn)
//                {
//
//                    [targetImgBtn setImage:img forState:UIControlStateNormal];
//                    //                    [imgDic setObject:img forKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]];
//                    [imgDic removeObjectForKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]];
//                    [imgDic setObject:img forKey:[NSString stringWithFormat:@"%li",targetImgBtn.tag]];
//                }
//                else
//                {
//                    [imgArray addObject:img];
//                    [self reSizeCollectionView];
//                    [self.imgCollectionView reloadData];
//                }
//            }
//        }
//    }
//
//    targetImgBtn = nil;
//}
//
//- (void)assetsPickerControllerDidCancel:(IQAssetsPickerController *)controller
//{
//
//}

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
