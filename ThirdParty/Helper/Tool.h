//
//  Tool.h
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonCryptor.h>
#import "RMMapper.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "Jastor.h"

@interface Tool : NSObject

+ (UIAlertView *)getLoadingView:(NSString *)title andMessage:(NSString *)message;

+ (UIColor *)getColorForCell:(int)row;
+ (UIColor *)getColorForMain;
+ (UIColor *)getColorForTitle;

+ (void)clearWebViewBackground:(UIWebView *)webView;

+ (void)doSound:(id)sender;

+ (NSString *)getBBSIndex:(int)index;

+ (void)toTableViewBottom:(UITableView *)tableView isBottom:(BOOL)isBottom;

+ (void)borderView:(UIView *)view;

+ (void)roundTextView:(UIView *)txtView andBorderWidth:(float)width andCornerRadius:(float)radius;

+ (void)roundView:(UIView *)view andCornerRadius:(float)radius;

+ (void)noticeLogin:(UIView *)view andDelegate:(id)delegate andTitle:(NSString *)title;

+ (NSString *)getCommentLoginNoticeByCatalog:(int)catalog;

+ (void)playAudio:(BOOL)isAlert;

+ (NSString *)intervalSinceNow: (NSString *) theDate;

+ (BOOL)isToday:(NSString *) theDate;

+ (int)getDaysCount:(int)year andMonth:(int)month andDay:(int)day;

+ (NSString *)getAppClientString:(int)appClient;

+ (void)ReleaseWebView:(UIWebView *)webView;

+ (UIColor *)getBackgroundColor;
+ (UIColor *)getCellBackgroundColor;

+ (BOOL)isValidateEmail:(NSString *)email;

+ (void)saveCache:(int)type andID:(int)_id andString:(NSString *)str;
+ (NSString *)getCache:(int)type andID:(int)_id;

+ (void)deleteAllCache;

+ (NSString *)getHTMLString:(NSString *)html;

+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud;
+ (void)showCustomHUD:(NSString *)text andView:(UIView *)view andImage:(NSString *)image andAfterDelay:(int)second;

+ (UIImage *) scale:(UIImage *)sourceImg toSize:(CGSize)size;

+ (CGSize)scaleSize:(CGSize)sourceSize;

+ (NSString *)getOSVersion;

+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom;

+ (void)CancelRequest:(ASIFormDataRequest *)request;

+ (NSDate *)NSStringDateToNSDate:(NSString *)string;

//获取当前时间的时间字符串
+ (NSString *)getCurrentTimeStr:(NSString *)formatter;
//时间戳转指定格式时间字符串
+ (NSString *)TimestampToDateStr:(NSString *)timestamp andFormatterStr:(NSString *)formatter;

+ (NSString *)GenerateTags:(NSMutableArray *)tags;

+ (void)saveCache:(NSString *)catalog andType:(int)type andID:(int)_id andString:(NSString *)str;
+ (NSString *)getCache:(NSString *)catalog andType:(int)type andID:(int)_id;
//保留数值几位小数
+ (NSString *)notRounding:(float)price afterPoint:(int)position;

+ (NSString* )databasePath;

//获取年月日
+ (NSDateComponents *)getCurrentYear_Month_Day;

//判断两个日期大小
+(int)compareOneDay:(NSString *)oneDay withAnotherDay:(NSString *)anotherDay;

//生成一个随机号码
+ (NSString *)generateTradeNO;

+ (BOOL) imageHasAlpha: (UIImage *) image;

//根据分隔符分隔日期，只得到日期
+ (NSString *)DateTimeRemoveTime:(NSString *)dateTime andSeparated:(NSString *)separated;

//UIImage转Base64
+ (NSString *) image2DataURL: (UIImage *) image;

//Base64转UIImage
+ (UIImage *) dataURL2Image: (NSString *) imgSrc;

//平台接口生成验签
+ (NSDictionary *)parseQueryString:(NSString *)query;
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params;
//平台接口生成验签Sign中文转UFT-8
+ (NSString *)serializeUFT8Sign:(NSString *)baseURL params:(NSDictionary *)params;
//平台接口生成验签Sign中文
+ (NSString *)serializeSign:(NSString *)baseURL params:(NSDictionary *)params;

//通过对象返回一个NSDictionary，键是属性名称，值是属性值。
+ (NSDictionary*)getObjectData:(id)obj;

//将对象转换成对象
+ (NSString *)readObjToJson:(id)obj;

//将getObjectData方法返回的NSDictionary转化成JSON
+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;

//将json字符串转换成对象
+ (id) readJsonToObj:(NSString *)json andObjClass:(Class)objClass;

//将json字典转换成对象
+ (id)readJsonDicToObj:(NSDictionary *)jsonDic andObjClass:(Class)objClass;

//将json集合转换成对象集合
+ (NSArray *)readJsonToObjArray:(NSArray *)jsonArray andObjClass:(Class)objClass;

//去掉字符串中的html标签
+(NSString *)filterHTML:(NSString *)html;

//string转unicode
+(NSString *)string2Unicode:(NSString *)str;

//unicode转string
+(NSString *)unicode2String:(NSString *)str;

@end
