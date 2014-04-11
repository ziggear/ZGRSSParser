//
//  RSSParser.h
//  XMLParser
//
//  Created by ziggear on 14-4-11.
//  Copyright (c) 2014年 ziggear. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZGRSSParserDelegate;

@interface ZGRSSParser : NSObject
@property id<ZGRSSParserDelegate> delegate;
- (id) initWithFeedURL:(NSURL *)feedURL;
- (void) startParseAsync;
@end

@protocol ZGRSSParserDelegate <NSObject>
@optional
- (void)parser:(ZGRSSParser *)parser didParseItem:(NSDictionary *)item;
- (void)parser:(ZGRSSParser *)parser finishParseWithItems:(NSArray *)items;
@end

