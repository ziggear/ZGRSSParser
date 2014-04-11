//
//  RSSParser.m
//  XMLParser
//
//  Created by ziggear on 14-4-11.
//  Copyright (c) 2014年 ziggear. All rights reserved.
//

#import "ZGRSSParser.h"
@interface ZGRSSParser() <NSXMLParserDelegate>{
    NSXMLParser *parser;
    
    //temporary variables
    NSMutableDictionary *oneItem;
    NSMutableArray *postItems;
    NSString *innerString;
}
@end

@implementation ZGRSSParser
@synthesize delegate;
- (id) initWithFeedURL:(NSURL *)feedURL {
    if(self = [super init]){
        parser = [[NSXMLParser alloc] initWithContentsOfURL:feedURL];
        parser.delegate = self;
        [parser setShouldProcessNamespaces:NO];
    }
    return self;
}

- (void) startParseAsync {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        postItems = [NSMutableArray array];
        oneItem = [NSMutableDictionary dictionary];
        [parser parse];
    });
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"item"]) {
        oneItem = [NSMutableDictionary dictionary];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if([delegate respondsToSelector:@selector(parser:finishParseWithItems:)] && postItems != nil){
        [delegate parser:self finishParseWithItems:[NSArray arrayWithArray:postItems]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(oneItem) {
        innerString = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if([elementName isEqualToString:@"title"]) {
        [oneItem setObject:innerString forKey:@"title"];
        innerString = nil;
    }
    
    if([elementName isEqualToString:@"link"]) {
        [oneItem setObject:innerString forKey:@"link"];
        innerString = nil;
    }
    
    if([elementName isEqualToString:@"comments"]) {
        [oneItem setObject:innerString forKey:@"comments"];
        innerString = nil;
    }
    
    if([elementName isEqualToString:@"category"]) {
        if([oneItem objectForKey:@"category"] == nil){
            [oneItem setObject:innerString forKey:@"category"];
        } else if([oneItem objectForKey:@"tags"] == nil ) {
            NSMutableArray *tags = [NSMutableArray array];
            [tags addObject:innerString];
            [oneItem setObject:tags forKey:@"tags"];
        } else {
            NSMutableArray *tags = [oneItem objectForKey:@"tags"];
            [tags addObject:innerString];
        }
    }
    
    if([elementName isEqualToString:@"description"]) {
        [oneItem setObject:innerString forKey:@"description"];
    }
    
    if([elementName isEqualToString:@"content:encoded"]) {
        [oneItem setObject:innerString forKey:@"content"];
    }
    
    if([elementName isEqualToString:@"pubDate"]) {
        [oneItem setObject:innerString forKey:@"date"];
    }
    
    if([elementName isEqualToString:@"dc:creator"]) {
        [oneItem setObject:innerString forKey:@"author"];
    }
    
    if([elementName isEqualToString:@"item"]) {
        [postItems addObject:oneItem];
        if([delegate respondsToSelector:@selector(parser:didParseItem:)]){
            [delegate parser:self didParseItem:[NSDictionary dictionaryWithDictionary:oneItem]];
        }
        oneItem = nil;
    }
}

@end
