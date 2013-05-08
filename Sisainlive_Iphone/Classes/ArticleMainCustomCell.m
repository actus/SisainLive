//
//  ArticleMainCustomCell.m
//  Sisainlive
//
//  Created by snow leopard on 10. 8. 26..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArticleMainCustomCell.h"

/**
 기사리스트 메인 테이블 커스텀 뷰
 */
@implementation ArticleMainCustomCell


@synthesize myImageFlag,myImageView,myTextLabel;


#define imageView_frame CGRectMake(60.0f, 2.0f, 200.0f, 120.0f)
#define textLabel_frame CGRectMake(50.0f, 130.0f, 220.0f, 20.0f)
#define nonImage_textLabel_frame CGRectMake(10.0f, 5.0f, 300.0f, 20.0f)


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		myImageFlag = NO;
		threadFlag = NO;
		
		myImageView = [[UIImageView alloc] initWithFrame:imageView_frame];
		myImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:myImageView];
		[myImageView release];
		
		myTextLabel = [[UILabel alloc] initWithFrame:textLabel_frame];
		myTextLabel.textAlignment = UITextAlignmentCenter;
		myTextLabel.font = [UIFont systemFontOfSize:14.0f];
		[self.contentView addSubview:myTextLabel];
		[myTextLabel release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (void)setupMode:(BOOL)imgView {
	if (imgView == YES) {
		myImageView.hidden		= NO;
		myTextLabel.frame		= textLabel_frame;
	}
	else {
		myImageView.hidden		= YES;
		myTextLabel.frame		= nonImage_textLabel_frame;
	}
}

- (void)setupThumbNail:(NSString *)url {
	if (threadFlag)
		return;
	
	if ([url length] == 0) {
		myImageFlag = YES;
		return;
	}
	
	[NSThread detachNewThreadSelector:@selector(getImageData:) toTarget:self withObject:url];
}


- (void)getImageData:(NSString *)url {
	
	
	
	threadFlag = YES;
	NSAutoreleasePool *Pool = [[NSAutoreleasePool alloc] init];
	
	UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]; 
	if (img) {
		myImageView.image = img;
		myImageFlag = YES;
		[img release];
	}
	
	[Pool release];
	threadFlag = NO;
}


- (void)dealloc {
    [super dealloc];
}

@end
