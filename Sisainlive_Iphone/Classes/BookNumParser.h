//
//  BookNumParser.h
//  sisain
//
//  Created by snow leopard on 10. 7. 29..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Book, BookNumParser;

@protocol BookNumParserDelegate<NSObject>

- (void)parser:(id)parser didParseContents:(NSArray *)parsedContents;

@end


@interface BookNumParser : NSObject<NSXMLParserDelegate> {
@private
	id<BookNumParserDelegate> delegate;
	NSMutableArray	*parsedBookNum;
	NSMutableString *currentString;
	Book *currentContent;
	BOOL didAbortParsing;
	BOOL storingCharacters;
	
}
@property (nonatomic, assign) id <BookNumParserDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *parsedBookNum;
@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) Book *currentContent;

- (void)start;
@end
