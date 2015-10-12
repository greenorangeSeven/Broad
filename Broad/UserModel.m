//
//  UserModel.m
//  zhxq
//
//  Created by Seven on 13-9-21.
//
//

#import "UserModel.h"
#import "AESCrypt.h"
#import "EGOCache.h"

@implementation UserModel

@synthesize topicTitle;
@synthesize topicContent;
@synthesize isNetworkRunning;

static UserModel * instance = nil;
+(UserModel *) Instance
{
    @synchronized(self)
    {
        if(nil == instance)
        {
            [self new];
            [instance getUserInfo];
        }
    }
    return instance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

-(void)saveIsLogin:(BOOL)_isLogin
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"isLogin"];
    [user setObject:_isLogin ? @"1" : @"0" forKey:@"isLogin"];
    [user synchronize];
}

-(BOOL)isLogin
{
    return self.userinfo ? YES:NO;
}

-(void)saveAccount:(NSString *)account andPwd:(NSString *)pwd
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [user removeObjectForKey:@"Account"];
    [user setObject:account forKey:@"Account"];
    
    [user removeObjectForKey:@"Password"];
    pwd = [AESCrypt encrypt:pwd password:@"pwd"];
    [user setObject:pwd forKey:@"Password"];
    
    [user synchronize];
}

-(NSString *)getPwd
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString * temp = [user objectForKey:@"Password"];
    return [AESCrypt decrypt:temp password:@"pwd"];
}

-(NSString *)getIOSGuid
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString * value = [settings objectForKey:@"guid"];
    if (value && [value isEqualToString:@""] == NO)
    {
        return value;
    }
    else
    {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString * uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        CFRelease(uuid);
        [settings setObject:uuidString forKey:@"guid"];
        [settings synchronize];
        return uuidString;
    }
}

-(void)saveUserInfo:(UserInfo *)userinfo
{
    self.userinfo = userinfo;
    EGOCache *cache = [EGOCache globalCache];
    [cache setObjectForSync:userinfo forKey:@"userinfo"];
}

-(UserInfo *)getUserInfo
{
    if(!self.userinfo)
    {
        EGOCache *cache = [EGOCache globalCache];
        self.userinfo = (UserInfo *)[cache objectForKey:@"userinfo"];
    }
    return self.userinfo;
}

-(void)logoutUser
{
    if(self.isLogin)
    {
        EGOCache *cache = [EGOCache globalCache];
        [cache removeCacheForKey:@"userinfo"];
        self.userinfo = nil;
    }
}

@end
