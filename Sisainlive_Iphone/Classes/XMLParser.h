//
//  XMLParser.h
//  sisain
//
//  Created by snow leopard on 10. 7. 20..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMLParser;

@protocol XMLParserDelegate <NSObject>

@optional

@end

@interface XMLParser : NSObject <NSXMLParserDelegate> {
@private
    id <XMLParserDelegate> delegate;
	NSMutableString *currentString;
	BOOL didAbortParsing;
	BOOL storingCharacters;
	NSInteger postTotal;
	NSMutableDictionary *xmlDictionnary;

	NSMutableDictionary *coordsDictionnary;
	NSMutableArray *coordsArray;

	
	NSMutableArray *itemArray;
	NSMutableDictionary *itemDictionnary;
	NSMutableArray *portraitObjects;
	NSMutableArray *landscapeObjects;
	NSMutableString *currentStrigValue;
	BOOL currentIsPortrait;
	
	NSInteger count;
}

@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, assign) NSInteger postTotal;
@property (nonatomic, retain) NSMutableArray *landscapeObjects;
@property (nonatomic, retain) NSMutableArray *portraitObjects;
@property (nonatomic, assign) NSInteger portraitNumber;
@property (nonatomic, assign) NSInteger landscapeNumber;

- (void)start:(NSString *)number;
- (void)stop;

@end
