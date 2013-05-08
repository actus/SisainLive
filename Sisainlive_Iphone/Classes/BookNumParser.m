//
//  BookNumParser.m
//  sisain
//
//  Created by snow leopard on 10. 7. 29..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BookNumParser.h"
#import	"Book.h"
#import "Constants.h"

@implementation BookNumParser
@synthesize delegate,currentString, currentContent, parsedBookNum;;

- (void)dealloc {
	[parsedBookNum release];
    [super dealloc];
}

- (void)start{
	
	didAbortParsing = NO;
	self.parsedBookNum = [NSMutableArray array];

	/*
	NSString *xmlPath = @"/Users/Ong/Desktop/text.xml";
	NSURL *urlBuf = [NSURL fileURLWithPath:xmlPath];
	[NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:urlBuf];
	 */
	
 	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:booknumber_url]];
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
	[self performSelectorOnMainThread:@selector(bookparseEnded) withObject:nil waitUntilDone:NO];
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
static NSString *k_BookNumber	    = @"booknumber";

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
	if (didAbortParsing) {
		[parser abortParsing];
	}
	
	if ([elementName isEqualToString:k_Entry]) {
		self.currentContent = [[[Book alloc] init] autorelease];
	}
	else if ([elementName isEqualToString:k_BookNumber]) {
        [currentString setString:@""];
        storingCharacters = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:k_Entry]) {
        [self performSelectorOnMainThread:@selector(parsedBook:) withObject:currentContent waitUntilDone:NO];
		// performSelectorOnMainThread: will retain the object until the selector has been performed
        // setting the local reference to nil ensures that the local reference will be released
        self.currentContent = nil;
    }
	else if ([elementName isEqualToString:k_BookNumber]) {
        currentContent.Booknum = currentString;
    }
    storingCharacters = NO;
}

- (void)parsedBook:(Book *)booknum {
	
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	[self.parsedBookNum addObject:booknum];
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (storingCharacters){
		[currentString appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
//	NSLog(@">>parseError:%@",parseError);
}


// XML파싱이 끝나면 취득한 값을 전송
- (void)bookparseEnded {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseContents:)] && [parsedBookNum count] > 0) {
		[self.delegate parser:self didParseContents:parsedBookNum];
	}
}


@end
