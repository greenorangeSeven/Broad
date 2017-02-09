//
//  RongYeHandleDetailView.m
//  Broad
//
//  Created by Seven on 17/2/9.
//  Copyright © 2017年 greenorange. All rights reserved.
//

#import "RongYeHandleDetailView.h"
#import "Img.h"

@interface RongYeHandleDetailView ()
{
    NSArray *imgArray;
}

@end

@implementation RongYeHandleDetailView

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
    
    [self initData];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData
{
    self.CUST_Name_field.text = self.solutionMgmt.CUST_Name;
    self.Exec_Man_field.text = self.solutionMgmt.Exec_Man;
    self.Exec_Date_field.text = [Tool DateTimeRemoveTime:self.solutionMgmt.Exec_Date andSeparated:@" "];
    self.UploadTime1_field.text = [Tool DateTimeRemoveTime:self.solutionMgmt.UploadTime1 andSeparated:@" "];
    self.Uploader1_field.text = self.solutionMgmt.Uploader1;
    self.OutFact_Num_field.text = self.solutionMgmt.OutFact_Num;
    self.AirCondUnit_Mode_field.text = self.solutionMgmt.AirCondUnit_Mode;
    self.ReceiveDate_field.text = [Tool DateTimeRemoveTime:self.solutionMgmt.ReceiveDate andSeparated:@" "];
    self.HandleOpinion_field.text = self.solutionMgmt.HandleOpinion;
    
    self.LiBr_field.text = self.solutionMgmt.LiBr;
    self.LiBr_R_lb.text = self.solutionMgmt.LiBrResult;
    self.Density_field.text = self.solutionMgmt.Density;
    self.Temp_field.text = self.solutionMgmt.Temp;
    self.SolutionOutward_field.text = self.solutionMgmt.SolutionOutward;
    self.SolutionOutward_R_lb.text = self.solutionMgmt.OutwardResult;
    self.PH_field.text = self.solutionMgmt.PH;
    self.PH_R_lb.text = self.solutionMgmt.PHResult;
    self.CU2_field.text = self.solutionMgmt.CU2;
    self.CU2_R_lb.text = self.solutionMgmt.CU2Result;
    self.Fe_field.text = self.solutionMgmt.Fe;
    self.Fe_R_lb.text = self.solutionMgmt.FeResult;
    self.Licro4_field.text = self.solutionMgmt.Licro4;
    self.Licro4_R_lb.text = self.solutionMgmt.Licro4Result;
    self.Precipitation_field.text = self.solutionMgmt.Precipitation;
    self.Precipitation_R_lb.text = self.solutionMgmt.PrecipitationResult;
    self.Cl_field.text = self.solutionMgmt.Cl;
    self.Cl_R_lb.text = self.solutionMgmt.ClResult;
    self.Result_field.text = self.solutionMgmt.Result;
    
    self.HandleTime_field.text = [Tool DateTimeRemoveTime:self.solutionMgmt.HandleTime andSeparated:@" "];
    self.LithiumByEngineer_field.text = self.solutionMgmt.LithiumByEngineer;
    self.Other_field.text = self.solutionMgmt.Other;

    NSString *imgurl = [NSString stringWithFormat:@"%@%@",self.solutionMgmt.allfilename1,self.solutionMgmt.allfilename];
    imgurl = [imgurl stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
//    imgurl = [imgurl stringByReplacingOccurrencesOfString:@"(" withString:@""];
//    imgurl = [imgurl stringByReplacingOccurrencesOfString:@")" withString:@""];
    [self getImg:imgurl];
}

- (void)getImg:(NSString *)imgurl
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
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
    if (self.solutionMgmt.allfilename1.length > 0)
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
    if (self.solutionMgmt.allfilename > 0)
    {
        Img *img = imgArray[index];
        [self.Handle_ImageView sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
        
        self.Handle_ImageView.tag = index;
        
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapClick:)];
        [self.Handle_ImageView addGestureRecognizer:imgTap];
        
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
