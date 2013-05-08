//
//  ArticleListCustomCell.m
//  sisain
//
//  Created by snow leopard on 10. 8. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArticleListCustomCell.h"
#import "Constants.h"
#import "SisainliveAppDelegate.h"

/**
 기사리스트 테이블 커스텀 뷰
 */
@implementation ArticleListCustomCell
@synthesize myImageFlag,myImageView,myTextLabel,myDetailTextLabel;
@synthesize adViewIndexPath;

//#define imageView_frame CGRectMake(2.0f, 2.0f, 78.0f, 60.0f)
//#define textLabel_frame CGRectMake(85.0f, 5.0f, 233.0f, 20.0f)
//#define detailTextLabel_frame CGRectMake(85.0f, 29.0f, 233.0f, 30.0f)
#define imageView_frame CGRectMake(230.0f, 2.0f, 78.0f, 60.0f)
#define textLabel_frame CGRectMake(10.0f, 5.0f, 210.0f, 20.0f)
#define detailTextLabel_frame CGRectMake(10.0f, 29.0f, 210.0f, 30.0f)

#define nonImage_textLabel_frame CGRectMake(10.0f, 5.0f, 300.0f, 20.0f)
#define nonImage_detailTextLabel_frame CGRectMake(10.0f, 29.0f, 300.0f, 30.0f)

/**
 해당하는 영역설정
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		adViewIndexPath = 0;
        // Initialization code
		myImageFlag = NO;
		threadFlag = NO;
		adViewFlg = NO;
		
		myImageView = [[UIImageView alloc] initWithFrame:imageView_frame];
		myImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:myImageView];
		[myImageView release];
		
		myTextLabel = [[UILabel alloc] initWithFrame:textLabel_frame];
		myTextLabel.font = [UIFont systemFontOfSize:14.0f];
		[self.contentView addSubview:myTextLabel];
		[myTextLabel release];
		
		myDetailTextLabel = [[UILabel alloc] initWithFrame:detailTextLabel_frame];
		myDetailTextLabel.numberOfLines = 2;
		myDetailTextLabel.font = [UIFont systemFontOfSize:12.0f];
		myDetailTextLabel.textColor = [UIColor darkGrayColor];
		[self.contentView addSubview:myDetailTextLabel];
		[myDetailTextLabel release];
		
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

/**
 테이블 이미지에 따른 뷰영역 설정
 */
- (void)setupMode:(BOOL)imgView {
	if (imgView == YES) {
		myImageView.hidden		= NO;
		myTextLabel.frame		= textLabel_frame;
		myDetailTextLabel.frame	= detailTextLabel_frame;
	}
	else {
		myImageView.hidden		= YES;
		myTextLabel.frame		= nonImage_textLabel_frame;
		myDetailTextLabel.frame	= nonImage_detailTextLabel_frame;
	}
}

/**
 이미지 표시 설정
 */
- (void)setupThumbNail:(NSString *)url {
	if (threadFlag)
		return;
	
	if ([url length] == 0) {
		myImageFlag = YES;
		return;
	}
	
	[NSThread detachNewThreadSelector:@selector(getImageData:) toTarget:self withObject:url];
}

/**
 테이블 이미지 설정
 */
- (void)getImageData:(NSString *)url {
	
	threadFlag = YES;
	NSAutoreleasePool *Pool = [[NSAutoreleasePool alloc] init];
	
	UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]; 
	if (img) {
		myImageView.image = img;
		myImageFlag = YES;
		[img release];
	}
	
	//[spin removeFromSuperview];
	
	[Pool release];
	threadFlag = NO;
}

- (void)setupADView:(NSInteger)indexPath{

	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.adview.frame = CGRectMake(0.0f, 10.0f, 320.0f, 48.0f);
	
	if (!adViewFlg) {
		[self.contentView addSubview:appDelegate.adview];
	
		adViewFlg = YES;
	}else {
		if (![appDelegate.adview superview]) {
			[self.contentView addSubview:appDelegate.adview];
		}else {
			[appDelegate.adview removeFromSuperview];
			[self.contentView addSubview:appDelegate.adview];
		}
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
