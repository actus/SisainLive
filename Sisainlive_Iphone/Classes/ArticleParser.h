//
//  ArticleParser.h
//  sisain
//
//  Created by snow leopard on 10. 7. 27..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Article, ArticleParser;

// Protocol for the parser to communicate with its delegate.
@protocol ArticleParserDelegate <NSObject>

@optional
// Called by the parser when one or more songs have been parsed. This method may be called multiple times.
- (void)parser:(id)parser didParseContents:(NSArray *)parsedContents;

@end
/**
 기사취득 XML파서
 */

@interface ArticleParser : NSObject<NSXMLParserDelegate> {
@private
    id <ArticleParserDelegate> delegate;
	NSMutableArray	*parsedArticles;
	NSMutableString *currentString;
	Article *currentContent;
	
	BOOL didAbortParsing;
	BOOL storingCharacters;
	
}
@property (nonatomic, assign) id <ArticleParserDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *parsedArticles;
@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) Article *currentContent;

- (void)start:(NSString *)index;
- (void)stop;
- (void)downloadStarted;
- (void)downloadEnded;
- (void)parseEnded;

@end
