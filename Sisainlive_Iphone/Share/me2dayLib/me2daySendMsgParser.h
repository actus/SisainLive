//
//  me2daySendMsgParser.h
//  me2dayLib
//
//  Created by snow leopard on 10. 10. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "me2dayMsgContent.h"


// Protocol for the parser to communicate with its delegate.
@protocol me2daySendMsgParserDelegate <NSObject>
@optional
- (void)msgparser:(id)parser didParseContents:(NSArray *)parsedContents;
- (void)msgrequestFailed;
@end

@interface me2daySendMsgParser : NSObject<NSXMLParserDelegate> {

@private
	id <me2daySendMsgParserDelegate>delegate;
	
	NSMutableArray	*msgMuArray;
	NSMutableString *currentString;
	me2dayMsgContent *currentContent;
	BOOL didAbortParsing;
	BOOL storingCharacters;
	
}
@property (nonatomic, assign) id<me2daySendMsgParserDelegate>delegate;
@property (nonatomic, retain) NSMutableArray  *msgMuArray;
@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) me2dayMsgContent *currentContent;


- (void)sendMessage:(NSString *)aMsg atTag:(NSString *)aTag;


@end
