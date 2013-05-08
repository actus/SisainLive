//
//  me2dayMsgContent.m
//  me2dayLib
//
//  Created by snow leopard on 10. 10. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "me2dayMsgContent.h"


@implementation me2dayMsgContent
@synthesize body;


- (void)dealloc {
    [super dealloc];
	[body  release];
}

@end
