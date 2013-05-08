//
//  kakaotalkClass.h
//  Sisainlive
//
//  Created by snow leopard on 11/03/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const KakaoConnectScheme;
extern NSString *const KakaoConnectMethod;

NSString *GetConnectBaseURL();
NSString *GetConnectURLStringWithParameters(NSDictionary *parameters);
NSDictionary *GetParametersDictionary(NSString *appid, NSString *appver, NSString *url, NSString *msg);

@protocol kakaotalkClassDelegate <NSObject>


@optional

- (void)kakaotalkSendMessageEnd;

@end

@interface kakaotalkClass : NSObject<UIAlertViewDelegate, UITextViewDelegate> {
	// 타이틀 변수
	NSString *msg;
	// 링크 변수
	NSString *url;
	
	UIAlertView *msgAlert;	
	
	UITextView	*titleTextView;	
	UITextView	*msgTextView;	
	UILabel		*limitLabel;
	
	NSMutableString	*message;
	id <kakaotalkClassDelegate> delegate;
	
	
	
}
@property (assign) id <kakaotalkClassDelegate> delegate;
@property (nonatomic,retain)NSString *msg;
@property (nonatomic,retain)NSString *url;
@property (nonatomic, readonly) BOOL canOpenConnect;

- (void)sendMessage;


@end
