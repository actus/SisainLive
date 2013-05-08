
 //
 //  ThumbImageView.h
 //  sisain
 //
 //  Created by snow leopard on 10. 7. 14..
 //  Copyright 2010 __MyCompanyName__. All rights reserved.
 //
 
#import <QuartzCore/QuartzCore.h>
#import "SisainliveAppDelegate.h"

@protocol ThumbImageViewDelegate;

@interface ThumbImageView : UIImageView {
    id <ThumbImageViewDelegate> delegate;

    BOOL             dragging;
    CGPoint          touchLocation; // Location of touch in own coordinates (stays constant during dragging).
	UIView	        *subselected;
	UIView	        *subselected2;
	UIButton	    *TitleText;
	UILabel	        *TitleLabel;
	UILabel	        *TitleLabel2;
	NSString        *idno;
	NSString        *ad;
	
	NSString        *title;
	UIImageView     *alpaview;

	BOOL			viewFlg;
}
@property (nonatomic, assign) BOOL viewFlg;
@property (nonatomic, assign) id <ThumbImageViewDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *item;
@property (nonatomic, assign) CGPoint touchLocation;
@property (nonatomic, assign) IBOutlet UIView *subselected;
@property (nonatomic, assign) IBOutlet UIView *subselected2;
@property (nonatomic, assign) IBOutlet UIButton *TitleText;
@property (nonatomic, assign) IBOutlet UILabel	*TitleLabel;
@property (nonatomic, assign) IBOutlet UILabel	*TitleLabel2;

- (void)ShowTitleView:(int)x totest:(int)y object:(NSDictionary *)itemobjects;
@end

@protocol ThumbImageViewDelegate <NSObject>

- (void)thumbImageTouchEnded:(NSString *)idno atAd:(NSString *)ad;

- (void)PageButtonHidden;

- (void)PageButtonHiddenNO;

@optional


@end

