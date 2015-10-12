//
//  XMLParserUtils.m
//  Broad
//
//  Created by 赵腾欢 on 15/8/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "XMLParserUtils.h"

@interface XMLParserUtils()<NSXMLParserDelegate>
{
    NSMutableString *currentElementContent;
    NSString *targetTag;
}

@end

@implementation XMLParserUtils

- (void)stringFromparserXML:(NSString *)xmlStr target:(NSString *)tag
{
    targetTag = tag;
    NSXMLParser *parse = [[NSXMLParser alloc] initWithData:[xmlStr dataUsingEncoding:NSUTF8StringEncoding]];
    parse.delegate = self;
    BOOL isOK = [parse parse];
    if(!isOK)
    {
        self.parserFail();
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElementContent = [[NSMutableString alloc] init];
}

//当解析器找到开始标记和结束标记之间的字符时，调用这个方法。
//解析器，从两个结点之间读取具体内容(可能不会一次就读取完,可能会多次调用该方法)
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentElementContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:targetTag])
    {
        self.parserOK(currentElementContent);
        return;
    }
    currentElementContent = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.parserFail();
}

//当解析器解析结束后，调用该方法
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

@end
