//
//  BookScreenViewCtrl.h
//  Sisainlive
//
//  Created by snow leopard on 10. 8. 24..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"BaseViewCtrl.h"
#import	"XMLParser.h"
#import	"BookNumParser.h"
#import "ThumbImageView.h"
#import "ArticleViewCtrl.h"
#import "SettingViewController.h"
#import "Article.h"

// mail
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "me2dayClass.h"
//#import "TwitterClass.h"
//#import "kakaotalkClass.h"

#import "TadViewController.h"

@interface BookScreenViewCtrl : BaseViewCtrl<SettingViewControllerDelegate,
											MFMailComposeViewControllerDelegate,
											ArticleViewCtrlDelegate,
											UIScrollViewDelegate,
											XMLParserDelegate,
											BookNumParserDelegate,
											ThumbImageViewDelegate,
                                            me2dayClassDelegate>{
    
//											TwitterClassDelegate,
//											kakaotalkClassDelegate> {
	// 디바이스버젼 저장
	int version;

	// 스크롤 페이지 넘버 변수
	NSInteger       pageNumber;		
	
	// 다운로드된 파일들이 저장되는 경로를 지정
	NSString *documentPath;
	
	NSMutableArray *imageViewsInScrollView1;
	
	NSMutableArray *imageViewsInScrollView2;
	NSMutableArray *imageFileNamesForScrollView1;
	NSMutableArray *imageFileNamesForScrollView2;
	NSMutableDictionary * laData;
	
	// XML파서(페이지 이미지정보취득)
	XMLParser		*contentParser;
	BOOL ViewFlg; // 다운로드가 완료되었으면 NO, 다운로드가 끝나지 않았으면 YES;
	BOOL DownEndFlg;
	BOOL Start_Flg;	
	BOOL didAbortParsing;
	// 최신 책번호 취득
	BookNumParser	*bookParser;
	NSMutableArray	*bookcontentArray;
	// 기동시에 최신 책번호 확인을 위해서
	NSString		*BookNumber_Conf;
	
	// portrait:세로 보기
	UIScrollView    *scrollView1;
	NSUInteger      portraitcount;
	// landscape:가로 보기
	UIScrollView    *scrollView2;
	NSUInteger      landscapecount;
	
	UIButton *PageNumber_Btn;
	
	NSString *PageNumberString;
	
	NSInteger Portrait_Number;
	NSInteger Portrait_TotalNumber;	
	
	NSInteger landscape_Number;
	NSInteger landscape_TotalNumber;
	
	NSString *ReDownload;
	
	BOOL PageNumberButtonFlg;
	
	
	
	// 기사보기뷰
	ArticleViewCtrl *articleViewCtrl;
	NSString *Articleidnum;
	NSString *Articlead;
	
	// 화면회전flg
	BOOL receivedRotate;
	
	SettingViewController *settingView;
	
	Article *outputArray;
	NSString *bitlyurl;
	
	me2dayClass       *me2day;
//	TwitterClass      *twitter;
//    kakaotalkClass    *kakaotalk;
												
	BOOL viewPageFlg;
	
	NSMutableArray	*LaitemArray;	
												
	NSInteger laPageNumber;													
	NSInteger poPageNumber;
	
}
@property (nonatomic, retain) XMLParser          *contentParser;
@property (nonatomic, retain) BookNumParser      *bookParser;
@property (nonatomic, retain) NSMutableArray     *bookcontentArray;
@property (nonatomic, retain) UIButton			 *PageNumber_Btn;
@property (nonatomic, retain) ArticleViewCtrl    *articleViewCtrl;
@property (nonatomic, retain) SettingViewController *settingView;

// XML파서를 이용하여 페이지 이미지 정보취득 함수
- (void)getContent;

// 최신 책번호 데이터 취득
- (void)loadBookNum;

// XML데이터 취득이 끝난 후에 실행(취득한 정보를 처리)
- (void)parsingEnded:(NSNotification *)notification;

// 페이지의 관련기사보기화면 출력
- (void)thumbImageTouchEnded:(NSString *)idno atAd:(NSString *)ad;

- (NSData *)downloadData:(NSURL *)url toFile:(NSString *)fileName;

- (void)addImageView:(UIImageView *)imageView toScrollView:(UIScrollView *)scrollView atIndex:(NSInteger)index;

- (void)readImage:(NSInteger)currentPageNumber scrollView:(UIScrollView *)scrollView;

- (void)PortraitButtonSetting;

- (void)landscapeButtonSetting;

- (void)MailSendViewCtrl:(NSArray *)mailcontent;

// 메일 전송 후 메세지 표시 이벤트
- (void)messageAlertView:(NSString *)aMessage;

- (void)MailSendViewControll;
- (void)setupSpinView:(BOOL)flag message:(NSString *)message;

//- (void)twitterLoginIsCanceled;
//
//- (void)twitterSendMsgIsSuccessed;
//
//- (void)twitterSendMsgIsFaild;

- (void)me2dayLoginCancled;

- (void)me2daySendMsgIsSuccessed;

- (void)me2daySendMsgIsFaild;
- (void)me2daySendMsgIsCancled;

@end

