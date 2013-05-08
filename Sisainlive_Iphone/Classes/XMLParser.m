//
//  XMLParser.m
//  sisain
//
//  Created by snow leopard on 10. 7. 20..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XMLParser.h"
#import "Constants.h"

@implementation XMLParser
@synthesize currentString;
@synthesize postTotal;
@synthesize portraitObjects;
@synthesize landscapeObjects;
@synthesize portraitNumber;
@synthesize landscapeNumber;

- (void)dealloc {
    [super dealloc];

}

- (void)start:(NSString *)number {

	didAbortParsing = NO;

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;


	NSString *url = [NSString stringWithFormat:@"%@%@", [NSString stringWithFormat:sisainxml_url,number],@".xml"];
	NSURL *urlBuf = [NSURL URLWithString:url];
	[NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:urlBuf];

/*
	// 시물레이터안에 있는 파일을 가지고 실행(테스트를 위해서)
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *xmlPath = [bundle pathForResource:@"list" ofType:@"xml"];
	NSURL *urlBuf = [NSURL fileURLWithPath:xmlPath];
	[NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:urlBuf];
*/
}

- (void)downloadStarted {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
}

- (void)downloadEnded {
	NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
}

- (void)stop {
	didAbortParsing = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)downloadAndParse:(NSURL *)url {

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];

    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	// setting
	parser.delegate = self;

	// start parser
	if (portraitObjects != nil) {
		[portraitObjects release];
	}
	portraitObjects = [[NSMutableArray alloc] init];
	if (landscapeObjects != nil) {
		[landscapeObjects release];
	}
	landscapeObjects = [[NSMutableArray alloc] init];
	[parser parse];
    [self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
	[parser release];
	self.currentString = nil;
    [pool release];

}
// Constants for the XML element names that will be considered during the parse. 
// Declaring these as static constants reduces the number of objects created during the run
// and is less prone to programmer error.

static NSString *k_entry		= @"entry";
static NSString *k_page		    = @"page";
static NSString *k_pagenum		= @"pagenum";
static NSString *k_img		    = @"img";
static NSString *k_title		= @"title";
static NSString *k_shape		= @"shape";
static NSString *k_ad			= @"ad";
static NSString *k_coords	    = @"coords";
static NSString *k_item			= @"item";
static NSString *k_id			= @"id";
static NSString *k_map			= @"map";
static NSString *k_portrait		= @"portrait";

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	
	if ([elementName isEqualToString:k_entry]) {
		if (xmlDictionnary != nil) {
			if (currentIsPortrait) {
				[portraitObjects addObject:xmlDictionnary];
			} else {
				[landscapeObjects addObject:xmlDictionnary];
			}
			[xmlDictionnary release];
			xmlDictionnary = nil;
		}
	} else if ([elementName isEqualToString:k_item]) {
		if (xmlDictionnary != nil && itemDictionnary != nil) {
			if (itemArray == nil) {
				itemArray = [xmlDictionnary objectForKey:k_item];
				[itemArray retain];
			}
			[itemArray addObject:itemDictionnary];
			[xmlDictionnary setObject:itemArray forKey:k_item];
			[itemDictionnary release];
			itemDictionnary = nil;
			[itemArray release];
			itemArray = nil;
		}
	} else if ([elementName isEqualToString:k_pagenum]
		|| [elementName isEqualToString:k_img]) {
		[xmlDictionnary setObject:currentString forKey:elementName];
	} else if ([elementName isEqualToString:k_title]
			   || [elementName isEqualToString:k_id]
			   || [elementName isEqualToString:k_coords]
			   || [elementName isEqualToString:k_ad]) {
		[itemDictionnary setObject:currentString forKey:elementName];
	}
	self.currentString = nil;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{

	if ([elementName isEqualToString:k_entry]) {
		xmlDictionnary = [[NSMutableDictionary alloc] init];
		[xmlDictionnary setObject:[attributeDict objectForKey:k_page] forKey:k_page];
		if ([[attributeDict objectForKey:k_page] isEqualToString:k_portrait]) {
			currentIsPortrait = YES;
		} else {
			currentIsPortrait = NO;
		}
		itemArray = [[NSMutableArray alloc] init];
	} else if ([elementName isEqualToString:k_item]) {
		itemDictionnary = [[NSMutableDictionary alloc] init];
		
	} else if ([elementName isEqualToString:k_map]) {
		if (itemDictionnary != nil) {
			[itemDictionnary setObject:[attributeDict objectForKey:k_shape] forKey:k_shape];
		}
	} else if ([elementName isEqualToString:k_pagenum]
			   || [elementName isEqualToString:k_img]
			   || [elementName isEqualToString:k_title]
			   || [elementName isEqualToString:k_id]
			   || [elementName isEqualToString:k_coords]
			   || [elementName isEqualToString:k_ad]) {
		self.currentString = [NSMutableString string]; // POINT
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
	NSNotification *notification = [NSNotification notificationWithName:@"ParsingEnded" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *) string {
	if (currentString != nil)
		[currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
}


@end
