//
//  UserModel.h
//  zhxq
//
//  Created by Seven on 13-9-21.
//
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface UserModel : NSObject

//话题缓存
@property (copy,nonatomic) NSString * topicTitle;
@property (copy,nonatomic) NSString * topicContent;

//用户信息
@property (strong, nonatomic) UserInfo *userinfo;

+(UserModel *) Instance;
+(id)allocWithZone:(NSZone *)zone;
-(void)saveIsLogin:(BOOL)_isLogin;
-(BOOL)isLogin;

//是否具备网络链接
@property BOOL isNetworkRunning;

-(void)saveAccount:(NSString *)account
             andPwd:(NSString *)pwd;

-(NSString *)getPwd;

-(UserInfo *)getUserInfo;

-(void)saveUserInfo:(UserInfo *)userinfo;

-(void)logoutUser;

-(NSString *)getIOSGuid;

@end
