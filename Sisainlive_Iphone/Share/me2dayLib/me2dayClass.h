//
//  me2dayClass.h
//  me2dayLib
//
//  Created by snow leopard on 10. 10. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "me2dayLoginCheckParser.h"
#import "me2daySendMsgParser.h"
#import <UIKit/UIKit.h>
@protocol me2dayClassDelegate <NSObject>


@optional

- (void)me2dayLoginIsSuccessed;
- (void)me2dayLoginIsFaild;
- (void)me2dayLogoutIsSuccessed;
- (void)me2daySendMsgIsSuccessed;
- (void)me2daySendMsgIsFaild;
- (void)me2daySendMsgIsCancled;
- (void)me2dayLoginCancled;

@end

@interface me2dayClass : NSObject<UIAlertViewDelegate,me2dayLoginCheckParserDelegate,UITextViewDelegate,me2daySendMsgParserDelegate> {

	// 타이틀 변수
	NSString *title;
	// 링크 변수
	NSString *link;
	// 태그 변수
	NSString *tag;
	// 어플리케이션 키 변수
	NSString *apikey;
	// 암호화 키 변수
	NSString *md5key;
	
	// 로그인 아이디 필드
	UITextField		    *idTextField;
	// 로그인 패스워드 필드
	UITextField		    *pwTextField;
	// 로그인 유저키 설명라벨
	UILabel			    *userkeyLabel;
	
	id <me2dayClassDelegate> delegate;
	
	me2dayLoginCheckParser	*loginParser;
	NSMutableArray	*loginContentArray;
	
	// 메세지창에 표시할 메세지
	NSMutableString		*message;
	
	// 메세지창 타이틀
	UITextView	*titleTextView;
	// 해당 메세지 출력 부분
	UITextView	*msgTextView;
	// 해당 메세지의 전체 길이 표시
	UILabel		*limitLabel;
	// 해당 메세지타이틀 저장 변수
	NSString    *msgTitle;
	
	
	me2daySendMsgParser	*msgSendParser;
	NSMutableArray	*sendMsgContentArray;
	
	
	BOOL msgSendBtnFlg;
	
}
@property (assign) id <me2dayClassDelegate> delegate;
@property (nonatomic,retain)NSString *title;
@property (nonatomic,retain)NSString *tag;
@property (nonatomic,retain)NSString *link;
@property (nonatomic,retain)NSString *apikey;
@property (nonatomic,retain)NSString *md5key;
@property (nonatomic, retain) me2dayLoginCheckParser  *loginParser;
@property (nonatomic, retain) me2daySendMsgParser	  *msgSendParser;


- (void)sendMessage;

- (void)setLinkTitle:(NSString *)aTitle atLink:(NSString *)aLink;
- (void)login;
- (void)logout;
@end
