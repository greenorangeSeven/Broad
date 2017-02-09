//
//  SecurityUpdateView.m
//  Broad
//
//  Created by Seven on 16/12/21.
//  Copyright © 2016年 greenorange. All rights reserved.
//

#import "SecurityUpdateView.h"
#import "HSDatePickerViewController.h"
#import "EnginUnit.h"
#import "SGActionView.h"
#import "SecurityInfo.h"
#import "RepairImgCell.h"
#import "Img.h"

#define ORIGINAL_MAX_WIDTH 540.0f

@interface SecurityUpdateView ()<UICollectionViewDataSource, UICollectionViewDelegate,UITextFieldDelegate,HSDatePickerViewControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    SecurityInfo *newSecurity;
    
    NSInteger selectedServiceprojectIndex;
    
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
    
    NSString *sysTimeStr;
    NSString *currentMonthDayStr;
}

@end

@implementation SecurityUpdateView

- (void)viewDidLoad {
    [super viewDidLoad];
    newSecurity = [[SecurityInfo alloc] init];
    [newSecurity initWithSecurity:self.security];
    
    fromCamera = NO;
    haveUploadImage = NO;
    
    deleteImgStr = @"";
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
    
    self.imgCollectionView.delegate = self;
    self.imgCollectionView.dataSource = self;
    
    Img *img = [[Img alloc] init];
    img.img = [UIImage imageNamed:@"camera_tag"];
    [newSecurity.imgList insertObject:img atIndex:0];
    
    [self.imgCollectionView registerClass:[RepairImgCell class] forCellWithReuseIdentifier:@"RepairImgCell"];
    
    [self bindData];
    [self initData];
    
    newsAllfilename = self.security.allfilename;
    
    self.serviceproject_field.delegate = self;
    self.serviceproject_field.tag = 1;
    
    self.servicetime_field.delegate = self;
    self.servicetime_field.tag = 2;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    self.enginer_label.text = app.depart.Duty_Engineer;
    self.uploador_label.text = app.userinfo.UserName;
}

-(void) bindData
{
    [self.imgCollectionView reloadData];
    
    self.enginer_label.text = newSecurity.Exec_Man;
    self.uploador_label.text = newSecurity.Uploader;
    self.uploadtime_label.text = newSecurity.UploadTime;
    self.serviceproject_field.text = newSecurity.Project;
    
    
    if (newSecurity.Exec_Date.length > 0)
    {
        NSString *timeStr = newSecurity.Exec_Date;
        if([newSecurity.Exec_Date rangeOfString:@" "].length > 0)
        {
            timeStr = [newSecurity.Exec_Date substringToIndex:[newSecurity.Exec_Date rangeOfString:@" "].location];
        }
        self.servicetime_field.text = timeStr;
        //        if(newSecurity.imgList.count > 0)
        //        {
        //            [self.imgCollectionView reloadData];
        //        }
    }
}

- (void)initData
{
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
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
//             NSString *timeStr = [string substringToIndex:[string rangeOfString:@" "].location];
             self.uploadtime_label.text = string;
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

- (void)add
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    NSString *project = self.serviceproject_field.text;
    NSString *time = self.servicetime_field.text;
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
    //跳过第一个
    for(int i = 1; i < newSecurity.imgList.count; ++i)
    {
        Img *img = newSecurity.imgList[i];
        if(img.img)
        {
            int y = (arc4random() % 501) + 500;
            
            NSString *reName = [NSString stringWithFormat:@"%@%@%iI.jpg",self.serviceproject_field.text,[Tool getCurrentTimeStr:@"yyyy-MM-dd-HHmmss"],y];
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
    
    [self updateData];
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
                        
                        if(newsAllfilename == nil || [newsAllfilename isEqualToString:@"null"])
                        {
                            newsAllfilename = @"";
                        }
                        newSecurity.allfilename = [NSString stringWithFormat:@"%@|%@",newSecurity.allfilename,fileName];
                        newsAllfilename = [NSString stringWithFormat:@"%@|%@",newsAllfilename,fileName];
                        newsAllfilename = [newsAllfilename stringByReplacingOccurrencesOfString:@"null" withString:@""];
                        
                    }
                }
            };
            
            [utils stringFromparserXML:response target:@"string"];
        }
    }
    
    return isOK;
}

- (void)updateData
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    NSString *sql = @"";
    
    sql = [NSString stringWithFormat:@"update Tb_CUST_ProjInf_SecurityMgmt set UploadTime ='%@', Exec_Date='%@', Project='%@',allfilename='%@' where ID='%@'", self.uploadtime_label.text, self.servicetime_field.text,self.serviceproject_field.text,newsAllfilename,newSecurity.ID];
    if([newsAllfilename isEqualToString:@"null"])
    {
        sql = [NSString stringWithFormat:@"update Tb_CUST_ProjInf_SecurityMgmt set UploadTime ='%@', Exec_Date='%@',Project='%@',allfilename=%@ where ID='%@'",self.uploadtime_label.text,self.servicetime_field.text,self.serviceproject_field.text,newsAllfilename,newSecurity.ID];
        newsAllfilename = @"";
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
            [self writeLog];
        };
        
        [utils stringFromparserXML:response target:@"string"];
    }
}

- (void)writeLog
{
    //写日志
    NSString *ip = [Tool getIPAddressIPv4:YES];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    Depart *depart = app.depart;
    UserInfo *user = app.userinfo;
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'insert into [ERPRiZhi] (UserName,Operation,Plate,ProjName,DoSomething,IpStr) values (@UserName,@Operation,@Plate,@ProjName,@DoSomething,@IpStr);select @@IDENTITY',N'@UserName varchar(50),@Operation varchar(20),@Plate varchar(100),@ProjName varchar(500),@DoSomething varchar(1000),@IpStr varchar(50)',@UserName='%@',@Operation='修改',@Plate='安全管理(%@)',@ProjName='%@',@DoSomething='工程师修改(中文app:IOS);附件:%@',@IpStr='%@'", user.UserName, self.serviceproject_field.text, depart.PROJ_Name, newSecurity.allfilename, ip];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        if([response rangeOfString:@"true"].length > 0)
        {
            [Tool showCustomHUD:@"保存成功" andView:self.view andImage:nil andAfterDelay:1.2f];
            newSecurity.UploadTime = self.uploadtime_label.text;
            newSecurity.Exec_Date = self.servicetime_field.text;
            newSecurity.allfilename = newsAllfilename;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"securityNotifire" object:nil userInfo:[NSDictionary dictionaryWithObject:newSecurity forKey:@"security"]];
            
            [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
        }
        else
        {
            [Tool showCustomHUD:@"保存失败" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}

//服务类型、项目、时间等输入框不允许弹出输入法界面
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //服务类型
    if(textField.tag == 1)
    {
        NSArray *items = @[ @"技改开工",@"外包开工",@"外协开工"];
        [SGActionView showSheetWithTitle:@"请选择服务项目:"
                              itemTitles:items
                           itemSubTitles:nil
                           selectedIndex:selectedServiceprojectIndex
                          selectedHandle:^(NSInteger index){
                              self.serviceproject_field.text = @"";
                              textField.text = items[index];
                              
                          }];
    }
    else if(textField.tag == 2)
    {
        HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
        selectTimeIndex = textField.tag;
        hsdpvc.delegate = self;
        if (serviceDate) {
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
    int tag = [Tool compareOneDay:targetDate withAnotherDay:self.uploadtime_label.text];
    //如果为0则两个日期相等,如果为-1则服务时间小于于起始时间
    if(tag == 0 || tag == -1)
    {
        self.servicetime_field.text = targetDate;
    }
    else
    {
        [Tool showCustomHUD:@"服务时间不能超过当前时间" andView:self.view andImage:nil andAfterDelay:3.8f];
        return;
    }
    serviceDate = date;
}

//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker did dismiss with %lu", method);
    if(method == 1)
    {
        self.servicetime_field.text = @"";
    }
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker will dismiss with %lu", method);
}

#pragma mark - 图片集合
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger count = newSecurity.imgList.count;
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
    
    Img *img = [newSecurity.imgList objectAtIndex:[indexPath row]];
    
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
    Img *img = [newSecurity.imgList objectAtIndex:indexRow];
    if(indexRow == 0)
    {
        if([newSecurity.imgList count] >= 5)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"图片文件最多支持4张!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = -10;
            [alert show];
            return;
        }
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
        //        if (timeCha > 1.0) {
        //            [Tool showCustomHUD:@"附件超过24小时，不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
        //            return;
        //        }
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
        //        alert.tag = indexPath.row;
        //        [alert show];
        if(img.fileName != nil)
        {
            [self checkImgUploadTime:img.fileName andImgTag:indexPath.row];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
            alert.tag = indexPath.row;
            [alert show];
        }
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
        [utils stringFromparserXML:response target:@"string"];
    }
}

- (double)intervalSinceNow: (NSString *) theDate
{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate *nowdate=[date dateFromString:self.uploadtime_label.text];
    NSTimeInterval now=[nowdate timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
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
        Img *img = [newSecurity.imgList objectAtIndex:alertView.tag];
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
        [newSecurity.imgList removeObjectAtIndex:alertView.tag];
        [self.imgCollectionView reloadData];
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
         
         
         Img *tem = [[Img alloc] init];
         tem.img = tImg;
         [newSecurity.imgList addObject:tem];
         [self.imgCollectionView reloadData];
         
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
