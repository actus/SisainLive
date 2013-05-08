//
//  TwitterClass.h
//  TastyBlog
//
//  Created by SUNGMAN LEE on 3/18/10.
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SA_OAuthTwitterController.h"


@protocol TwitterClassDelegate <NSObject>
@optional
- (void)showTwitterViewCtrl:(UIViewController *)controller;
- (void)twitterLoginIsSuccessed;
- (void)twitterLoginIsFailed;
- (void)twitterLoginIsCanceled;
- (void)twitterLogOutIsSuccessed;
- (void)twitterSendMsgIsSuccessed;
- (void)twitterSendMsgIsFaild;
- (void)twitterSendMsgIsCanceled;
@end

@class SA_OAuthTwitterEngine;

@interface TwitterClass : NSObject <UIAlertViewDelegate, UITextViewDelegate, SA_OAuthTwitterControllerDelegate> {
	UIAlertView *msgAlert;
	UITextView	*msgTextView;
	UILabel		*limitLabel;
	UITextField	*idTextField;
	UITextField	*pwTextField;
	// 메세지창 타이틀
	UITextView	*titleTextView;	

	
	NSMutableString	*message;
	NSInteger	firstResponder;
	
	NSInteger	request;
	
	SA_OAuthTwitterEngine *_engine;
	
	NSString *ConsumerKey;
	NSString *ConsumerSecret;
	
	NSString *title;
	NSString *url;
	
	BOOL	showMesFlg;
	
@private
	id <TwitterClassDelegate> delegate;
}
@property (assign) id <TwitterClassDelegate> delegate;
@property (nonatomic,retain) SA_OAuthTwitterEngine *_engine;
@property (nonatomic,retain) NSString *ConsumerKey;
@property (nonatomic,retain) NSString *ConsumerSecret;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *url;




//- (id)initWithViewCtrl:(NSString *)aTitle url:(NSString *)aUrl;
- (void)start;
- (void)showMessageAlertView;
- (void)showAlertView:(NSString *)aMessage;
- (void)initWithViewCtrl;
- (void)twitterSendMsg:(NSString *)aMsg;

@end
