//
//  ArticleViewCtrl.h
//  sisain
//
//  Created by snow leopard on 10. 7. 27..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewCtrl.h"
#import "ArticleParser.h"
//#import "ThumbImageView.h"
#import "SisainliveAppDelegate.h"
// mail
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TadViewController.h"

// Protocol for the parser to communicate with its delegate.
@protocol ArticleViewCtrlDelegate <NSObject>

@optional

//- (void)MailSendViewControll:(BOOL)MailSendView_Flg;
- (void)MailSendViewCtrl:(NSArray *)mailcontent;

// 10/7 추가
- (void)TwitterSendViewCtrl:(NSArray *)twittercontent atshortUrl:(NSString *)bitlyURL;

- (void)FaceBookSendViewCtrl:(NSArray *)facebookcontent atshortUrl:(NSString *)bitlyURL;

- (void)me2daySendViewCtrl:(NSArray *)me2daycontent atshortUrl:(NSString *)bitlyURL;

- (void)kakaotalkSendViewCtrl:(NSArray *)kakaotalkcontent atshortUrl:(NSString *)bitlyURL;

- (void)btnPressedClosed;
@end

/**
 기사보기 화면
 */
@interface ArticleViewCtrl : BaseViewCtrl <UIWebViewDelegate,UIActionSheetDelegate,ArticleParserDelegate,MFMailComposeViewControllerDelegate>{

    id <ArticleViewCtrlDelegate> delegate;
	NSString        *idnumber;
	NSString        *adUrl;
	
	NSMutableArray	*contentArray;
	ArticleParser	*contentParser;
	UIWebView		*myWebView;
	
	
	
	SisainliveAppDelegate *appDelegate;
	
	BOOL			MailSendView_Flg;
	BOOL			ArticleView_Flg;
	UIImageView     *backgroundView;
	UIButton	    *CloseBtn;	
	UIButton	    *MailBtn;
	UIButton	    *BookMarkBtn;
	//10/7 추가 
	NSString		  *bitlyURL;
//	UIImageView     *bgImageView;
}
@property (nonatomic, assign) id <ArticleViewCtrlDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIWebView *myWebView;
//@property (nonatomic, retain) IBOutlet UIImageView *bgImageView;
@property (nonatomic, retain) NSString           *idnumber;
@property (nonatomic, retain) NSString           *adUrl;
@property (nonatomic, retain) NSMutableArray     *contentArray;
@property (nonatomic, retain) ArticleParser      *contentParser;
@property (nonatomic, retain) IBOutlet UIImageView   *backgroundView;
@property (nonatomic, retain) IBOutlet UIButton	      *CloseBtn;
@property (nonatomic, retain) IBOutlet UIButton	      *MailBtn;
@property (nonatomic, retain) IBOutlet UIButton	      *BookMarkBtn;


// 페이지 닫기 버튼이벤트
- (IBAction)ScreenClosed_btn;
// 북마크 버튼이벤트
- (IBAction)BookMark_btn;
// 메일 전송버튼이벤트
- (IBAction)MailSend_btn;

// 메일 전송 후 메세지 표시 이벤트
//- (void)messageAlertView:(NSString *)aMessage;

@end


