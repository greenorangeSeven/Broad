//
//  XMLParserUtils.h
//  Broad
//
//  Created by 赵腾欢 on 15/8/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParserUtils : NSObject

@property (strong, nonatomic) void (^parserOK)(NSString *text);

@property (strong, nonatomic) void (^parserFail)();

- (void)stringFromparserXML:(NSString *)xmlStr target:(NSString *)tag;

@end
