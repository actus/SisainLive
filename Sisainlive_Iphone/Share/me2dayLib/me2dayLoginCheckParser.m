//
//  me2dayLoginCheckParser.m
//  me2dayLib
//
//  Created by snow leopard on 10. 10. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "me2dayLoginContent.h"
#import "me2dayLoginCheckParser.h"
#import "me2dayLoginContent.h"
#import <CommonCrypto/CommonDigest.h>


// 미투데이 로그인 체크 URL
#define LOGINURL			@"http://me2day.net/api/noop?uid=%@&ukey=%@%@&akey=%@"


@implementation me2dayLoginCheckParser
@synthesize delegate;
@synthesize currentString;
@synthesize loginMuArray;
@synthesize currentContent;


- (void)dealloc {
	[loginMuArray release];
	[currentContent release];
    [super dealloc];
}

NSString* md5( NSString *str )
{
	
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString  stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4],
			result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12],
			result[13], result[14], result[15]
			];
	
}

- (void)loginCheckStart{

	didAbortParsing = NO;
	loginfailed		= NO;
	
	NSUserDefaults *me2dayContent = [NSUserDefaults standardUserDefaults];
	NSString *me2day_apikey  = [me2dayContent stringForKey:@"setApikey"];
	NSString *me2day_md5key  = [me2dayContent stringForKey:@"setMd5key"];
	NSString *me2day_Id		 = [me2dayContent stringForKey:@"me2dayId"];
	NSString *me2day_Pwd	 = [me2dayContent stringForKey:@"me2dayPwd"];

	
	self.loginMuArray = [NSMutableArray array];
	NSString *md5Content	 = [NSString stringWithFormat:@"%@%@",me2day_md5key,me2day_Pwd]; 
	NSString *md5value		 = md5(md5Content);
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:LOGINURL,me2day_Id,me2day_md5key,md5value,me2day_apikey]];
		
	[NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:url];
}


- (void)downloadAndParse:(NSURL *)url {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
	parser.delegate = self;
	self.currentString = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
	[parser parse];	
	[self performSelectorOnMainThread:@selector(parseEnded) withObject:nil waitUntilDone:NO];
    [parser release];
    self.currentString = nil;
    self.currentContent = nil;
	[pool release];
	
}

- (void)stop {
	didAbortParsing = YES;
}

- (void)downloadStarted {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
}

- (void)downloadEnded {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
}


static NSString *k_error			= @"error";
static NSString *k_code	         	= @"code";


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
	if (didAbortParsing) {
		[parser abortParsing];
	}
	
	if ([elementName isEqualToString:k_error]) {
		self.currentContent = [[[me2dayLoginContent alloc] init] autorelease];
	}
	else if ([elementName isEqualToString:k_code]) {
        [currentString setString:@""];
        storingCharacters = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:k_error]) {
        [self performSelectorOnMainThread:@selector(parsedArticle:) withObject:currentContent waitUntilDone:NO];
		// performSelectorOnMainThread: will retain the object until the selector has been performed
        // setting the local reference to nil ensures that the local reference will be released
        self.currentContent = nil;
    }
	else if ([elementName isEqualToString:k_code]) {
        currentContent.code = currentString;
    }
    storingCharacters = NO;
}

- (void)parsedArticle:(me2dayLoginContent *)article {
	
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	[self.loginMuArray addObject:article];
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
	
	//	NSLog(@">>parserDidEndDocument");
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (storingCharacters){
		[currentString appendString:string];
	}
}



//로그인 실패시에(관련된 데이터가 검색이 안되었으므로 파싱 에러가 출력되어 진다)
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	loginfailed = YES;
}


// XML파싱이 끝나면 취득한 값을 전송
- (void)parseEnded {
	
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);

	if (!loginfailed && self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseContents:)] && [loginMuArray count] > 0) {
		[self.delegate parser:self didParseContents:loginMuArray];
	}
	else {
		[self.delegate requestFailed];	
	}
	
}



@end
