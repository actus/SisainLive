
//
//  ThumbImageView.m
//  sisain
//
//  Created by snow leopard on 10. 7. 14..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ThumbImageView.h"
#import "Constants.h"
#import "SisainliveAppDelegate.h"

@implementation ThumbImageView
@synthesize delegate;
@synthesize item;
@synthesize touchLocation;
@synthesize subselected;
@synthesize subselected2;
@synthesize TitleText;
@synthesize TitleLabel;
@synthesize TitleLabel2;
@synthesize viewFlg;

- (void)dealloc {
    [super dealloc];
	[item release];
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];
		
	}
	return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];  // block other touches while dragging a thumb view
    }
    return self;
}


- (void)ShowTitleView:(int)x totest:(int)y object:(NSDictionary *)itemobjects{
	
	
	NSString *titlecontent;
	title = [itemobjects objectForKey:@"title"];
	if (title != nil) {
		NSInteger size = [title length];
		NSString * string;
		NSString * string2;
		if (size < 13) {
			titlecontent = title;
			string = [NSString stringWithFormat:@"%@",titlecontent];
			string2 = @"";
		}
		else {
			titlecontent = [title substringToIndex:13];
			string = [NSString stringWithFormat:@"%@",titlecontent];
			string2 = [NSString stringWithFormat:@"%@",[title substringFromIndex:13]];
		}
		int sumy = y-20;
		TitleText.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
		TitleText.frame = CGRectMake(x, sumy, 140.0f, -58.0f);
		[TitleText setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		//		[TitleText setAlpha:1.0];
		TitleLabel.frame = CGRectMake(x+4, sumy-34, 133.0f, -20.0f); 
		TitleLabel.text = string;
		TitleLabel.font = [UIFont boldSystemFontOfSize:11.0];
		TitleLabel2.frame = CGRectMake(x+4, sumy-34, 133.0f, 20.0f); 
		TitleLabel2.text = string2;
		TitleLabel2.font = [UIFont boldSystemFontOfSize:11.0];
		TitleText.hidden = NO;
		TitleLabel.hidden = NO;
		TitleLabel2.hidden = NO;
		
	}
	
	
	
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[delegate PageButtonHidden];
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:self];
	
	NSString *x = [[NSString alloc] initWithFormat:@"%3.0f",currentPosition.x];
	NSString *y = [[NSString alloc] initWithFormat:@"%3.0f",currentPosition.y];
	
	int h = [x intValue];
	int v = [y intValue];
	
	// 이전에 선택되어진 영역이 있을경우 remove
	if ([subselected superview]) {
		[subselected removeFromSuperview];
		subselected = nil;
	}
	if ([subselected2 superview]) {
		[subselected2 removeFromSuperview];
		subselected2 = nil;
	}
	
	if ([alpaview superview]) {
		[alpaview removeFromSuperview];
		alpaview = nil;
	}
	
	
	UIImage *img = [[UIImage alloc] init];
	img = TitleView3G;
	TitleText = [UIButton buttonWithType:UIButtonTypeCustom];
	[TitleText setBackgroundImage:img forState:UIControlStateNormal];
	[TitleText setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[appDelegate.tabBarController.view addSubview:TitleText];
	TitleLabel = [[UILabel alloc] init];
	[appDelegate.tabBarController.view addSubview:TitleLabel];
	TitleLabel2 = [[UILabel alloc] init];
	[appDelegate.tabBarController.view addSubview:TitleLabel2];
	
	// 기사 ID취득을 위하여 NULL설정
	idno = nil;
	ad = nil;
	
	// 선택한 부분이 기사영역인지 검사 
	for (int i=1; i <= [item count]; i++) {
		NSDictionary *itemobjects = [item objectAtIndex:i-1];
		NSString *shape = [itemobjects objectForKey:@"shape"];
		NSString *coords = [itemobjects objectForKey:@"coords"];
		
		// データの中で「rect」データがある場合
		if ([shape isEqualToString:@"rect"]) {
			
			NSArray *listItems = [coords componentsSeparatedByString:@","];
			
			if ([listItems count] == 4) {
				int coords0 = [[listItems objectAtIndex:0] intValue];
				int coords1 = [[listItems objectAtIndex:1] intValue];
				int coords2 = [[listItems objectAtIndex:2] intValue];
				int coords3 = [[listItems objectAtIndex:3] intValue];

				
				if ( coords0 < h && h < coords2 && coords1 < v && v < coords3 ) {
					// 선택한 부분중에 기사가 있을 경우에 기사ID부여
					idno = [itemobjects objectForKey:@"id"];
					ad = [itemobjects objectForKey:@"ad"];

					//START_이슈번호:0000027//
					if (alpaview ==nil) {
						alpaview = [[UIImageView alloc]init];
					}

					
					if (viewFlg) {
						alpaview.frame = CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height);
					}else {
						alpaview.frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
					}
					
					UIGraphicsBeginImageContext(alpaview.frame.size);
					
					if (viewFlg) {
						[alpaview.image drawInRect:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
					}else {
						[alpaview.image drawInRect:CGRectMake(0.0f, 0.0f, 480.0f, 320.0f)];
					}
					
					CGContextFillPath(UIGraphicsGetCurrentContext());
					CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 0.3);
					CGContextBeginPath(UIGraphicsGetCurrentContext());
					
					
					CGContextMoveToPoint (UIGraphicsGetCurrentContext(),coords0 , coords1);
					
					CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), coords2, coords1);

					CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), coords2, coords3);
					
					CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), coords0, coords3);
					
					CGContextClosePath (UIGraphicsGetCurrentContext());
					CGContextFillPath(UIGraphicsGetCurrentContext());
					alpaview.image = UIGraphicsGetImageFromCurrentImageContext();
					UIGraphicsEndImageContext();
					[self addSubview:alpaview];
				
					[self ShowTitleView:h totest:v object:itemobjects];
				}
			}
		}
		else if([shape isEqualToString:@"poly"]){
			NSArray *listItems = [coords componentsSeparatedByString:@","];
			
			int start1 = [[listItems objectAtIndex:0] intValue];
			int start2 = [[listItems objectAtIndex:1] intValue];
			int maxcount = [listItems count]-1;
			
			CGMutablePathRef myPath = CGPathCreateMutable();
			CGPathMoveToPoint   ( myPath, NULL, start1, start2 );
			for (int i=2; i<=maxcount; i++) {
				int x = [[listItems objectAtIndex:i] intValue];
				int y = [[listItems objectAtIndex:i+1] intValue];
				CGPathAddLineToPoint(myPath, nil, x, y);
				i++;
			}
			CGPathCloseSubpath( myPath );
			CGPoint myPoint = CGPointMake(h, v);
			bool pathContainsPoint = CGPathContainsPoint( myPath, NULL, myPoint, false );
			if (pathContainsPoint) {
				
				idno = [itemobjects objectForKey:@"id"];
				ad	 = [itemobjects objectForKey:@"ad"];
				
				[self ShowTitleView:h totest:v object:itemobjects];
				
				//START_이슈번호:0000027//
				if (alpaview == nil) {
					alpaview = [[UIImageView alloc]init];
				}
				
				if (viewFlg) {
					alpaview.frame = CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height);
				}else {
					alpaview.frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
				}
				
				UIGraphicsBeginImageContext(alpaview.frame.size);
				
				if (viewFlg) {
					[alpaview.image drawInRect:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
				}else {
					[alpaview.image drawInRect:CGRectMake(0.0f, 0.0f, 480.0f, 320.0f)];
				}
				
				CGContextFillPath(UIGraphicsGetCurrentContext());
				CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 0.3);
				CGContextBeginPath(UIGraphicsGetCurrentContext());
				
				int drawStart1 = [[listItems objectAtIndex:0] intValue];
				int drawStart2 = [[listItems objectAtIndex:1] intValue];				
				
				CGContextMoveToPoint (UIGraphicsGetCurrentContext(),drawStart1 , drawStart2);
				
				for (int i=2; i<= maxcount; i++) {
					int x = [[listItems objectAtIndex:i] intValue];
					int y = [[listItems objectAtIndex:i+1] intValue];
					
					CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x, y);
					i++;
				}				
				CGContextClosePath (UIGraphicsGetCurrentContext());
				CGContextFillPath(UIGraphicsGetCurrentContext());
				alpaview.image = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				[self addSubview:alpaview];
				
				
				//END_이슈번호:0000027//
			}
		}
		
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:self];
	
	NSString *x = [[NSString alloc] initWithFormat:@"%3.0f",currentPosition.x];
	NSString *y = [[NSString alloc] initWithFormat:@"%3.0f",currentPosition.y];
	
	int h = [x intValue];
	int v = [y intValue];
	
	// 이전에 선택되어진 영역이 있을경우 remove
	if ([subselected superview]) {
		[subselected removeFromSuperview];
		subselected = nil;
	}
	if ([subselected2 superview]) {
		[subselected2 removeFromSuperview];
		subselected2 = nil;
	}
	
	if ([alpaview superview]) {
		[alpaview removeFromSuperview];
		alpaview = nil;
	}
	
	/*START_이슈번호:0000028*/
	TitleText.hidden = YES;
	TitleLabel.hidden = YES;
	TitleLabel2.hidden = YES;
	/*END_이슈번호:0000028*/
	
	// 기사 ID취득을 위하여 NULL설정
	idno = nil;
	// 선택한 부분이 기사영역인지 검사 
	for (int i=1; i <= [item count]; i++) {
		NSDictionary *itemobjects = [item objectAtIndex:i-1];
		NSString *shape = [itemobjects objectForKey:@"shape"];
		NSString *coords = [itemobjects objectForKey:@"coords"];
		// データの中で「rect」データがある場合
		if ([shape isEqualToString:@"rect"]) {
			NSArray *listItems = [coords componentsSeparatedByString:@","];
			
			if ([listItems count] == 4) {
				int coords0 = [[listItems objectAtIndex:0] intValue];
				int coords1 = [[listItems objectAtIndex:1] intValue];
				int coords2 = [[listItems objectAtIndex:2] intValue];
				int coords3 = [[listItems objectAtIndex:3] intValue];
				
				if ( coords0 < h && h < coords2 && coords1 < v && v < coords3 ) {

					// 선택한 부분중에 기사가 있을 경우에 기사ID부여
					idno = [itemobjects objectForKey:@"id"];
					ad = [itemobjects objectForKey:@"ad"];
					//START_이슈번호:0000027//
					if (alpaview == nil) {
						alpaview = [[UIImageView alloc]init];
					}

					
					if (viewFlg) {
						alpaview.frame = CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height);
					}else {
						alpaview.frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
					}
					
					UIGraphicsBeginImageContext(alpaview.frame.size);
					
					if (viewFlg) {
						[alpaview.image drawInRect:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
					}else {
						[alpaview.image drawInRect:CGRectMake(0.0f, 0.0f, 480.0f, 320.0f)];
					}
					
					CGContextFillPath(UIGraphicsGetCurrentContext());
					CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 0.3);
					CGContextBeginPath(UIGraphicsGetCurrentContext());
					
					
					CGContextMoveToPoint (UIGraphicsGetCurrentContext(),coords0 , coords1);
					
					CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), coords2, coords1);
					
					CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), coords2, coords3);
					
					CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), coords0, coords3);
					
					CGContextClosePath (UIGraphicsGetCurrentContext());
					CGContextFillPath(UIGraphicsGetCurrentContext());
					alpaview.image = UIGraphicsGetImageFromCurrentImageContext();
					UIGraphicsEndImageContext();
					[self addSubview:alpaview];

					[self ShowTitleView:h totest:v object:itemobjects];
				}
			}
		}
		else if([shape isEqualToString:@"poly"]){
			
			NSArray *listItems = [coords componentsSeparatedByString:@","];
			int maxcount = [listItems count]-1;
			
			int start1 = [[listItems objectAtIndex:0] intValue];
			int start2 = [[listItems objectAtIndex:1] intValue];
			
			CGMutablePathRef myPath = CGPathCreateMutable();
			CGPathMoveToPoint   ( myPath, NULL, start1, start2);
			for (int i=2; i<=maxcount; i++) {
				int x = [[listItems objectAtIndex:i] intValue];
				int y = [[listItems objectAtIndex:i+1] intValue];
				CGPathAddLineToPoint(myPath, nil, x, y);
				i++;
			}
			CGPathCloseSubpath( myPath );
			CGPoint myPoint = CGPointMake(h, v);
			bool pathContainsPoint = CGPathContainsPoint( myPath, NULL, myPoint, false );
			if (pathContainsPoint) {
				
				idno = [itemobjects objectForKey:@"id"];
				ad = [itemobjects objectForKey:@"ad"];
				[self ShowTitleView:h totest:v object:itemobjects];
				
				//START_이슈번호:0000027//
				
				alpaview = [[UIImageView alloc]init];
				
				if (viewFlg) {
					alpaview.frame = CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height);
				}else {
					alpaview.frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
				}
				UIGraphicsBeginImageContext(alpaview.frame.size);
				
				if (viewFlg) {
					[alpaview.image drawInRect:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
				}else {
					[alpaview.image drawInRect:CGRectMake(0.0f, 0.0f, 480.0f, 320.0f)];
				}
				
				
				
				CGContextFillPath(UIGraphicsGetCurrentContext());
				CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 0.3);
				CGContextBeginPath(UIGraphicsGetCurrentContext());
				
				int drawStart1 = [[listItems objectAtIndex:0] intValue];
				int drawStart2 = [[listItems objectAtIndex:1] intValue];	
				
				CGContextMoveToPoint (UIGraphicsGetCurrentContext(),drawStart1 , drawStart2);
				
				for (int i=2; i<=maxcount; i++) {
					int x = [[listItems objectAtIndex:i] intValue];
					int y = [[listItems objectAtIndex:i+1] intValue];
					CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x, y);
					i++;
				}				
				CGContextClosePath (UIGraphicsGetCurrentContext());
				CGContextFillPath(UIGraphicsGetCurrentContext());
				alpaview.image = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				[self addSubview:alpaview];
				//END_이슈번호:0000027//
				
			}
		}
	}
}

// ScrollImage를 클릭한 부분에 기사가 있을 경우
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[delegate PageButtonHiddenNO];
	
	if ( idno != nil) {
		
		//		[delegate thumbImageTouchEnded:idno];
		[delegate thumbImageTouchEnded:idno atAd:ad];
	}
	if ([subselected superview]) {
		[subselected removeFromSuperview];
		subselected = nil;
	}
	if ([subselected2 superview]) {
		[subselected2 removeFromSuperview];
		subselected2 = nil;
	}
	if ([TitleText superview]) {
		[TitleText removeFromSuperview];
		TitleText = nil;
	}
	
	if ([TitleLabel superview]) {
		[TitleLabel removeFromSuperview];
		TitleLabel = nil;
	}
	
	if ([TitleLabel2 superview]) {
		[TitleLabel2 removeFromSuperview];
		TitleLabel2 = nil;
	}
	
	
	if ([alpaview superview]) {
		[alpaview removeFromSuperview];
		alpaview = nil;
	}
	
	
	
	[subselected release];
	[subselected2 release];
	
	[TitleText release];	
	[TitleLabel release];
	[TitleLabel2 release];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[delegate PageButtonHiddenNO];
	
	if ([subselected superview]) {
		[subselected removeFromSuperview];
		subselected = nil;
	}
	if ([subselected2 superview]) {
		[subselected2 removeFromSuperview];
		subselected2 = nil;
	}
	if ([TitleText superview]) {
		[TitleText removeFromSuperview];
		TitleText = nil;
	}
	
	if ([TitleLabel superview]) {
		[TitleLabel removeFromSuperview];
		TitleLabel = nil;
	}
	
	if ([TitleLabel2 superview]) {
		[TitleLabel2 removeFromSuperview];
		TitleLabel2 = nil;
	}
	
	if ([alpaview superview]) {
		[alpaview removeFromSuperview];
		alpaview = nil;
	}
	
	
	[subselected release];
	[subselected2 release];
	
	[TitleText release];	
	[TitleLabel release];
	[TitleLabel2 release];
}


@end



