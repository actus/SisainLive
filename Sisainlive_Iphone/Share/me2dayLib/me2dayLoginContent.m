//
//  me2dayLoginContent.m
//  me2dayLib
//
//  Created by snow leopard on 10. 10. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "me2dayLoginContent.h"


@implementation me2dayLoginContent
@synthesize code;


- (void)dealloc {
    [super dealloc];
	[code       release];
}
@end
