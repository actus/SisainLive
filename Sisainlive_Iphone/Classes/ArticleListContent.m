//
//  ArticleListContent.m
//  sisain
//
//  Created by snow leopard on 10. 8. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "ArticleListContent.h"

/**
 기사리스트 보기 변수
 */
@implementation ArticleListContent
@synthesize title,description,Limage,image,link_id,link,pubDate;

- (void)dealloc {
    [super dealloc];
	[title       release];
	[description release];
	[Limage      release];
	[image       release];
	[link_id     release];
	[link        release];
	[pubDate     release];
}
@end
