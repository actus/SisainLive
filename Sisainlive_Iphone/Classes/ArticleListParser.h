//
//  ArticleListParser.h
//  sisain
//
//  Created by snow leopard on 10. 8. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ArticleListContent,ArticleListParser;

// Protocol for the parser to communicate with its delegate.
@protocol ArticleListParserDelegate <NSObject>

@optional

// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(id)parser;
// Called by the parser in the case of an error.
- (void)parser:(id)parser didFailWithError:(NSError *)error;
// Called by the parser when one or more songs have been parsed. This method may be called multiple times.
- (void)parser:(id)parser didParseContents:(NSArray *)parsedContents;


// Called by the parser when parsing is finished.
- (void)MainparserDidEndParsingData:(id)parser;
// Called by the parser in the case of an error.
- (void)Mainparser:(id)parser didFailWithError:(NSError *)error;
// Called by the parser when one or more songs have been parsed. This method may be called multiple times.
- (void)Mainparser:(id)parser didParseContents:(NSArray *)parsedContents;


@end

/**
 기사리스트 XML파서
 */

@interface ArticleListParser : NSObject<NSXMLParserDelegate> {
    id <ArticleListParserDelegate> delegate;
	NSMutableArray	*parsedListArticles;
	NSMutableString *currentString;
	ArticleListContent *currentContent;
	
	BOOL sectionFlg;
	BOOL didAbortParsing;
	BOOL storingCharacters;
}
@property (nonatomic, assign) id <ArticleListParserDelegate> delegate;
@property (nonatomic, assign) BOOL sectionFlg;
@property (nonatomic, retain) NSMutableArray *parsedListArticles;
@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) ArticleListContent *currentContent;


- (void)start:(NSString *)url;
- (void)stop;
- (void)downloadStarted;
- (void)downloadEnded;
- (void)ArticleListParseEnded;
@end
