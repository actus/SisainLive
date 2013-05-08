//
//  ArticleViewCtrl.m
//  sisain
//
//  Created by snow leopard on 10. 7. 27..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArticleViewCtrl.h"
#import "Article.h"
#import "Constants.h"
#import "SisainliveAppDelegate.h"


/**
 기사보기 화면
 */
@interface ArticleViewCtrl ()
// 기사정보 데이터 취득이벤트
- (void)getArticle;
// 기사정보 표시이벤트
- (void)loadArticle;

@end

@implementation ArticleViewCtrl
@synthesize idnumber;
@synthesize adUrl;
@synthesize contentArray;
@synthesize contentParser;
@synthesize myWebView;
@synthesize delegate;
@synthesize backgroundView;
@synthesize CloseBtn;
@synthesize MailBtn;
@synthesize BookMarkBtn;
//@synthesize bgImageView;


typedef enum {
	shareActionSheet = 1,
	bookmarkActionSheet
} actionSheetTag;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	NSInteger networkStatus;
	networkStatus = [self checkNetworkStatus];
	
	if (networkStatus != network_disable) {
		[self getArticle];
	}
	else {
		[self showNetworkError];
	}

	
	appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	if ([appDelegate.adview superview]) {
		[appDelegate.adview removeFromSuperview];
		[self.view addSubview:appDelegate.adview];
	}else {
		[self.view addSubview:appDelegate.adview];
	}
	
	
	
	/*******************************************************
	 * 발급받은 Application ID를 입력 하시고 확인 하시기 바랍니다. 
	 *******************************************************/

	/*
	// T ad 초기화 작업 (initialize:@"ApplicationID", bannerPosition:배너 위치(상, 하) 설정 
	//					applicationTitle:@"App 이름", view:T ad 를 붙일 위치 지정)
	[TadViewController initialize:ADAPPID bannerPosition:BANNER_POSITION_BOTTOM
				 applicationTitle:ADAPPNAME view:[self view]];
	
	
	// 배너 위치 지정 Y좌표 양수로 입력
	[TadViewController setBannerPosition:BANNER_POSITION_BOTTOM setPortraitY:0 setLandscapeY:0];
//	[TadViewController setBannerPosition:BANNER_POSITION_BOTTOM setPortraitY:430 setLandscapeY:270];	
	
	// 배너의 자동 회전 기능 사용 여부 설정
	[TadViewController enableAutoRotation:NO];
	*/
}

- (IBAction)ScreenClosed_btn{
	if (ArticleView_Flg) {
		
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(btnPressedClosed)]) {
			[self.delegate btnPressedClosed];
		}
		
	}
}

// 기동시 기사파일리스트 테이블 생성
- (void)viewWillAppear:(BOOL)animated {

}
- (void)viewWillDisappear:(BOOL)animated {
	
	if (contentParser) {
		[contentParser stop];
		self.contentParser = nil;
	}
	[myWebView stopLoading];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {

	[idnumber release];
	[adUrl release];
	[contentArray release];
	[myWebView release];
	[backgroundView release];
	[CloseBtn release];
	[BookMarkBtn release];
	[MailBtn release];
//	[bgImageView release];
	
	if (bitlyURL)
		[bitlyURL release];
	
    [super dealloc];

}

// 기사정보 데이터 취득
- (void)getArticle{
	
	if ([adUrl length] > 0) {

		//Create a URL object.
		NSURL *url = [NSURL URLWithString:adUrl];
		
		//URL Requst Object
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
		
		//Load the request in the UIWebView.
		[myWebView loadRequest:requestObj];
		ArticleView_Flg = YES;
		MailBtn.hidden = YES;
		CloseBtn.hidden = NO;
		BookMarkBtn.hidden = YES;
		
	}else {

		contentArray = [[NSMutableArray alloc] initWithCapacity:0];
		self.contentParser = [[[ArticleParser alloc] init] autorelease];
		contentParser.delegate = self;
		[contentParser start:idnumber];
		ArticleView_Flg = NO;
		MailBtn.hidden = NO;
		BookMarkBtn.hidden = NO;
	}
}

#pragma mark ArticleParser delegate

- (void)parserDidEndParsingData:(id)parser {
    self.contentParser = nil;
}

- (void)parser:(id)parser didParseContents:(NSArray *)parsedContents {
    [contentArray addObjectsFromArray:parsedContents];
	[self loadArticle];
    // Three scroll view properties are checked to keep the user interface smooth during parse. When new objects are delivered by the parser, the table view is reloaded to display them. If the table is reloaded while the user is scrolling, this can result in eratic behavior. dragging, tracking, and decelerating can be checked for this purpose. When the parser finishes, reloadData will be called in parserDidEndParsingData:, guaranteeing that all data will ultimately be displayed even if reloadData is not called in this method because of user interaction.
}

// 기사정보 표시
- (void)loadArticle {
	
	Article *content = [contentArray objectAtIndex:0];

	[myWebView loadHTMLString:content.content baseURL:nil];
	ArticleView_Flg = YES;
	
	/*
	if (bitlyURL == nil) {
		NSString *url = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=yongsuklee&apiKey=R_cf2ce2c57e5ea391da775fc021e575b1", [content.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
		[NSURLConnection connectionWithRequest:request delegate:self];
	}
	 */

	
}


#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
		//NSLog(@">> didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//NSLog(@">> didReceiveData");
	NSString *buf = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSRange range = [buf rangeOfString:@"\"shortUrl\": \""];
	
	NSInteger length = 0;
	NSInteger location = range.location + range.length;
	
	
	while (1) {
		NSString *letter = [buf substringWithRange:NSMakeRange(location++, 1)];
		
		if ([letter isEqualToString:@"\""])
			break;
		
		length++;
	}
	
	bitlyURL = [[NSString alloc] initWithString:[buf substringWithRange:NSMakeRange(range.location + range.length, length)]];
	//NSLog(@"bitlyURL:%@",bitlyURL);
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//NSLog(@">> didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//NSLog(@">> connectionDidFinishLoading");
}



// 북마크 버튼
- (IBAction)BookMark_btn{

	if (ArticleView_Flg) {
		
		appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];

		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"북마크 타이틀", @"북마크 타이틀")
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"취소", @"취소")
												   destructiveButtonTitle:nil
														otherButtonTitles:NSLocalizedString(@"북마크하기", @"북마크하기"), nil];
		actionSheet.tag = bookmarkActionSheet;
		//[actionSheet showInView:[[appDelegate.tabBarController subviews] objectAtIndex:0]];
		[actionSheet showInView:appDelegate.tabBarController.view];
		[actionSheet release];
	}
}

- (IBAction)MailSend_btn{
	
	Article *content = [contentArray objectAtIndex:0];
	
	if (bitlyURL == nil) {
		NSString *url = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=yongsuklee&apiKey=R_cf2ce2c57e5ea391da775fc021e575b1", [content.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
		[NSURLConnection connectionWithRequest:request delegate:self];
	}
	
	if (ArticleView_Flg) {

		
		appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];

		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"취소", @"취소")
												   destructiveButtonTitle:nil
														otherButtonTitles:NSLocalizedString(@"이메일", @"이메일"),NSLocalizedString(@"트위터", @"트위터"),NSLocalizedString(@"페이스북", @"페이스북"),NSLocalizedString(@"미투데이", @"미투데이"),NSLocalizedString(@"카카오톡", @"카카오톡"), nil];
		actionSheet.tag = shareActionSheet;
		[actionSheet showInView:appDelegate.tabBarController.view];
		[actionSheet release];
		
	}
}


#pragma mark actionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];

	if(actionSheet.tag == bookmarkActionSheet){
		switch (buttonIndex) {
			case 0:		// 북마크하기
			{
				BookMarkListContent *ListContent = [[BookMarkListContent alloc] init];
				Article *content = [contentArray objectAtIndex:0];
				ListContent.idnum       = content.idnum;
				ListContent.title       = content.title;
				ListContent.content     = content.content;
				ListContent.permalink   = content.permalink;
				ListContent.description = content.description;
				ListContent.image       = content.image;
				[appDelegate getBookmarkList];
				[appDelegate insertBookmark:ListContent];
				[ListContent release];

				break;
			}

		}
	}
	else if(actionSheet.tag == shareActionSheet){
		switch (buttonIndex) {
			case 0:		// 메일 보내기
			{
				if (self.delegate != nil && [self.delegate respondsToSelector:@selector(MailSendViewCtrl:)]) {
					[self.delegate MailSendViewCtrl:contentArray];
				}

				break;
			}
			case 1:		// Twitter
			{
				if (self.delegate != nil && [self.delegate respondsToSelector:@selector(TwitterSendViewCtrl:atshortUrl:)]) {
					[self.delegate TwitterSendViewCtrl:contentArray atshortUrl:bitlyURL];
				}				
				
				break;
			}
			case 2:		// FaceBook
			{
				
				if (self.delegate != nil && [self.delegate respondsToSelector:@selector(FaceBookSendViewCtrl:atshortUrl:)]) {
					[self.delegate FaceBookSendViewCtrl:contentArray atshortUrl:bitlyURL];
				}				
				break;
			}
			case 3:		// me2Day
			{
				if (self.delegate != nil && [self.delegate respondsToSelector:@selector(me2daySendViewCtrl:atshortUrl:)]) {
					[self.delegate me2daySendViewCtrl:contentArray atshortUrl:bitlyURL];
				}								
				break;
			}
			case 4:		// kakaotalk
			{
				if (self.delegate != nil && [self.delegate respondsToSelector:@selector(me2daySendViewCtrl:atshortUrl:)]) {
					[self.delegate kakaotalkSendViewCtrl:contentArray atshortUrl:bitlyURL];
				}								
				break;
			}
		}
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;

}
@end
