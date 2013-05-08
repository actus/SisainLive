//
//  Book.m
//  sisain
//
//  Created by snow leopard on 10. 7. 29..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Book.h"


@implementation Book

@synthesize Booknum;

- (void)dealloc {
	[Booknum release];
    [super dealloc];
}
@end
