//
//  ArticleListParser.m
//  sisain
//
//  Created by snow leopard on 10. 8. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArticleListParser.h"
#import "ArticleListContent.h"
#import "Constants.h"


/**
 기사리스트 XML파서
 */


@implementation ArticleListParser
@synthesize delegate;
@synthesize parsedListArticles;
@synthesize currentString;
@synthesize currentContent;
@synthesize sectionFlg;

- (void)dealloc {
    [super dealloc];
	[parsedListArticles release];
}


- (void)start:(NSString *)url{

	self.parsedListArticles = [NSMutableArray array];
	
	
/*
	// 시물레이터안에 있는 파일을 가지고 실행(테스트를 위해서)
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *xmlPath = [bundle pathForResource:@"list" ofType:@"xml"];
	NSURL *urlBuf = [NSURL fileURLWithPath:xmlPath];
	[NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:urlBuf];
*/
	
	//NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ArticleList_url, index]];
	
 	NSURL *urlBuf = [NSURL URLWithString:url];
	
	[NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:urlBuf];
	
}

- (void)stop {
	didAbortParsing = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)downloadAndParse:(NSURL *)url {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
	parser.delegate = self;
	self.currentString = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
	[parser parse];	
	[self performSelectorOnMainThread:@selector(ArticleListParseEnded) withObject:nil waitUntilDone:NO];
    [parser release];
    self.currentString = nil;
    self.currentContent = nil;
	
	[pool release];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (storingCharacters){
		[currentString appendString:string];
	}
}

- (void)downloadStarted {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)downloadEnded {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

static NSString *k_id			    = @"id";
static NSString *k_item			    = @"item";
static NSString *k_link				= @"link";
static NSString *k_title			= @"title";
static NSString *k_description		= @"description";
static NSString *k_image			= @"image";
static NSString *k_Limage			= @"Limage";
static NSString *k_pubDate			= @"pubDate";

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
	if (didAbortParsing) {
		[parser abortParsing];
	}
	if ([elementName isEqualToString:k_item]) {
		self.currentContent = [[[ArticleListContent alloc] init] autorelease];
	}
	else if ([elementName isEqualToString:k_link]){
        [currentString setString:@""];
        storingCharacters = YES;	
		currentContent.link_id = [attributeDict objectForKey:k_id];
	}
	else if ([elementName isEqualToString:k_link]
			 || [elementName isEqualToString:k_title] 
			 || [elementName isEqualToString:k_description] 
			 || [elementName isEqualToString:k_image] 
 			 || [elementName isEqualToString:k_Limage] 
			 || [elementName isEqualToString:k_pubDate] ) {
        [currentString setString:@""];
        storingCharacters = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:k_item]) {
        [self performSelectorOnMainThread:@selector(parsedListArticle:) withObject:currentContent waitUntilDone:NO];
		// performSelectorOnMainThread: will retain the object until the selector has been performed
        // setting the local reference to nil ensures that the local reference will be released
        self.currentContent = nil;
    }
	else if ([elementName isEqualToString:k_link]) {
        currentContent.link        = currentString;
    }
	else if ([elementName isEqualToString:k_title]) {
        currentContent.title       = currentString;
    }
	else if ([elementName isEqualToString:k_description]) {
        currentContent.description = currentString;
    }
	else if ([elementName isEqualToString:k_Limage]) {
        currentContent.Limage       = currentString;
    }
	else if ([elementName isEqualToString:k_image]) {
        currentContent.image       = currentString;
    }
	else if ([elementName isEqualToString:k_pubDate]) {
        currentContent.pubDate     = currentString;
    }
    storingCharacters = NO;
	
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
//	NSLog(@">>parseError:%@",parseError);
    // Handle errors as appropriate for your application.
	if (sectionFlg) {	
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(Mainparser:didFailWithError:)]) {
			[self.delegate Mainparser:self didFailWithError:parseError];
		}
	}else {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
			[self.delegate parser:self didFailWithError:parseError];
		}		
	}
}

- (void)ArticleListParseEnded{
	if (didAbortParsing)
		return;

	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	
	if (sectionFlg) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(Mainparser:didParseContents:)] && [parsedListArticles count] > 0) {
			[self.delegate Mainparser:self didParseContents:parsedListArticles];
		}
	}else {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseContents:)] && [parsedListArticles count] > 0) {
			[self.delegate parser:self didParseContents:parsedListArticles];
		}		
	}

	[self.parsedListArticles removeAllObjects];
	if (sectionFlg) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(MainparserDidEndParsingData:)]) {
			[self.delegate MainparserDidEndParsingData:self];
		}
	}else {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidEndParsingData:)]) {
			[self.delegate parserDidEndParsingData:self];
		}
	}
}

- (void)parsedListArticle:(ArticleListContent *)ListArticle {
	
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
   [self.parsedListArticles addObject:ListArticle];
	
}

@end
