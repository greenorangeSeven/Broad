//
//  RongYeHandleView.h
//  Broad
//
//  Created by Seven on 17/2/7.
//  Copyright © 2017年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface RongYeHandleView : UIViewController<MWPhotoBrowserDelegate>
{
    NSMutableArray *_photos;
}
@property (nonatomic, retain) NSMutableArray *photos;

@property (copy, nonatomic) NSString *Mark;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *CUST_Name_field;

@property (weak, nonatomic) IBOutlet UITextField *Exec_Man_field;
@property (weak, nonatomic) IBOutlet UITextField *Exec_Date_field;
@property (weak, nonatomic) IBOutlet UITextField *OutFact_Num_field;
@property (weak, nonatomic) IBOutlet UITextField *AirCondUnit_Mode_field;
@property (weak, nonatomic) IBOutlet UITextField *ReceiveDate_field;
@property (weak, nonatomic) IBOutlet UITextField *HandleOpinion_field;

@property (weak, nonatomic) IBOutlet UITextField *HandleTime_field;
@property (weak, nonatomic) IBOutlet UITextField *LithiumByEngineer_field;
@property (weak, nonatomic) IBOutlet UITextField *Other_field;

@property (weak, nonatomic) IBOutlet UITextField *LiBr_field;
@property (weak, nonatomic) IBOutlet UILabel *LiBr_R_lb;

@property (weak, nonatomic) IBOutlet UITextField *Density_field;
@property (weak, nonatomic) IBOutlet UITextField *Temp_field;

@property (weak, nonatomic) IBOutlet UITextField *SolutionOutward_field;
@property (weak, nonatomic) IBOutlet UILabel *SolutionOutward_R_lb;

@property (weak, nonatomic) IBOutlet UITextField *PH_field;
@property (weak, nonatomic) IBOutlet UILabel *PH_R_lb;

@property (weak, nonatomic) IBOutlet UITextField *CU2_field;
@property (weak, nonatomic) IBOutlet UILabel *CU2_R_lb;

@property (weak, nonatomic) IBOutlet UITextField *Fe_field;
@property (weak, nonatomic) IBOutlet UILabel *Fe_R_lb;

@property (weak, nonatomic) IBOutlet UITextField *Licro4_field;
@property (weak, nonatomic) IBOutlet UILabel *Licro4_R_lb;

@property (weak, nonatomic) IBOutlet UITextField *Precipitation_field;
@property (weak, nonatomic) IBOutlet UILabel *Precipitation_R_lb;

@property (weak, nonatomic) IBOutlet UITextField *Cl_field;
@property (weak, nonatomic) IBOutlet UILabel *Cl_R_lb;

@property (weak, nonatomic) IBOutlet UITextField *Result_field;
@property (weak, nonatomic) IBOutlet UITextField *UploadTime1_field;
@property (weak, nonatomic) IBOutlet UIImageView *quyangfilename_image;
@property (weak, nonatomic) IBOutlet UILabel *hint_lable;
@property (weak, nonatomic) IBOutlet UITextField *Uploader1_field;

@property (weak, nonatomic) IBOutlet UILabel *Handle_label;
@property (weak, nonatomic) IBOutlet UIButton *Handle_button;

- (IBAction)imgChoiceAction:(id)sender;

@end
