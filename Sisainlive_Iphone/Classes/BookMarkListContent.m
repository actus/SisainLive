//
//  BookMarkListContent.m
//  sisain
//
//  Created by snow leopard on 10. 8. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BookMarkListContent.h"


@implementation BookMarkListContent

@synthesize idnum,title,content,permalink,description,image;

- (void)dealloc {
    [super       dealloc];
	[idnum       release];
	[title       release];
	[content     release];
	[permalink   release];
	[image       release];
	[description release];
	
}
@end
