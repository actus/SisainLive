//
//  ArticleParser.m
//  sisain
//
//  Created by snow leopard on 10. 7. 27..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArticleParser.h"
#import "Article.h"
#import "Constants.h"
/**
 기사취득 XML파서
 */
@implementation ArticleParser
@synthesize delegate, currentString, currentContent, parsedArticles;

- (void)dealloc {
	[parsedArticles release];
    [super dealloc];
}


- (void)start:(NSString *)index {
	
	didAbortParsing = NO;
	self.parsedArticles = [NSMutableArray array];

	

	// 시물레이터안에 있는 파일을 가지고 실행(테스트를 위해서)

/*
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *xmlPath = [bundle pathForResource:@"testaa" ofType:@"xml"];
	//NSURL *urlBuf = [NSURL URLWithString:xmlPath];
	NSURL *urlBuf = [NSURL fileURLWithPath:xmlPath];
	[NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:urlBuf];
*/
	
	// xmlファイルがエラーになってしまったのでサンプルを利用して開発している中
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// テストがすべて終わったら、内容をまとめて報告する必要がある。
	//　■　xml形式の修正が必要。
	//　■　xmlデータの入力値が間違えている。修正必要
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:entry_url, index]];
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
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)downloadStarted {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)downloadEnded {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

static NSString *k_Entry			= @"entry";
static NSString *k_id	         	= @"id";
static NSString *k_description		= @"description";
static NSString *k_image			= @"image";
static NSString *k_category_id		= @"category_id";
static NSString *k_permalink		= @"permalink";
static NSString *k_title			= @"title";
static NSString *k_content			= @"content";



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
	if (didAbortParsing) {
		[parser abortParsing];
	}

	if ([elementName isEqualToString:k_Entry]) {
		self.currentContent = [[[Article alloc] init] autorelease];
	}
	else if ([elementName isEqualToString:k_id] 
			 || [elementName isEqualToString:k_category_id] 
			 || [elementName isEqualToString:k_permalink] 
			 || [elementName isEqualToString:k_title] 
			 || [elementName isEqualToString:k_content]
 			 || [elementName isEqualToString:k_description]
 			 || [elementName isEqualToString:k_image]) {
        [currentString setString:@""];
        storingCharacters = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:k_Entry]) {
        [self performSelectorOnMainThread:@selector(parsedArticle:) withObject:currentContent waitUntilDone:NO];
		// performSelectorOnMainThread: will retain the object until the selector has been performed
        // setting the local reference to nil ensures that the local reference will be released
        self.currentContent = nil;
    }
	else if ([elementName isEqualToString:k_id]) {
        currentContent.idnum = currentString;
    }
	else if ([elementName isEqualToString:k_category_id]) {
        currentContent.category_id = currentString;
    }
	else if ([elementName isEqualToString:k_permalink]) {
        currentContent.permalink = currentString;
    }
	else if ([elementName isEqualToString:k_title]) {
        currentContent.title = currentString;
    }
	else if ([elementName isEqualToString:k_content]) {
        currentContent.content = currentString;
    }
	else if ([elementName isEqualToString:k_description]) {
        currentContent.description = currentString;
    }
	else if ([elementName isEqualToString:k_image]) {
        currentContent.image = currentString;
    }
    storingCharacters = NO;
}


- (void)parsedArticle:(Article *)article {

    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	[self.parsedArticles addObject:article];

}

- (void)parserDidEndDocument:(NSXMLParser *)parser{

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (storingCharacters){
		[currentString appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
}

// XML파싱이 끝나면 취득한 값을 전송
- (void)parseEnded {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseContents:)] && [parsedArticles count] > 0) {
		[self.delegate parser:self didParseContents:parsedArticles];
	}
}

@end
