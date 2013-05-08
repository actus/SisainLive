//
//  ArticleDetailViewController.m
//  sisain
//
//  Created by snow leopard on 10. 8. 3..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArticleDetailViewController.h"
#import "Article.h"
#import "ArticleListContent.h"
#import "BookMarkListContent.h"
#import "MailCompose.h"
#import "SisainliveAppDelegate.h"

@interface ArticleDetailViewController ()

// 기사정보 데이터 취득이벤트
- (void)getArticle;
// 기사정보 표시이벤트
- (void)loadArticle;

// 메일 전송 후 메세지 표시 이벤트
- (void)messageAlertView:(NSString *)aMessage;

- (void)setupSpinView:(BOOL)flag message:(NSString *)message;
@end


@implementation ArticleDetailViewController
@synthesize idnumber;
@synthesize ViewFlg;
@synthesize contentArray;
@synthesize contentParser;
@synthesize ListDataArray;
@synthesize CountDataArray;
@synthesize contentSendFlg;
@synthesize row;

typedef enum {
	shareActionSheet = 1,
} actionSheetTag;

typedef enum {
	nonShare = 0,
	mailShare,
	facebookShare,
	twitterShare
} kingOfShareMode;



/* 광고 삽입을 위해서 수정 11/01/18
 - (void)loadView {
 
 NSLog(@"loadView");
 web = [[PSWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 400.0f-48.0f)];
 
 self.view = web;
 
 }
 */

#pragma mark -
#pragma mark viewDidLoad

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    web = [[PSWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, deviceHeight-78.0f)];
	
	[self.view addSubview:web];
	
	NSInteger networkStatus;
	
	// 네트워크 연결상태 확인
	networkStatus = [self checkNetworkStatus];
	
	if (networkStatus != network_disable) {
		
		// 해당 기사파일 로드
		[self getArticle];
	}
	else {
		[self showNetworkError];
	}
	
	kingofShare = nonShare;
	
	
	// 액션시트 실행 버튼 설정
	UIBarButtonItem *barButtonItem = nil;
	
    barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
																  target:self 
																  action:@selector(actionSheetAction)];
	
	self.navigationItem.rightBarButtonItem = barButtonItem;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[barButtonItem release];
}

- (void)viewWillAppear:(BOOL)animated {
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	
	appDelegate.adview.frame = CGRectMake(0.0f, 320, 320.0f, 48.0f);
	
	if ([appDelegate.adview superview]) {
		[appDelegate.adview removeFromSuperview];
		[self.view addSubview:appDelegate.adview];
	}else {
		[self.view addSubview:appDelegate.adview];
	}
	
}

- (void)viewWillDisappear:(BOOL)animated {
	if (contentParser) {
		[contentParser stop];
	}
	[web stopLoading];
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
	[web release];
//	[kakaotalk release];
	[idnumber      release];
	[ViewFlg       release];
	[contentArray  release];
	[ListDataArray release];
	[CountDataArray release];
	if (bitlyURL)
		[bitlyURL release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark ArticleParser delegate
// 기사정보 데이터 취득
- (void)getArticle{
	
	
	if (contentSendFlg) {
		
		NSMutableDictionary *cellcontentdic = [ListDataArray objectAtIndex:row];
		
		ArticleListContent *ListData = [cellcontentdic objectForKey:CONTENTDIC];
		
		
		//	ArticleListContent *ListData = [ListDataArray objectAtIndex:row];
		
		contentArray = [[NSMutableArray alloc] initWithCapacity:0];
		self.contentParser = [[[ArticleParser alloc] init] autorelease];
		contentParser.delegate = self;
		[contentParser start:ListData.link_id];
	}else {
		ArticleListContent *ListData = [ListDataArray objectAtIndex:row];
		
		contentArray = [[NSMutableArray alloc] initWithCapacity:0];
		self.contentParser = [[[ArticleParser alloc] init] autorelease];
		contentParser.delegate = self;
		[contentParser start:ListData.link_id];
		
	}
}

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
	
	int totalcount;
	int numbercount;
	if ([ViewFlg isEqualToString:@"MAIN"]) {
		totalcount = [CountDataArray count]+1;
		numbercount = 1;
	}else {
		if ([CountDataArray count] > 0) {
			totalcount = [ListDataArray count]+1;
			numbercount = 2;
		}
		else {
			totalcount = [ListDataArray count];
			numbercount = 1;
		}
		
		
	}
	
	NSString *TitleString = [NSString stringWithFormat:@"%d/%d",row+numbercount,totalcount];
	
	self.navigationItem.title = TitleString;
	
	web.delegate = self;
	[web loadHTMLString:content.content baseURL:nil];
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	/*
	 if (bitlyURL == nil) {
	 NSString *url = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=yongsuklee&apiKey=R_cf2ce2c57e5ea391da775fc021e575b1", [content.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	 NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	 [NSURLConnection connectionWithRequest:request delegate:self];
	 }
	 */
}

- (void)ArticleCountUP{
	if (row == 0) {
	}
	else {
		row = row-1;
		[self getArticle];
	}
}

- (void)ArticleCountDown{
	if (row == [ListDataArray count]-1) {
	}
	else {
		row = row+1;
		[self getArticle];
		
	}
	
}
- (void)facebookinstallHook{
	
	//	[web installHook];
	
}
- (void)installHook{
	
	//	[web installHook];
	
}

- (void)UninstallHook{
	
	//	[web uninstallHook];
	
}

#pragma mark -
#pragma mark actionSheet delegate
- (void)actionSheetAction {
	
	Article *content = [contentArray objectAtIndex:0];
	
	if (bitlyURL == nil) {
		NSString *url = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=yongsuklee&apiKey=R_cf2ce2c57e5ea391da775fc021e575b1", [content.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
		[NSURLConnection connectionWithRequest:request delegate:self];
	}
	
	[self UninstallHook];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"취소", @"취소")
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"북마크", @"북마크"),NSLocalizedString(@"이메일", @"이메일"),NSLocalizedString(@"트위터", @"트위터"),NSLocalizedString(@"페이스북", @"페이스북"),NSLocalizedString(@"미투데이", @"미투데이"),NSLocalizedString(@"카카오톡", @"카카오톡"), nil];
	actionSheet.tag = shareActionSheet;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
	
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	kingofShare = buttonIndex + 1;
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
			[self installHook];
			break;
			
		}
		case 1:		// 메일보내기
		{
			if (bitlyURL == nil) {
				Article *mailcontent = [contentArray objectAtIndex:0];
				NSString *url = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=yongsuklee&apiKey=R_cf2ce2c57e5ea391da775fc021e575b1", [mailcontent.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
				[NSURLConnection connectionWithRequest:request delegate:self];
			}
			else {
				
				Article *mailcontent = [contentArray objectAtIndex:0];
				
				MailCompose *picker = [[MailCompose alloc] init];
				picker.mailComposeDelegate = self;
				[picker setSubject:mailcontent.title];
				[picker setMessageBody:[NSString stringWithFormat:@"%@\n%@",mailcontent.content,bitlyURL] isHTML:YES];
				[self presentModalViewController:picker animated:YES];
				[picker release];
			}
			break;
		}
		case 2:		// 트위터
		{
			
			if (bitlyURL == nil) {
				Article *twittercontent = [contentArray objectAtIndex:0];
				NSString *url = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=yongsuklee&apiKey=R_cf2ce2c57e5ea391da775fc021e575b1", [twittercontent.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
				[NSURLConnection connectionWithRequest:request delegate:self];
			}
			else {
				
//				// 베이직 인증 방식에서 OAuth방식으로 변경
//				Article *twittercontent = [contentArray objectAtIndex:0];				
//				[twitter release];
//				twitter = nil;
//				
//				if (twitter == nil) {
//					twitter = [[TwitterClass alloc] init];
//					[twitter setConsumerKey:kOAuthConsumerKey];
//					[twitter setConsumerSecret:kOAuthConsumerSecret];
//					twitter.delegate = self;
//					[twitter initWithViewCtrl];
//				}
//				[twitter setTitle:twittercontent.title];
//				[twitter setUrl:bitlyURL];
//				[twitter start];
				
				
			}
			
			break;
		}
		case 3:		// facebook
		{	
			if (bitlyURL == nil) {
				Article *facebookcontent = [contentArray objectAtIndex:0];
				NSString *url = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=yongsuklee&apiKey=R_cf2ce2c57e5ea391da775fc021e575b1", [facebookcontent.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
				[NSURLConnection connectionWithRequest:request delegate:self];
			}
			else {
				SisainliveAppDelegate *sisaappDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
				Article *facebookcontent = [contentArray objectAtIndex:0];
				appDelegate.facebook.titleExplain = @"지금 무슨 생각하고 계신가요?";
				appDelegate.facebook.description = @"www.sisainlive.com";
				[sisaappDelegate.facebook sendMsg:facebookcontent.title atTo:facebookcontent.image atTo:bitlyURL];				
				
				
			}
			break;
		}
		case 4:		// me2Day
		{	
			/*
			 // Web방식으로 인증을 했을 경우
			 // 별도의 키가 필요없이 해당 URL에 데이터 전송만 해주면 글이 새로 등록되어 진다
			 Article *content = [contentArray objectAtIndex:0];
			 NSString *urlAddress = [NSString stringWithFormat:me2day_url,content.permalink];
			 NSLog(@">>urlAddress:%@",urlAddress);
			 NSURL *url = [NSURL URLWithString:urlAddress];
			 NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
			 [web loadRequest:requestObj];
			 */
			if (bitlyURL == nil) {
				Article *facebookcontent = [contentArray objectAtIndex:0];
				NSString *url = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=sisain&apiKey=R_3f002d2bf8d3d19f74e9e2f10f0f4a08", [facebookcontent.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
				[NSURLConnection connectionWithRequest:request delegate:self];
			}
			else {
				/*
				 Article *me2daycontent = [contentArray objectAtIndex:0];
				 if (me2day == nil) {
				 me2day = [[Me2dayClass alloc] initWithViewCtrl:me2daycontent.title url:bitlyURL];
				 me2day.delegate = self;
				 }
				 [me2day start:me2daycontent.permalink toTitle:me2daycontent.title];
				 */
				Article *me2daycontent = [contentArray objectAtIndex:0];				
				if (me2day == nil) {
					me2day = [[me2dayClass alloc] init];
					[me2day setApikey:me2dayAPIKey];
					[me2day setMd5key:nonce];
					me2day.delegate = self;
				}
				[me2day setTitle:me2daycontent.title];
				[me2day setLinkTitle:me2daycontent.title atLink:bitlyURL];
				[me2day setTag:@"시사INLive"];
				
				[me2day sendMessage];
				
				
			}
			
			break;
		}
		case 5:		// 카카오톡 링크
		{	
			
			if (bitlyURL == nil) {
				Article *kakaotalkcontent = [contentArray objectAtIndex:0];
				NSString *url = [NSString stringWithFormat:@"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=sisain&apiKey=R_3f002d2bf8d3d19f74e9e2f10f0f4a08", [kakaotalkcontent.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
				[NSURLConnection connectionWithRequest:request delegate:self];
			}
			else {
				Article *kakaotalkcontent = [contentArray objectAtIndex:0];
				
//				if (kakaotalk == nil) {
//					kakaotalk = [[kakaotalkClass alloc] init];
//				}
//				[kakaotalk setMsg:kakaotalkcontent.title];
//				[kakaotalk setUrl:bitlyURL];
//				
//				[kakaotalk sendMessage];
//			
			}
			
			break;
		}			
			
		default:
		{
			[self installHook];
			break;
		}
	}
}

#pragma mark -
#pragma mark Compose Mail

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
	
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			[self messageAlertView:NSLocalizedString(@"메세지 전송 완료", @"메세지 전송 완료")];
			break;
		case MFMailComposeResultFailed:
			[self messageAlertView:NSLocalizedString(@"메세지 전송 실패", @"메세지 전송 실패")];
			break;
		default:
			break;
	}
	[self installHook];
	[self dismissModalViewControllerAnimated:YES];
	
}

#pragma mark - 
#pragma mark shot alertView
- (void)messageAlertView:(NSString *)aMessage {
	UIAlertView *resAlert = [[UIAlertView alloc] initWithTitle:aMessage 
													   message:nil
													  delegate:self
											 cancelButtonTitle:NSLocalizedString(@"확인", @"확인") 
											 otherButtonTitles:nil];
	[resAlert show];
	[resAlert release];
}


#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	//	NSLog(@">> didReceiveResponse");
}

/**
 압축URL생성
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
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
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//	NSLog(@">> didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//	NSLog(@">> connectionDidFinishLoading");
}



#pragma mark Me2DAYClass delegate

- (void)Me2dayAction:(NSInteger)action {
	if (action == 1) {
		[self setupSpinView:YES message:@"확인중...."];
	}
	else if (action == 2) {
		[self setupSpinView:YES message:@"전송중...."];
	}
	else if (action == 3) {
		[self setupSpinView:NO message:@""];
	}
}

#pragma mark - 
#pragma mark setupSpinView

- (void)setupSpinView:(BOOL)flag message:(NSString *)message {
	if (flag) {
		UIView *spinView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
		spinView.tag = SPINVIEW_TAG;
		spinView.backgroundColor = [UIColor blackColor];
		spinView.alpha = 0.7f;
		
		UIActivityIndicatorView *spin = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		
		CGPoint center = spinView.center;
		center.x -= 50;
		spin.center = center;
		[spin startAnimating];
		[spinView addSubview:spin];
		[spin release];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 20.0f)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor whiteColor];
		label.text = message;
		center.x += 70;
		label.center = center;
		[spinView addSubview:label];
		[label release];
		
		[self.view addSubview:spinView];
		[spinView release];
	}
	else {
		UIView *spinView = [self.view viewWithTag:SPINVIEW_TAG];
		[spinView removeFromSuperview];
		spinView = nil;
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}


- (void)showTwitterViewCtrl:(UIViewController *)controller {
	[self presentModalViewController:controller animated:YES];
}

- (void)twitterSendMsgIsSuccessed{
	[self messageAlertView:NSLocalizedString(@"메세지 전송 완료", @"메세지 전송 완료")];
	
}
- (void)twitterSendMsgIsFaild{
	[self messageAlertView:NSLocalizedString(@"메세지 전송 실패", @"메세지 전송 실패")];
}


@end
