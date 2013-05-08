//
//  DescriptionLabel.m
//  sisain
//
//  Created by Jupiter on 10. 8. 4..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import "DescriptionLabel.h"


@implementation DescriptionLabel

@synthesize index;
@synthesize delegate;

- (void)dealloc {
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	dragging = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (dragging) {
        dragging = NO;
    }
	else {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(articleLabelWasTapped:)]) {
			[self.delegate articleLabelWasTapped:index];
		}
    }
}

@end
