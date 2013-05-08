//
//  Article.m
//  sisain
//
//  Created by snow leopard on 10. 7. 27..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Article.h"

/**
 기사변수 설정 클래스
 */
@implementation Article

@synthesize idnum,category_id,permalink,title,content,description,image;

- (void)dealloc {
    [super dealloc];
	[idnum       release];
	[category_id release];
	[permalink   release];
	[title       release];
	[content     release];
	[description release];
	[image       release];
}
@end
