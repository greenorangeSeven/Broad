//
//  DES.m
//  DESDemo
//
//  Created by tekuba.net on 13-7-23.
//  Copyright (c) 2013年 tekuba.net. All rights reserved.
//  
//  DES algorithm has two modes:CBC and EBC. It is EBC mode if CCCrypt function used kCCOptionECBMode Parameter.Otherwise,It's CBC mode.
//  In ECB mode, you can encrypti and decrypt only 8 bytes data  each time。If the data extra 8 bytes, you need to call encryptDES/decryptDES multiple times.
//  

#import "DES.h"
#import <CommonCrypto/CommonCryptor.h>

static Byte iv[] = {'3','B','1','3','0','8','B','5'};//only Used for Cipher Block Chaining (CBC) mode,This is ignored if ECB mode is used
@implementation DES

/*DES encrypt*/
+(Byte *) encryptDES:(Byte *)srcBytes key:(NSString *)key useEBCmode:(BOOL)useEBCmode
{
    NSUInteger dataLength = strlen((const char*)srcBytes);
    Byte *encryptBytes = malloc(1024);
    memset(encryptBytes, 0, 1024);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          useEBCmode ? (kCCOptionPKCS7Padding | kCCOptionECBMode):kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          srcBytes	, dataLength,
                                          encryptBytes, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess)
    {
        NSLog(@"DES加密成功");
        return encryptBytes;
    }
    else
    {
        NSLog(@"DES加密失败");
        return nil;
    }
}

/*DES decrypt*/
+(Byte *) decryptDES:(Byte *)srcBytes key:(NSString *)key useEBCmode:(BOOL)useEBCmode
{
    NSUInteger dataLength = strlen((const char*)srcBytes);
    Byte *decryptBytes = malloc(1024);
    memset(decryptBytes, 0, 1024);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          useEBCmode ? (kCCOptionPKCS7Padding | kCCOptionECBMode):kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          srcBytes	, dataLength,
                                          decryptBytes, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess)
    {
        NSLog(@"DES解密成功");
        return decryptBytes;
    }
    else
    {
        NSLog(@"DES解密失败");
        return nil;
    }
}




@end
