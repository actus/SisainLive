//
//  me2dayLoginCheckParser.h
//  me2dayLib
//
//  Created by snow leopard on 10. 10. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class	me2dayLoginContent,me2dayLoginCheckParser;
@protocol me2dayLoginCheckParserDelegate <NSObject>
@optional
- (void)parser:(id)parser didParseContents:(NSArray *)parsedContents;
- (void)requestFailed;
@end

@interface me2dayLoginCheckParser : NSObject<NSXMLParserDelegate> {

@private
    id <me2dayLoginCheckParserDelegate> delegate;
	
	me2dayLoginContent *Content;
	NSMutableString *currentString;
	NSMutableArray	*loginMuArray;
	me2dayLoginContent *currentContent;
	BOOL didAbortParsing;
	BOOL storingCharacters;
	BOOL loginfailed;
	
	
}
@property (nonatomic, assign) id <me2dayLoginCheckParserDelegate> delegate;
@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) NSMutableArray *loginMuArray;
@property (nonatomic, retain) me2dayLoginContent *currentContent;

- (void)loginCheckStart;

@end
