//
//  BookScreenViewCtrl.m
//  Sisainlive
//
//  Created by snow leopard on 10. 8. 24..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BookScreenViewCtrl.h"
#import "SisainliveAppDelegate.h"
#import "Book.h"
#import "Article.h"
#import "MailCompose.h"

#define LATEST_BOOKNUM_PATH @"LatestBookNumber.txt"
#define PAGE_IMAGE_FILE_PREFIX @"ThirdViewController_"
#define READ_TO_MEMORY_PLUS_MINUS 2

typedef enum {
	screenredown = 1,
	newbookdown
} alertViewMode;

@interface BookScreenViewCtrl ()
- (NSMutableArray *)leftItemReSetting:(NSMutableArray*)itemArray;
- (NSMutableArray *)rightItemReSetting:(NSMutableArray*)itemArray;
- (NSString *)nsMutableArrayToNSString:(NSMutableArray *)dataMu;
- (void)showalertViewController:(NSInteger)indexPath;

@end


@implementation BookScreenViewCtrl
@synthesize contentParser;
@synthesize bookParser;
@synthesize bookcontentArray;
@synthesize PageNumber_Btn;
@synthesize articleViewCtrl;
@synthesize settingView;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// 재 다운로드 플래그 초기설정
	ReDownload = @"NO";
	
	documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] retain];
	
	LaitemArray = [[NSMutableArray alloc] init];
	
	// 이미지 관련 데이터 임시 저장 변수 설정
	imageViewsInScrollView1 = [[NSMutableArray alloc] init];
	imageViewsInScrollView2 = [[NSMutableArray alloc] init];
	imageFileNamesForScrollView1 = [[NSMutableArray alloc] init];
	imageFileNamesForScrollView2 = [[NSMutableArray alloc] init];
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	// 아이폰 디바이스 확인
	if ([[appDelegate platform] isEqualToString:@"iPhone3,1"]) {
		version = 4;
	} else {
		version = -1;
	}
	
	// 화면배경색 변경
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	// XML파싱 처리가 끝나면 실행
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parsingEnded:) name:@"ParsingEnded" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dialogShowstatus:) name:@"dialogStatus" object:nil];
	
	
}

#pragma mark Start

- (void)viewWillAppear:(BOOL)animated {
	
	// 화면 회전이 일어났을 시에 전체적으로 플래그를 설정하여 화면을 회전 시켜준다.(면별보기 세로보기,가로보기)
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	appDelegate.OrientationFlg = @"YES";
	
	[appDelegate.adview setOrView:YES];
	
	ViewFlg = YES;
	// 다운로드 완료시 메세지 박스 표시를 위한 플래그 설정
	DownEndFlg = YES;
	if ([appDelegate.mailviewFlg isEqualToString:@"YES"]) {
		[self shouldAutorotateToInterfaceOrientation:[[UIDevice currentDevice] orientation]];
		
	}else {
		// XML데이터의 내용이 있을 시에는 시작하지 않음
		if ([self.contentParser.portraitObjects count] <= 0){
			[self getContent];
		}
		else {
			if (portraitcount != 0) {
				portraitcount = portraitcount-1;
			}
			// 기존에 다운로드 하는 것을 완료한 다음 새로운 책이 있으면 다시 다운로드 실행
			if (portraitcount == [self.contentParser.portraitObjects count]) {
				if ([scrollView2 superview]) {
					[scrollView2 removeFromSuperview];
				}
				[self getContent];
			}
		}
		
		// 페이지 번호 표시 버튼 설정
        PageNumber_Btn = [[UIButton alloc] initWithFrame:CGRectMake(135.0f, deviceHeight - 100, 70.0f, 30.0f)];

    
		PageNumberString = [NSString stringWithFormat:@"%d/%d", pageNumber,Portrait_TotalNumber];
		[PageNumber_Btn setTitle:PageNumberString forState:UIControlStateNormal];
		[PageNumber_Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[PageNumber_Btn addTarget:self action:@selector(PageNumberbuttonPressed) forControlEvents:UIControlEventTouchUpInside];
		PageNumber_Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
		[PageNumber_Btn setBackgroundColor:[UIColor blackColor]];
		[PageNumber_Btn setAlpha:0.5f];
		[self.view addSubview:PageNumber_Btn];

	}
}

#pragma mark -
#pragma mark BookNumParser
- (void)getContent {
	
	bookcontentArray = [[NSMutableArray alloc] initWithCapacity:0];
	self.bookParser = [[[BookNumParser alloc] init] autorelease];
	bookParser.delegate = self;
	
	NSInteger networkStatus;
	networkStatus = [self checkNetworkStatus];
	
	if (networkStatus != network_disable) {
		[self NOshowNetworkError];
		[bookParser start];
	}
	else {
		[self showNetworkError];
	}
}


- (void)parser:(id)parser didParseContents:(NSArray *)parsedContents{
	
    [bookcontentArray addObjectsFromArray:parsedContents];
	
	if (pageNumber<=0) {
		pageNumber = 1;
	}	
	[self loadBookNum];
	
}

#pragma mark loadBookNum
// 책번호에 대한 데이터 취득후에 실행
- (void)loadBookNum{
	
	
	
	Book *content = [bookcontentArray objectAtIndex:0];
	self.contentParser = [[[XMLParser alloc] init] autorelease];
	
	NSInteger networkStatus;
	
	// 네트워크 상태 확인
	networkStatus = [self checkNetworkStatus];
	
	if (networkStatus != network_disable) {
		
		// 디바이스안의 이미지 파일 저장소 패스 설정
		NSString *bookNumberPath = [documentPath stringByAppendingPathComponent:LATEST_BOOKNUM_PATH];
		
		// 디바이스 안에 저장되어 있는 책호수 번호 취득
		BookNumber_Conf = [NSString stringWithContentsOfFile:bookNumberPath encoding:NSASCIIStringEncoding error:nil];
		
		// 디바이스 안에 책호수 번호가 없을 경우 : 취득한 데이터로 책의 이미지 파일을 다운로드 한다.
		if (BookNumber_Conf == nil) {
			[self showalertViewController:1];
			BookNumber_Conf = content.Booknum;
		}
		// 재 다운로드 버튼을 클릭한 후에 면별보기 화면으로 이동했을 경우 :
		// 디바이스안에 저장되어 있는 파일을 삭제 후에 이미지 파일을 재다운로드 한다.
		else {
			if([ReDownload isEqualToString:@"YES"]){
				ReDownload = @"NO";
				pageNumber = 1;
				NSFileManager *fileManager = [NSFileManager defaultManager];
				NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
				for (NSString *fileName in contentsOfDirectory) {
					int count = [fileName length];
					if (count > 20) {
						if ([[fileName substringToIndex:20] isEqualToString:PAGE_IMAGE_FILE_PREFIX]) {
							[fileManager removeItemAtPath:[documentPath stringByAppendingPathComponent:fileName] error:nil];
						}
					}
				}
				
				// 새로 다운로드 시작한다.
				BookNumber_Conf = content.Booknum;
				[contentParser start:BookNumber_Conf];
				
			}
			// XML파서만 끝나고 데이터를 취득하지 못했을 경우 :
			// 탭바를 초기에 여러번 이동 하였을 경우 발생 :
			// 이미지 파일이 있는지 여부를 확인하여 재다운로드 한다.
			else if ([BookNumber_Conf isEqualToString:content.Booknum]) {

				BOOL ReDownloadFlg = YES;
				NSFileManager *fileManager = [NSFileManager defaultManager];
				NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
				
				for (NSString *fileName	in contentsOfDirectory) {
					int count = [fileName length];
					if (count > 20) {
						if ([[fileName substringToIndex:20] isEqualToString:PAGE_IMAGE_FILE_PREFIX]) {
							ReDownloadFlg = NO;
						}
					}
				}
				if (ReDownloadFlg ||[imageViewsInScrollView1 count] <= 0 || [imageViewsInScrollView2 count] <= 0) {
					// 새로 다운로드 시작한다.
					BookNumber_Conf = content.Booknum;
					[contentParser start:BookNumber_Conf];
				}
				else {
					// 기존에 있던 데이터를 남겨두고 다운로드 시작
					if (pageNumber <= 0) {
						pageNumber = 1;
					}
					[self readImage:pageNumber scrollView:scrollView1];
				}
			}
			// 취득한 데이터와 디바이스 안에 저장되어 있는 책번호가 틀릴 경우 :
			// 재 다운로드를 시작한다.
			else {
				
				[self showalertViewController:2];
				
				BookNumber_Conf = content.Booknum;
				
			}
		}
		// 취득한 책호수의 번호를 디바이스에 저장한다.
		[BookNumber_Conf writeToFile:bookNumberPath atomically:YES encoding:NSASCIIStringEncoding error:nil];	
	}
	else {
		[self showNetworkError];
	}
}

#pragma mark -
#pragma mark showalertViewController
- (void)showalertViewController:(NSInteger)indexPath{

	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	appDelegate.OrientationFlg = @"NO";
	
	switch (indexPath) {
		case 1:
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"bookscreenDown", @"bookscreenDown")
															message:nil
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"취소", @"취소")
												  otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
			
			UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,20,260,100)];
			textLabel.font = [UIFont systemFontOfSize:16];
			textLabel.textColor = [UIColor whiteColor];
			textLabel.backgroundColor = [UIColor clearColor];
			textLabel.numberOfLines = 2;
			textLabel.textAlignment = UITextAlignmentCenter;
			textLabel.text = NSLocalizedString(@"redownMSG", @"redownMSG");
			[alert addSubview:textLabel];
			
			alert.tag = screenredown;
			[alert show];
			[alert release];
		}
			break;
		case 2:
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"bookscreenDown", @"bookscreenDown")
															message:nil
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"취소", @"취소")
												  otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
			
			UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,20,260,100)];
			textLabel.font = [UIFont systemFontOfSize:16];
			textLabel.textColor = [UIColor whiteColor];
			textLabel.backgroundColor = [UIColor clearColor];
			textLabel.numberOfLines = 2;
			textLabel.textAlignment = UITextAlignmentCenter;
			textLabel.text = NSLocalizedString(@"redownMSG", @"redownMSG");
			[alert addSubview:textLabel];
			
			alert.tag = newbookdown;
			[alert show];
			[alert release];			
		}
			
			break;

		default:
			break;
	}



}

#pragma mark -
#pragma mark XMLParser

static NSString *k_img		    = @"img";
static NSString *k_item		    = @"item";

// 책호수 이미지에 대한 데이터 취득이 완료된 후
// XML데이터 취득이 끝난 후에 실행(취득한 정보를 처리)
- (void)parsingEnded:(NSNotification *)notification {
	
	// 세로보기 
	scrollView1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, porWidth, deviceHeight-69)];
	
	// ScrollViewSetting
	
	scrollView1.contentSize = CGSizeMake(([self.contentParser.portraitObjects count] * porWidth), deviceHeight-69);
	scrollView1.backgroundColor = [UIColor blackColor];
	scrollView1.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView1.pagingEnabled = YES;
	scrollView1.scrollEnabled = YES;
	scrollView1.scrollsToTop = NO;
	scrollView1.canCancelContentTouches = NO;
	scrollView1.clipsToBounds = NO;		// default is NO, we want to restrict drawing within our scrollview
	scrollView1.delegate = self;
	scrollView1.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:scrollView1];
	Start_Flg = NO;
	
	UIImage *defaultL = [[UIImage alloc] init];
	UIImage *defaultP = [[UIImage alloc] init];
	
	defaultL = DefaultL;
	defaultP = DefaultP;
	
	for (int i = 0; i < [self.contentParser.portraitObjects count]; i++) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:defaultP];
		[self addImageView:imageView toScrollView:scrollView1 atIndex:i];
		[imageView release];
	}
	landscape_TotalNumber = ([self.contentParser.portraitObjects count]+2)/2;

	// 가로보기
	scrollView2 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, deviceHeight, lanHeight)];
	
	// ScrollViewSetting
	scrollView2.contentSize	= CGSizeMake((landscape_TotalNumber * deviceHeight), lanHeight);
	scrollView2.backgroundColor = [UIColor blackColor];
	scrollView2.indicatorStyle = UIScrollViewIndicatorStyleWhite;	
	scrollView2.pagingEnabled = YES;
	scrollView2.scrollEnabled = YES;
	scrollView2.scrollsToTop = NO;	
	scrollView2.canCancelContentTouches = NO;
	scrollView2.clipsToBounds = NO;		// default is NO, we want to restrict drawing within our scrollview
	scrollView2.delegate = self;	
	scrollView2.showsHorizontalScrollIndicator = NO;
	
	for (int i = 0; i < landscape_TotalNumber; i++) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:defaultL];
		[self addImageView:imageView toScrollView:scrollView2 atIndex:i];
		[imageView release];
	}
	
	PageNumberString = [NSString stringWithFormat:@"%d/%d", pageNumber,[self.contentParser.portraitObjects count]];
	
	[self.view addSubview:PageNumber_Btn];
	
	[PageNumber_Btn setTitle:PageNumberString forState:UIControlStateNormal];
	
	[self performSelectorInBackground:@selector(loadPortraitPageImage) withObject:nil];
}




// XML에서 취득한 내용의 이미지파일을 가공처리:세로보기
- (void)loadPortraitPageImage{
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.redownloadflg = YES;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	Portrait_TotalNumber = [self.contentParser.portraitObjects count];
	
	NSString *laimageString;
	
	for (portraitcount = 1; portraitcount <= [self.contentParser.portraitObjects count]; portraitcount++)
	{	
		NSMutableArray *laitem = [[[NSMutableArray alloc] init] autorelease];
		
		appDelegate.redownloadflg = YES;
		
		if ( Portrait_Number == 0) {
			Portrait_Number = portraitcount;
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			appDelegate.redownloadflg = YES;
			NSDictionary *dictionary = [self.contentParser.portraitObjects objectAtIndex:Portrait_Number-1];
			NSString *string = [dictionary objectForKey:k_img];
			NSMutableArray *item = [dictionary objectForKey:k_item];
			for (int i = 0; i < [item count]; i++) {
					NSMutableDictionary *dic = [item objectAtIndex:i];
					NSMutableDictionary *resetDic = [NSMutableDictionary dictionaryWithDictionary:dic];
					[laitem addObject:resetDic];
			}
			NSURL *url;
			// 아이폰 디바이스 확인 후에 iPhone4의 경우와 옵션이미지 표시
			if (version == 4) {
				
				NSArray *SubArrayString = [string componentsSeparatedByString:@"/"];
				NSString *bookNumber = [SubArrayString objectAtIndex:3];
				NSArray *ImgArray    = [[SubArrayString objectAtIndex:4] componentsSeparatedByString:@"."];
				NSString *ImgString = [NSString stringWithFormat:@"%@%@/%@%@.%@", iPhone4_imgurl,bookNumber,[ImgArray objectAtIndex:0], @"@2x", [ImgArray objectAtIndex:1]];
				url = [NSURL URLWithString:ImgString];
				
			}else {
				
				url = [NSURL URLWithString:string];
				
			}
			NSData *receivedData = [self downloadData:url toFile:[string lastPathComponent]];
			// iPhone4의 경우 옵션 이미지가 없을 시에는 기본이미지 사용
			if (receivedData == nil) {
				url = [NSURL URLWithString:string];
				receivedData = [self downloadData:url toFile:[string lastPathComponent]];
			}
			
			//[receivedData retain];
			[receivedData release];
			
			//UIImage *image = [UIImage imageWithData:receivedData];
			
			[imageFileNamesForScrollView1 addObject:[string lastPathComponent]];
			
			laimageString = [string lastPathComponent];
			// 이미지 삽입
			// 각 페이지의 터치이벤트
			ThumbImageView *imageView = [[ThumbImageView alloc] initWithFrame:CGRectZero];
			
			NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:imageView, @"imageView", scrollView1, @"scrollView", [NSNumber numberWithInt:portraitcount-1], @"index", nil];
			[self performSelectorOnMainThread:@selector(replaceImageView:) withObject:arguments waitUntilDone:YES];
			imageView.viewFlg = YES;
			
			if ([item count] > 0) {
				imageView.item = item;
			}
			imageView.delegate = self;
			imageView.tag = portraitcount;	// tag our images for later use when we place them in serial fashion
			[imageView release];
			
			
		}else if ( Portrait_Number >= portraitcount|| Portrait_Number < 0 ) {
			//			NSLog(@">>Portrait_Number:%d",Portrait_Number);
		}else {
			
			Portrait_Number = portraitcount;
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			appDelegate.redownloadflg = YES;
			didAbortParsing = NO;
			NSDictionary *dictionary = [self.contentParser.portraitObjects objectAtIndex:Portrait_Number-1];
			NSString *string = [dictionary objectForKey:k_img];
			NSMutableArray *item = [dictionary objectForKey:k_item];
			for (int i = 0; i < [item count]; i++) {
				NSMutableDictionary *dic = [item objectAtIndex:i];
				NSMutableDictionary *resetDic = [NSMutableDictionary dictionaryWithDictionary:dic];
				[laitem addObject:resetDic];
					
			}
			
			
			NSURL *url;
			
			// 아이폰 디바이스 확인 후에 iPhone4의 경우와 옵션이미지 표시
			if (version == 4) {
				
				NSArray *SubArrayString = [string componentsSeparatedByString:@"/"];
				NSString *bookNumber = [SubArrayString objectAtIndex:3];
				NSArray *ImgArray    = [[SubArrayString objectAtIndex:4] componentsSeparatedByString:@"."];
				NSString *ImgString = [NSString stringWithFormat:@"%@%@/%@%@.%@", iPhone4_imgurl,bookNumber,[ImgArray objectAtIndex:0], @"@2x", [ImgArray objectAtIndex:1]];
				url = [NSURL URLWithString:ImgString];
				
			}else {
				
				url = [NSURL URLWithString:string];
				
			}
			NSData *receivedData = [self downloadData:url toFile:[string lastPathComponent]];
			
			// iPhone4의 경우 옵션 이미지가 없을 시에는 기본이미지 사용
			if (receivedData == nil) {
				url = [NSURL URLWithString:string];
				receivedData = [self downloadData:url toFile:[string lastPathComponent]];
			}
			
			//[receivedData retain];
			[receivedData release];
			
			//UIImage *image = [UIImage imageWithData:receivedData];
			[imageFileNamesForScrollView1 addObject:[string lastPathComponent]];
			laimageString = [string lastPathComponent];
			
			// 이미지 삽입
			// 각 페이지의 터치이벤트
			ThumbImageView *imageView = [[ThumbImageView alloc] initWithFrame:CGRectZero];
			
			NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:imageView, @"imageView", scrollView1, @"scrollView", [NSNumber numberWithInt:portraitcount-1], @"index", nil];
			[self performSelectorOnMainThread:@selector(replaceImageView:) withObject:arguments waitUntilDone:YES];
			imageView.viewFlg = YES;
			if ([item count] > 0) {
				imageView.item = item;
			}
			imageView.delegate = self;
			imageView.tag = portraitcount;	// tag our images for later use when we place them in serial fashion
			[imageView release];
			
			if (Portrait_Number == [self.contentParser.portraitObjects count]) {
				Portrait_Number = 0;
				landscape_Number = 0;
			}
			
		}
		
		NSInteger numberpath;
		BOOL	screenLRFlg;
		if (portraitcount%2) {
			screenLRFlg = YES;
			// 첫페이지에서 회전한 경우(초기 설정)
			if (portraitcount <= 0) {
				numberpath = 1;
			}
			// 첫페이지는 무조건 1로 설정
			if (portraitcount == 1) {
				numberpath = 1;
			}
		}else {
			screenLRFlg = NO;
			// 세로보기2,3페이지의 경우는 2페이지 설정
			if(portraitcount == 2 || portraitcount == 3){
				numberpath = 2;
			}
			else {
				numberpath = (portraitcount+2)/2;
			}
		}
		laData = [[[NSMutableDictionary alloc] initWithCapacity:0]autorelease];
		
		if (screenLRFlg) {
			if (numberpath != 1) {
				
				if (LaitemArray != nil && [LaitemArray count] > 0) {

					NSMutableArray *itemArray = [LaitemArray objectAtIndex:0];
					NSMutableArray *reSetArray = [self rightItemReSetting:laitem];
					
					for (NSMutableDictionary *dic in reSetArray) {
						
						[itemArray addObject:dic];
					}
					[LaitemArray replaceObjectAtIndex:0 withObject:itemArray];
				}
				
				laData = [imageFileNamesForScrollView2 objectAtIndex:numberpath-1];
				NSString *defaultRString = [NSString stringWithFormat:@"R%d",numberpath];
				[laData setObject:laimageString forKey:defaultRString];
				[imageFileNamesForScrollView2 replaceObjectAtIndex:numberpath-1 withObject:laData];
				viewPageFlg = YES;
				
				
			}else {

				
				if (laitem != nil && [laitem count] > 0) {
					NSMutableArray *reSetArray = [self leftItemReSetting:laitem];
					[LaitemArray addObject:reSetArray];
				}
				
				NSString *defaultRString = [NSString stringWithFormat:@"R%d",numberpath];
				[laData setObject:laimageString forKey:defaultRString];
				[imageFileNamesForScrollView2 insertObject:laData atIndex:numberpath-1];
				viewPageFlg = YES;
			}
		}else {

			if (laitem != nil && [laitem count] > 0) {
				NSMutableArray *reSetArray = [self leftItemReSetting:laitem];
				[LaitemArray addObject:reSetArray];
			}
			
			NSString *defaultLString = [NSString stringWithFormat:@"L%d",numberpath];
			[laData setObject:laimageString forKey:defaultLString];
			[imageFileNamesForScrollView2 insertObject:laData atIndex:numberpath-1];
			viewPageFlg = NO;
		}
		
		if (viewPageFlg) {
			
			// 이미지 삽입
			// 각 페이지의 터치이벤트
			ThumbImageView *imageViewLa = [[ThumbImageView alloc] initWithFrame:CGRectZero];
			
			NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:imageViewLa, @"imageView", scrollView2, @"scrollView", [NSNumber numberWithInt:numberpath-1], @"index", nil];
			[self performSelectorOnMainThread:@selector(replaceImageView:) withObject:arguments waitUntilDone:YES];
//			[self performSelectorInBackground:@selector(replaceImageViewla:) withObject:arguments];
			imageViewLa.viewFlg = NO;
			
			if (LaitemArray != nil &&[LaitemArray count] > 0 ) {
				imageViewLa.item = [LaitemArray objectAtIndex:0];
			}

			imageViewLa.delegate = self;
			imageViewLa.tag = numberpath;	// tag our images for later use when we place them in serial fashion
			[imageViewLa release];
			
			[LaitemArray release];
			LaitemArray = nil;
			
			LaitemArray = [[NSMutableArray alloc] init];
		}	
		
		
	}
	if (!DownEndFlg) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"면별보기", @"면별보기")]
														message:nil
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
		alert.tag = 1;
		
		[alert show];
		[alert release];
	}
	
	appDelegate.redownloadflg = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[pool release];	
}


- (NSMutableArray *)leftItemReSetting:(NSMutableArray*)itemArray{
	
	CGFloat xScale = 240.0f/320.0f;
    CGFloat yScale = 320.0f/(deviceHeight - 69.0f);

	for (int i= 0; i < [itemArray count]; i++) {
		NSMutableDictionary *dic = [itemArray objectAtIndex:i];
		
		NSString *coords = [dic objectForKey:@"coords"];
		
		NSMutableArray *reSetArray = [[[NSMutableArray alloc] init] autorelease];
		
		if ([coords length] > 0) {
			NSArray *listItems = [coords componentsSeparatedByString:@","];
			
			for (int j = 0;  j < [listItems count]; j++) {
				if (j%2) {
					NSInteger yValue = [[listItems objectAtIndex:j] intValue]*yScale;
					NSString *yPoint = [NSString stringWithFormat:@"%d",yValue];
					[reSetArray addObject:yPoint];
				}else {
					NSInteger xValue = [[listItems objectAtIndex:j] intValue]*xScale;
					NSString *xPoint = [NSString stringWithFormat:@"%d",xValue];
					[reSetArray addObject:xPoint];
				}
			}
			
			NSString *changeString = [self nsMutableArrayToNSString:reSetArray];
			
			[dic setObject:changeString forKey:@"coords"];
			
			[itemArray replaceObjectAtIndex:i withObject:dic];
		}
	}
	
	
	return itemArray;
}


/**
 데이터 NSString으로 가공
 */
- (NSString *)nsMutableArrayToNSString:(NSMutableArray *)dataMu{
	
	NSString *changeString = @"";
	
	NSMutableDictionary *checkdic = [[NSMutableDictionary alloc] init];
	[checkdic setObject:@"" forKey:@"code"];
	for (int i =0; i < [dataMu count]; i++) {
		
		NSString *outString = [dataMu objectAtIndex:i];
		
		NSString *testString = [NSString stringWithFormat:@"%@,%@",[checkdic objectForKey:@"code"],outString];
		[checkdic setObject:testString forKey:@"code"];
	}
	
	
	
	NSString *string = [checkdic objectForKey:@"code"];
	
	if ([string length] > 0) {
		changeString = [string substringWithRange:NSMakeRange(1,[string length]-1)];
	}
	
	
	return changeString;
}



- (NSMutableArray *)rightItemReSetting:(NSMutableArray*)itemArray{
	
	CGFloat xScale = 240.0f/320.0f;
	CGFloat yScale = 320.0f/(deviceHeight - 69.0f);
	
	
	for (int i= 0; i < [itemArray count]; i++) {
		NSMutableDictionary *dic = [itemArray objectAtIndex:i];
		
		NSString *coords = [dic objectForKey:@"coords"];
		
		NSMutableArray *reSetArray = [[[NSMutableArray alloc] init] autorelease];
		
		if ([coords length] > 0) {
			NSArray *listItems = [coords componentsSeparatedByString:@","];
			
			for (int j = 0;  j < [listItems count]; j++) {
				if (j%2) {
					NSInteger yValue = [[listItems objectAtIndex:j] intValue]*yScale;
					NSString *yPoint = [NSString stringWithFormat:@"%d",yValue];
					[reSetArray addObject:yPoint];
				}else {
					NSInteger xValue = ([[listItems objectAtIndex:j] intValue]*xScale)+240;
					NSString *xPoint = [NSString stringWithFormat:@"%d",xValue];
					[reSetArray addObject:xPoint];
				}
			}
			
			NSString *changeString = [self nsMutableArrayToNSString:reSetArray];
			
			[dic setObject:changeString forKey:@"coords"];
			
			[itemArray replaceObjectAtIndex:i withObject:dic];
		}
	}
	return itemArray;
}


#pragma mark -
#pragma mark scrollViewDidScroll


// 스크롤시 페이지 번호 취득하기
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	if (scrollView == scrollView1) {
		
		CGFloat pageWidth = scrollView.frame.size.width;
		float pageFloat = (scrollView.contentOffset.x -pageWidth / 2 ) / pageWidth + 1;
		int page = (int)pageFloat;
		
		NSInteger newPageNumber = page+1;
		
		
		if (pageNumber != newPageNumber) {
			[self readImage:newPageNumber scrollView:scrollView];
		}
		pageNumber = newPageNumber;
		
		poPageNumber = newPageNumber;
		
		if (pageNumber == Portrait_TotalNumber) {
			PageNumberString = @"처음으로";
			PageNumber_Btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
		}
		else {
			if (pageNumber <= 0) {
				pageNumber = 1;
			}
			PageNumberString = [NSString stringWithFormat:@"%d/%d", pageNumber,Portrait_TotalNumber];
			PageNumber_Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
		}

		[PageNumber_Btn setTitle:PageNumberString forState:UIControlStateNormal];
		
		
	}
	else {
		
		CGFloat pageWidth = scrollView.frame.size.width;
		float pageFloat = (scrollView.contentOffset.x -pageWidth / 2 ) / pageWidth + 1;
		int page = (int)pageFloat;
		
		
		NSInteger newPageNumber = page+1;
		
		
		if (pageNumber != newPageNumber) {
			//[self readImage:newPageNumber scrollView:scrollView];
		}
		pageNumber = newPageNumber;
		
		laPageNumber = newPageNumber;
		if (pageNumber == landscape_TotalNumber) {
			PageNumberString = @"처음으로";
			PageNumber_Btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
		}
		else {
			if (pageNumber <= 0) {
				pageNumber = 1;
			}
			PageNumberString = [NSString stringWithFormat:@"%d/%d", pageNumber,landscape_TotalNumber];
			PageNumber_Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
		}

		[PageNumber_Btn setTitle:PageNumberString forState:UIControlStateNormal];
		
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	
	
	if (scrollView == scrollView2) {
		
		[self readImage:pageNumber scrollView:scrollView];
		
	}else {

	}

}

#pragma mark -
#pragma mark thumbImageTouchEnded

// 면별보기 데이터 중 기사파일 데이터가 있는 부분을 클릭 했을 경우
//- (void)thumbImageTouchEnded:(NSString *)idno {
- (void)thumbImageTouchEnded:(NSString *)idno atAd:(NSString *)ad{
	
	articleViewCtrl = [[ArticleViewCtrl alloc] initWithNibName:@"ArticleViewCtrl" bundle:[NSBundle	mainBundle]];

	articleViewCtrl.idnumber = idno;
	articleViewCtrl.adUrl = ad;
	Articlead = ad;
	Articleidnum = idno;
	articleViewCtrl.delegate = self;
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	if (receivedRotate) {
		articleViewCtrl.view.frame = CGRectMake(0, 0, deviceHeight, 320);
		articleViewCtrl.myWebView.frame = CGRectMake(0.0f, 0.0f, deviceHeight, 272.0f);
//		articleViewCtrl.backgroundView.image = LaScreenImage;
//		articleViewCtrl.backgroundView.frame = CGRectMake(10.0f, 15.0f, 460, 290);
		articleViewCtrl.CloseBtn.frame = CGRectMake(440.0f, 5.0f, 30.0f, 30.0f);
		articleViewCtrl.BookMarkBtn.frame = CGRectMake(400.0f, 5.0f, 30.0f, 30.0f);
		articleViewCtrl.MailBtn.frame = CGRectMake(360.0f, 5.0f, 30.0f, 30.0f);
		articleViewCtrl.MailBtn.hidden = YES;
		[appDelegate.tabBarController.view addSubview:articleViewCtrl.view];
		appDelegate.adview.frame = CGRectMake(0.0f, 272.0f, deviceHeight, 48.0f);
		
	}
	else {
		articleViewCtrl.view.frame = CGRectMake(0, 0, 320, deviceHeight);
        articleViewCtrl.myWebView.frame = CGRectMake(0.0f, 20.0f, 320.0f, deviceHeight - 68);
//		articleViewCtrl.backgroundView.frame = CGRectMake(10.0f, 35.0f, 300, 430);
//		articleViewCtrl.backgroundView.image = PoScreenImage;
		articleViewCtrl.CloseBtn.frame = CGRectMake(280.0f, 30.0f, 30.0f, 30.0f);
		articleViewCtrl.BookMarkBtn.frame = CGRectMake(240.0f, 30.0f, 30.0f, 30.0f);
		articleViewCtrl.MailBtn.frame = CGRectMake(200.0f, 30.0f, 30.0f, 30.0f);
		articleViewCtrl.MailBtn.hidden = NO;
		[appDelegate.tabBarController.view addSubview:articleViewCtrl.view];

		appDelegate.adview.frame = CGRectMake(0.0f, 432.0f, 320, 48.0f);
	}
}


- (void)btnPressedClosed{

	if ([articleViewCtrl.view superview]) {
		[articleViewCtrl.view removeFromSuperview];
		[articleViewCtrl release];
		articleViewCtrl = nil;
	}
}

- (void)PageButtonHidden{
	
	PageNumber_Btn.hidden = YES;
}

- (void)PageButtonHiddenNO{
	
	PageNumber_Btn.hidden = NO;
}


#pragma mark -
#pragma mark Ended

- (void)viewWillDisappear:(BOOL)animated {
	
	ViewFlg = NO;
	DownEndFlg = NO;
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	appDelegate.OrientationFlg = @"NO";
	
	[appDelegate.adview setOrView:NO];
	
	if ([appDelegate.mailviewFlg isEqualToString:@"YES"]) {
		
	}else {
		
		if ([PageNumber_Btn superview])  {
			[PageNumber_Btn removeFromSuperview];
		}
	}
}


#pragma mark -
#pragma mark shouldAutorotateToInterfaceOrientation

// 화면회전에 대한 세로보기 가로보기에 대한 처리
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
	//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	UIApplication *app = [UIApplication sharedApplication];
	
	if ([appDelegate.mailviewFlg isEqualToString:@"YES"]) {
		
		
	}else {
		if ([appDelegate.OrientationFlg isEqualToString:@"YES"]) {
			
			if (interfaceOrientation == UIInterfaceOrientationPortrait
				||interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
				receivedRotate = NO;
				PageNumberButtonFlg = NO;
				[app setStatusBarHidden:NO];
				[scrollView2 removeFromSuperview];
/*
				// 첫페이지는 무조건 1로 설정
				if (pageNumber <= 0) {
					pageNumber = 1;
				}
				if (pageNumber == 1) {
					pageNumber = 1;
				}
				// 가로보기가 맨마지막이었던 경우 세로보기도 마지막 페이지 설정
				else if( pageNumber==landscape_TotalNumber ){
//					pageNumber=[self.contentParser.portraitObjects count];
					pageNumber = (pageNumber * 2)-2;
				}
				// 가로보기 페이지를 계산하여 세로보기 설정
				// ex) 가로보기 페이지 : 6
				//     세로보기 페이지 : 10 = (6*2)-2
				else {
					pageNumber = (pageNumber * 2)-2;
				}
*/				
				// 첫페이지는 무조건 1로 설정
				if (laPageNumber <= 0) {
					pageNumber = 1;
					laPageNumber= 1;
				}
				if (laPageNumber == 1) {
					pageNumber = 1;
					laPageNumber= 1;
				}
				// 가로보기가 맨마지막이었던 경우 세로보기도 마지막 페이지 설정
				else if( laPageNumber==landscape_TotalNumber ){
					//					pageNumber=[self.contentParser.portraitObjects count];
					pageNumber = (laPageNumber * 2)-2;
				}
				// 가로보기 페이지를 계산하여 세로보기 설정
				// ex) 가로보기 페이지 : 6
				//     세로보기 페이지 : 10 = (6*2)-2
				else {
					pageNumber = (laPageNumber * 2)-2;
				}
				
				// 세로보기화면에서 해당 페이지 표시
				CGRect frame = scrollView1.frame;
				frame.origin.x = frame.size.width * (pageNumber-1);
				frame.origin.y = 0;
				[scrollView1 scrollRectToVisible:frame animated:NO];
			
				poPageNumber = pageNumber;
				
				// 메모리에 이미지 로드해서 보여주기
				if ([imageFileNamesForScrollView1 count] > pageNumber - 1) {
					NSString *imageFileName = [imageFileNamesForScrollView1 objectAtIndex:pageNumber - 1];
					NSString *imageFilePath = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:imageFileName]];
					UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
					UIImageView *imageView = [imageViewsInScrollView1 objectAtIndex:pageNumber - 1];
					[imageView setImage:image];
				}
				
				[self PortraitButtonSetting];
				
				
				if ([articleViewCtrl.view superview]) {
					[articleViewCtrl.view removeFromSuperview];
					[articleViewCtrl release];
					articleViewCtrl = nil;
					articleViewCtrl = [[ArticleViewCtrl alloc] initWithNibName:@"ArticleViewCtrl" bundle:[NSBundle	mainBundle]];
					articleViewCtrl.idnumber = Articleidnum;
					articleViewCtrl.adUrl = Articlead;
					articleViewCtrl.delegate = self;
					
					articleViewCtrl.view.frame = CGRectMake(0, 0, deviceHeight, 320);
					articleViewCtrl.myWebView.frame = CGRectMake(0.0f, 20.0f, deviceHeight, 252.0f);
					articleViewCtrl.CloseBtn.frame = CGRectMake(440.0f, 30.0f, 30.0f, 30.0f);
					articleViewCtrl.BookMarkBtn.frame = CGRectMake(400.0f, 30.0f, 30.0f, 30.0f);
					articleViewCtrl.MailBtn.frame = CGRectMake(360.0f, 30.0f, 30.0f, 30.0f);
					articleViewCtrl.MailBtn.hidden = NO;

					[appDelegate.tabBarController.view addSubview:articleViewCtrl.view];
					appDelegate.adview.frame = CGRectMake(0.0f, 432.0f, deviceHeight, 48.0f);
				}
				
				return YES;
			}else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight){

				receivedRotate = YES;
				PageNumberButtonFlg = YES;
				
				// 첫페이지에서 회전한 경우(초기 설정)
				if (poPageNumber <= 0) {
					poPageNumber = 1;
					pageNumber = 1;
				}
				// 첫페이지는 무조건 1로 설정
				if (poPageNumber == 1) {
					pageNumber = 1;
					poPageNumber = 1;
				}
				// 세로보기2,3페이지의 경우는 2페이지 설정
				else if(poPageNumber == 2 || poPageNumber == 3){
					pageNumber = 2;
				}
				// 세로보기가 맨마지막이었던 경우 가로보기도 마지막 페이지 설정
				else if( poPageNumber == [self.contentParser.portraitObjects count]){
					//					pageNumber = [self.contentParser.landscapeObjects count];
					pageNumber = (poPageNumber+2)/2;
				}
				else {
					pageNumber = (poPageNumber+2)/2;
				}
				[app setStatusBarHidden:YES];
				[appDelegate.tabBarController.view addSubview:scrollView2];
				
				CGRect frame = scrollView2.frame;
				frame.origin.x = frame.size.width * (pageNumber-1);
				frame.origin.y = 0;
				[scrollView2 scrollRectToVisible:frame animated:NO];
				
				laPageNumber = pageNumber;
				// 메모리에 이미지 로드해서 보여주기
				if ([imageFileNamesForScrollView2 count]  > pageNumber - 1) {
					NSDictionary *imageFileName = [imageFileNamesForScrollView2 objectAtIndex:pageNumber - 1];
					NSString *leftName = [imageFileName objectForKey:[NSString stringWithFormat:@"L%d",pageNumber]];
					NSString *rightName = [imageFileName objectForKey:[NSString stringWithFormat:@"R%d",pageNumber]];
					if (pageNumber == 1) {
						NSString *imageFileRightPath = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:rightName]];
						UIImageView *imageView = [imageViewsInScrollView2 objectAtIndex:pageNumber - 1];
						NSArray *subViews = [imageView subviews];
						
						NSInteger index = 0;
						for (UIImageView *aiv in subViews) {
							if (index == 1) {
								UIImage *image = [UIImage imageWithContentsOfFile:imageFileRightPath];
								[aiv setImage:image];
							}else {
								[aiv setImage:nil];
							}
							
							index++;
						}
					}
					else {
						
					    if ([leftName length] > 0 && [rightName length] > 0) {
							
							NSString *imageFileLeftPath = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:leftName]];
							NSString *imageFileRightPath = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:rightName]];
							UIImageView *imageView = [imageViewsInScrollView2 objectAtIndex:pageNumber - 1];
							NSArray *subViews = [imageView subviews];
							NSInteger index = 0;
							for (UIImageView *aiv in subViews) {
								if (index == 0) {
									UIImage *imageL = [UIImage imageWithContentsOfFile:imageFileLeftPath];
									[aiv setImage:imageL];
								}else {
									UIImage *imageR = [UIImage imageWithContentsOfFile:imageFileRightPath];						
									[aiv setImage:imageR];
								}
								index++;
							}
						}
						
					}
				}
				[self landscapeButtonSetting];
				
				if ([articleViewCtrl.view superview]) {
					[articleViewCtrl.view removeFromSuperview];
					[articleViewCtrl release];
					articleViewCtrl = nil;

					articleViewCtrl = [[ArticleViewCtrl alloc] initWithNibName:@"ArticleViewCtrl" bundle:[NSBundle	mainBundle]];
					articleViewCtrl.idnumber = Articleidnum;
					articleViewCtrl.adUrl = Articlead;
					articleViewCtrl.delegate = self;
					
					articleViewCtrl.view.frame = CGRectMake(0, 0, 320, deviceHeight);
					articleViewCtrl.myWebView.frame = CGRectMake(0.0f, 0.0f, 320.0f, deviceHeight-48);
					articleViewCtrl.CloseBtn.frame = CGRectMake(275.0f, 25.0f, 30.0f, 30.0f);
					articleViewCtrl.BookMarkBtn.frame = CGRectMake(235.0f, 25.0f, 30.0f, 30.0f);
					articleViewCtrl.MailBtn.frame = CGRectMake(195.0f, 25.0f, 30.0f, 30.0f);
					articleViewCtrl.MailBtn.hidden = YES;
					
					[appDelegate.tabBarController.view addSubview:articleViewCtrl.view];
					appDelegate.adview.frame = CGRectMake(0.0f, 272.0f, 320, 48.0f);
				}
				
				
				return YES;
			}
			else {
				return NO; 		
			}
		}
	}
	return NO; 
	
}

#pragma mark -
#pragma mark PageButtonSetting


// 가로보기 버튼 페이지 번호 표시
- (void)landscapeButtonSetting{
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	if ([PageNumber_Btn superview])  {
		[PageNumber_Btn removeFromSuperview];
		
		PageNumber_Btn.frame = CGRectMake(215.0f, 270.0f, 70.0f, 30.0f);
		if (pageNumber == landscape_TotalNumber) {
			PageNumberString = @"처음으로";
			PageNumber_Btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
		}
		else {
			PageNumberString = [NSString stringWithFormat:@"%d/%d", pageNumber,landscape_TotalNumber];
			PageNumber_Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
		}
		
		[PageNumber_Btn setTitle:PageNumberString forState:UIControlStateNormal];
		[appDelegate.tabBarController.view addSubview:PageNumber_Btn];
	}
}

// 세로보기 버튼 페이지 번호 표시
- (void)PortraitButtonSetting{
	
	if ([PageNumber_Btn superview])  {
		[PageNumber_Btn removeFromSuperview];
		PageNumber_Btn.frame = CGRectMake(135.0f, deviceHeight-100, 70.0f, 30.0f);
		
		if (pageNumber == Portrait_TotalNumber) {
			PageNumberString = @"처음으로";
			PageNumber_Btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
		}
		else {
			PageNumberString = [NSString stringWithFormat:@"%d/%d", pageNumber,Portrait_TotalNumber];
			PageNumber_Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
		}		

		[PageNumber_Btn setTitle:PageNumberString forState:UIControlStateNormal];
		[self.view addSubview:PageNumber_Btn];
	}
	
}


// 페이지 버튼을 클릭 했을 경우에 대한 처리
- (void)PageNumberbuttonPressed{
	
	if ([scrollView2 superview]) {
		if (pageNumber == landscape_TotalNumber) {
			pageNumber = 1;
			[self readImage:pageNumber scrollView:scrollView2];
			// 세로보기화면에서 해당 페이지 표시
			CGRect frame = scrollView2.frame;
			frame.origin.x = frame.size.width * (pageNumber-1);
			frame.origin.y = 0;
			[scrollView2 scrollRectToVisible:frame animated:NO];
		}
	}
	else {
		if (pageNumber == Portrait_TotalNumber) {
			pageNumber = 1;
			[self readImage:pageNumber scrollView:scrollView1];
			// 세로보기화면에서 해당 페이지 표시
			CGRect frame = scrollView1.frame;
			frame.origin.x = frame.size.width * (pageNumber-1);
			frame.origin.y = 0;
			[scrollView1 scrollRectToVisible:frame animated:NO];
		}
		
	}
	
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
	[LaitemArray release];
	[laData release];
	[me2day release];
//	[twitter release];
//	[kakaotalk release];
	[documentPath     release];
	[imageViewsInScrollView1 release];
	[imageViewsInScrollView2 release];
	[imageFileNamesForScrollView1 release];
	[imageFileNamesForScrollView2 release];
	[contentParser    release];
	[bookParser       release];
	[bookcontentArray release];
	[PageNumber_Btn   release];
	[articleViewCtrl  release];
	[settingView      release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ParsingEnded" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"dialogStatus" object:nil];
	[outputArray release];
    [super dealloc];
}




#pragma mark -
#pragma mark ScrollViewImageSetting

- (NSData *)downloadData:(NSURL *)url toFile:(NSString *)fileName{	
	NSString *fileNameWithPrefix = [PAGE_IMAGE_FILE_PREFIX stringByAppendingString:fileName]; // ex) ThirdViewController_01.jpg
	NSString *filePathInDevice = [documentPath stringByAppendingPathComponent:fileNameWithPrefix];
	
	NSData *receivedData;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:filePathInDevice]) {
		receivedData = [[NSData alloc] initWithContentsOfFile:filePathInDevice];
	}
	else {
		receivedData = [[NSData alloc] initWithContentsOfURL:url];
		[receivedData writeToFile:filePathInDevice atomically:YES];
	}
	
	return receivedData;
}


- (void)addImageView:(UIImageView *)imageView toScrollView:(UIScrollView *)scrollView atIndex:(NSInteger)index {
	
	CGRect frame;
	if (scrollView == scrollView1) {
		frame = CGRectMake(porWidth * index, 0, porWidth, deviceHeight-69);
		[imageViewsInScrollView1 addObject:imageView];
	} else {
		frame = CGRectMake(lanWidth * index, 0, deviceHeight, lanHeight);
		[imageViewsInScrollView2 addObject:imageView];
	}
	
	imageView.frame = frame;
	[scrollView addSubview:imageView];
}

- (void)replaceImageView:(id)arguments {
	
	
	NSDictionary *dict = (NSDictionary *)arguments;
	ThumbImageView *imageView = [dict objectForKey:@"imageView"];
	UIScrollView *scrollView = [dict objectForKey:@"scrollView"];
	NSInteger index = [[dict objectForKey:@"index"] integerValue];
	
	UIImageView *imageViewLeft = [[UIImageView alloc] init];
	UIImageView *imageViewRight = [[UIImageView alloc] init];
	imageViewLeft.frame = CGRectMake(0.0f, 0.0f, 240.0f, 320.0f);
	imageViewRight.frame = CGRectMake(240.0f, 0.0f, 240.0f, 320.0f);
	
	// 기존의 디폴트 이미지뷰를 가져와서, Frame정보를 가져와서, 새 ThumbImageView에 적용하고, 지워버린다.
	UIImageView *defaultImageView;
	if (scrollView == scrollView1) {
		defaultImageView = [imageViewsInScrollView1 objectAtIndex:index];
	} else {
		defaultImageView = [imageViewsInScrollView2 objectAtIndex:index];
	}
	
	CGRect frame = defaultImageView.frame;
	[defaultImageView removeFromSuperview];
	
	imageView.frame = frame;
	
	
	if (scrollView == scrollView1) {
	
		if (pageNumber == index + 1) {
			
			NSMutableArray *imageFileNamesForScrollView = imageFileNamesForScrollView1;
			NSString *imageFileName = [imageFileNamesForScrollView objectAtIndex:index];
			NSString *imageFilePath = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:imageFileName]];
			UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
			[imageView setImage:image];
		}
		
	} else { 
		if (pageNumber == index + 1) {
			
			NSMutableArray *imageFileNamesForScrollView = imageFileNamesForScrollView2;
			NSMutableDictionary *imageFileName = [imageFileNamesForScrollView objectAtIndex:index];
			
			if (index == 0) {
				NSString *imageFilePathR = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:[imageFileName objectForKey:[NSString stringWithFormat:@"R%d",index+1]]]];
				UIImage *imageRight = [UIImage imageWithContentsOfFile:imageFilePathR];
				[imageViewLeft setImage:nil];
				[imageViewRight setImage:imageRight];
				
				
			}else {
				NSString *imageFilePathL = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:[imageFileName objectForKey:[NSString stringWithFormat:@"L%d",index+1]]]];
				NSString *imageFilePathR = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:[imageFileName objectForKey:[NSString stringWithFormat:@"R%d",index+1]]]];			
				UIImage *imageLeft = [UIImage imageWithContentsOfFile:imageFilePathL];
				[imageViewLeft setImage:imageLeft];
				
				UIImage *imageRight = [UIImage imageWithContentsOfFile:imageFilePathR];
				[imageViewRight setImage:imageRight];
				
				
			}
		}
		[imageView addSubview:imageViewLeft];
		[imageView addSubview:imageViewRight];
	}
	

	
	[scrollView addSubview:imageView];
	
	
	if (scrollView == scrollView1) {
		[imageViewsInScrollView1 replaceObjectAtIndex:index withObject:imageView];
	} else { 
		[imageViewsInScrollView2 replaceObjectAtIndex:index withObject:imageView];
	}
	[imageViewLeft release];
	[imageViewRight release];
}


- (void)replaceImageViewla:(id)arguments {
	
	NSDictionary *dict = (NSDictionary *)arguments;
	ThumbImageView *imageView  = [dict objectForKey:@"imageView"];
	UIScrollView *scrollView = [dict objectForKey:@"scrollView"];
	NSInteger index = [[dict objectForKey:@"index"] integerValue];
	UIImageView *imageViewLeft = [[UIImageView alloc] init];
	UIImageView *imageViewRight = [[UIImageView alloc] init];
	imageViewLeft.frame = CGRectMake(0.0f, 0.0f, 240.0f, deviceHeight-160);
	imageViewRight.frame = CGRectMake(240.0f, 0.0f, 240.0f, deviceHeight-160);
	
	UIImageView *defaultImageView;
	
	defaultImageView = [imageViewsInScrollView2 objectAtIndex:index];
	CGRect frame = defaultImageView.frame;
	[defaultImageView removeFromSuperview];
	imageView.frame = frame;
	
	
	if (pageNumber == index + 1) {
		
		NSMutableArray *imageFileNamesForScrollView = imageFileNamesForScrollView2;
		NSMutableDictionary *imageFileName = [imageFileNamesForScrollView objectAtIndex:index];
		
		if (index == 0) {
			NSString *imageFilePathR = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:[imageFileName objectForKey:[NSString stringWithFormat:@"R%d",index+1]]]];
			UIImage *imageRight = [UIImage imageWithContentsOfFile:imageFilePathR];
			[imageViewLeft setImage:nil];
			[imageViewRight setImage:imageRight];
			
			
		}else {
			NSString *imageFilePathL = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:[imageFileName objectForKey:[NSString stringWithFormat:@"L%d",index+1]]]];
			NSString *imageFilePathR = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:[imageFileName objectForKey:[NSString stringWithFormat:@"R%d",index+1]]]];			
			UIImage *imageLeft = [UIImage imageWithContentsOfFile:imageFilePathL];
			[imageViewLeft setImage:imageLeft];
			
			UIImage *imageRight = [UIImage imageWithContentsOfFile:imageFilePathR];
			[imageViewRight setImage:imageRight];
			
			
		}
	}
	[imageView addSubview:imageViewLeft];
	[imageView addSubview:imageViewRight];
	
	[scrollView addSubview:imageView];
	
	[imageViewsInScrollView2 replaceObjectAtIndex:index withObject:imageView];
	
	[imageViewLeft release];
	[imageViewRight release];
}

// scrollView 안에 있는 imageView에 image를 보여주기
- (void)readImage:(NSInteger)currentPageNumber scrollView:(UIScrollView *)scrollView {
	
	
	NSInteger TotalNumber;
	NSMutableArray *imageViewsInScrollView;
	NSMutableArray *imageFileNamesForScrollView;
	
	if (scrollView == scrollView1) {
		imageViewsInScrollView = imageViewsInScrollView1;
		imageFileNamesForScrollView = imageFileNamesForScrollView1;
		TotalNumber = Portrait_TotalNumber;
		
		if (currentPageNumber - 2 - READ_TO_MEMORY_PLUS_MINUS > 0) {
			UIImageView *foreImageView = [imageViewsInScrollView objectAtIndex:currentPageNumber - 2 - READ_TO_MEMORY_PLUS_MINUS];
			if ([foreImageView isMemberOfClass:[ThumbImageView class]])
			{
				foreImageView.image = nil;
			}
		}
		
		if (currentPageNumber + READ_TO_MEMORY_PLUS_MINUS < TotalNumber) {
			UIImageView *backImageView = [imageViewsInScrollView objectAtIndex:currentPageNumber + READ_TO_MEMORY_PLUS_MINUS];
			if ([backImageView isMemberOfClass:[ThumbImageView class]]) 
			{
				backImageView.image = nil;
			}
		}
		
		for (int i  = currentPageNumber - READ_TO_MEMORY_PLUS_MINUS; i <= currentPageNumber + READ_TO_MEMORY_PLUS_MINUS; i++) {
			
			if (i < 1 || i > TotalNumber)  {
				continue;
			}
			
			UIImageView *imageView = [imageViewsInScrollView objectAtIndex:i - 1];
			
			if ([imageView isMemberOfClass:[ThumbImageView class]]) { // 그림파일이 다운로드가 이미 된 경우
				if (imageView.image != nil) {
					continue;
				}
				NSString *imageFileName = [imageFileNamesForScrollView objectAtIndex:i - 1];
				NSString *imageFilePath = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:imageFileName]];
				UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
				[imageView setImage:image];

			}
		}
		
	}
	else {
		imageViewsInScrollView = imageViewsInScrollView2;
		imageFileNamesForScrollView = imageFileNamesForScrollView2;
		TotalNumber = landscape_TotalNumber;
		
		
		if (currentPageNumber - 2 - READ_TO_MEMORY_PLUS_MINUS > 0) {
			UIImageView *foreImageView = [imageViewsInScrollView objectAtIndex:currentPageNumber - 2 - READ_TO_MEMORY_PLUS_MINUS];
			if ([foreImageView isMemberOfClass:[ThumbImageView class]])
			{
				NSArray *subViews = [foreImageView subviews];
				
				NSInteger index = 0;
				for (UIImageView *aiv in subViews) {
					aiv.image = nil;
					index++;
				}
				
			}
		}
		
		if (currentPageNumber + READ_TO_MEMORY_PLUS_MINUS < TotalNumber) {
			UIImageView *backImageView = [imageViewsInScrollView objectAtIndex:currentPageNumber + READ_TO_MEMORY_PLUS_MINUS];
			if ([backImageView isMemberOfClass:[ThumbImageView class]]) 
			{
				NSArray *subViews = [backImageView subviews];
				NSInteger index = 0;
				for (UIImageView *aiv in subViews) {
					aiv.image = nil;
					index++;
				}
			}
		}
		
		
		for (int i  = currentPageNumber - READ_TO_MEMORY_PLUS_MINUS; i <= currentPageNumber + READ_TO_MEMORY_PLUS_MINUS; i++) {
			
			if (i < 1 || i > TotalNumber)  {
				continue;
			}
			UIImageView *imageView = [imageViewsInScrollView objectAtIndex:i - 1];
			if ([imageView isMemberOfClass:[ThumbImageView class]]) { // 그림파일이 다운로드가 이미 된 경우
				NSDictionary *imageFileName = [imageFileNamesForScrollView objectAtIndex:i - 1];
				if (i == 1) {
					NSString *imageFilePathR = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:[imageFileName objectForKey:[NSString stringWithFormat:@"R%d",i]]]];				
					UIImage *image = [UIImage imageWithContentsOfFile:imageFilePathR];
					NSArray *subViews = [imageView subviews];
					NSInteger index = 0;
					for (UIImageView *aiv in subViews) {
						if (index == 1) {
							[aiv setImage:image];
						}else {
							[aiv setImage:nil];
						}
						index++;
					}
				}
				else {
					NSString *imageFilePathL = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:[imageFileName objectForKey:[NSString stringWithFormat:@"L%d",i]]]];
					NSString *imageFilePathR = [documentPath stringByAppendingPathComponent:[PAGE_IMAGE_FILE_PREFIX stringByAppendingString:[imageFileName objectForKey:[NSString stringWithFormat:@"R%d",i]]]];				
					UIImage *imageL = [UIImage imageWithContentsOfFile:imageFilePathL];
					UIImage *imageR = [UIImage imageWithContentsOfFile:imageFilePathR];
					NSArray *subViews = [imageView subviews];
					NSInteger index = 0;
					for (UIImageView *aiv in subViews) {
						if (index == 0) {
							[aiv setImage:imageL];
						}else {
							[aiv setImage:imageR];
						}
						index++;
					}
				}
			}
		}
	}
	
	
	
	/*
	 UIImage *image = [UIImage imageNamed:@"default_bg.png"];
	 for (int i = 0; i < [imageViewsInScrollView count]; i++) {
	 UIImageView *imageView = [imageViewsInScrollView objectAtIndex:i];
	 
	 NSString *imageLog;
	 if (imageView.image == image) {
	 imageLog = @"DEFAULT";
	 } else if (imageView.image == nil) {
	 imageLog = @"nil";
	 } else {
	 imageLog = @"Loaded";
	 }
	 
	 NSLog (@"%d -> %@ and %@", i, [imageView class], imageLog);
	 }
	 NSLog (@"\n\n\n");
	 */
}




#pragma mark -
#pragma mark Output
// 10/7
- (void)TwitterSendViewCtrl:(NSArray *)twittercontent atshortUrl:(NSString *)bitlyURL{
	
//	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
//	
//	appDelegate.mailviewFlg = @"YES";
//	
//	outputArray = nil;
//	bitlyurl = nil;
//	outputArray = [twittercontent objectAtIndex:0];
//	bitlyurl = bitlyURL;
//	[twitter release];
//	twitter = nil;
//	
//	if (twitter == nil) {
//		twitter = [[TwitterClass alloc] init];
//		[twitter setConsumerKey:kOAuthConsumerKey];
//		[twitter setConsumerSecret:kOAuthConsumerSecret];
//		twitter.delegate = self;
//		[twitter initWithViewCtrl];
//	}
//	[twitter setTitle:outputArray.title];
//	[twitter setUrl:bitlyURL];
//	[twitter start];
//	
//	appDelegate.mailviewFlg = @"YES";
}

- (void)showTwitterViewCtrl:(UIViewController *)controller {
//	[self presentModalViewController:controller animated:YES];
}

- (void)twitterLoginIsCanceled{

//	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
//	
//	appDelegate.mailviewFlg = @"NO";
	

}
- (void)twitterSendMsgIsCanceled{
//	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
//	
//	appDelegate.mailviewFlg = @"NO";
}

- (void)twitterSendMsgIsSuccessed{

//	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
//	
//	appDelegate.mailviewFlg = @"NO";
//	
//	[self messageAlertView:NSLocalizedString(@"메세지 전송 완료", @"메세지 전송 완료")];
	
}
- (void)twitterSendMsgIsFaild{
//	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
//	
//	appDelegate.mailviewFlg = @"NO";
//	
//	[self messageAlertView:NSLocalizedString(@"메세지 전송 실패", @"메세지 전송 실패")];
}

- (void)FaceBookSendViewCtrl:(NSArray *)facebookcontent atshortUrl:(NSString *)bitlyURL{

	SisainliveAppDelegate *sisaappDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	outputArray = nil;
	outputArray = [facebookcontent objectAtIndex:0];
	bitlyurl = bitlyURL;
	
	sisaappDelegate.facebook.titleExplain = @"지금 무슨 생각하고 계신가요?";
	sisaappDelegate.facebook.description = @"www.sisainlive.com";
	[sisaappDelegate.facebook sendMsg:outputArray.title atTo:outputArray.image atTo:bitlyURL];				

}

// 1 :Show
// 2 :Close
- (void)dialogShowstatus:(NSNotification *)notification{

	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];	
	NSString *status = (NSString *)[notification object];
	if ([status isEqualToString:@"1"]) {
		appDelegate.mailviewFlg = @"YES";
	}else {
		appDelegate.mailviewFlg = @"NO";
	}
}


- (void)me2daySendViewCtrl:(NSArray *)me2daycontent atshortUrl:(NSString *)bitlyURL{

	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.mailviewFlg = @"YES";
	outputArray = nil;
	outputArray = [me2daycontent objectAtIndex:0];
	bitlyurl = bitlyURL;

	if (me2day == nil) {
		me2day = [[me2dayClass alloc] init];
		[me2day setApikey:me2dayAPIKey];
		[me2day setMd5key:nonce];
		me2day.delegate = self;
	}
	[me2day setTitle:outputArray.title];
	[me2day setLinkTitle:outputArray.title atLink:bitlyURL];
	[me2day setTag:@"시사INLive"];
	
	[me2day sendMessage];
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

- (void)me2dayLoginCancled{
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.mailviewFlg = @"NO";

}

- (void)me2daySendMsgIsSuccessed{

	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.mailviewFlg = @"NO";
	
	[self messageAlertView:NSLocalizedString(@"메세지 전송 완료", @"메세지 전송 완료")];
	
}
- (void)me2daySendMsgIsFaild{

	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.mailviewFlg = @"NO";
	
	[self messageAlertView:NSLocalizedString(@"메세지 전송 실패", @"메세지 전송 실패")];
}


- (void)me2daySendMsgIsCancled{
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.mailviewFlg = @"NO";
}


//- (void)kakaotalkSendViewCtrl:(NSArray *)kakaotalkcontent atshortUrl:(NSString *)bitlyURL{
//
//
//	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
//	
//	appDelegate.mailviewFlg = @"YES";
//	outputArray = nil;
//	outputArray = [kakaotalkcontent objectAtIndex:0];
//	bitlyurl = bitlyURL;
//	
//	if (kakaotalk == nil) {
//		kakaotalk = [[kakaotalkClass alloc] init];
//		kakaotalk.delegate = self;
//	}
//	[kakaotalk setMsg:outputArray.title];
//	[kakaotalk setUrl:bitlyurl];
//	
//	[kakaotalk sendMessage];
//}

//- (void)kakaotalkSendMessageEnd{
//	
//	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
//	
//	appDelegate.mailviewFlg = @"NO";
//}

#pragma mark - 
#pragma mark setupSpinView

- (void)setupSpinView:(BOOL)flag message:(NSString *)message {

	if (flag) {
		UIView *spinView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, deviceHeight - 20)];
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

		//로딩 불필요
//		[self.view addSubview:spinView];
		[spinView release];
	}
	else {
		UIView *spinView = [self.view viewWithTag:SPINVIEW_TAG];
		[spinView removeFromSuperview];
		spinView = nil;
	}
}
#pragma mark -
#pragma mark Compose Mail

- (void)MailSendViewCtrl:(NSArray *)mailcontent{
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	appDelegate.mailviewFlg = @"YES";
	Article *mailcontentarray = [mailcontent objectAtIndex:0];
	MailCompose *picker = [[MailCompose alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:mailcontentarray.title];
	[picker setMessageBody:[NSString stringWithFormat:@"%@\n%@",mailcontentarray.content,mailcontentarray.permalink] isHTML:YES];
	[appDelegate.tabBarController presentModalViewController:picker animated:YES];
	[picker release];
	
}

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
	
	[self dismissModalViewControllerAnimated:YES];
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.mailviewFlg = @"NO";
	
	[self MailSendViewControll];
}


- (void)MailSendViewControll{
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	if ([articleViewCtrl.view superview]) {
		[articleViewCtrl.view removeFromSuperview];
	}

	articleViewCtrl = [[ArticleViewCtrl alloc] initWithNibName:@"ArticleViewCtrl" bundle:[NSBundle	mainBundle]];
	articleViewCtrl.idnumber = Articleidnum;
	articleViewCtrl.adUrl = Articlead;
	articleViewCtrl.delegate = self;
	
	articleViewCtrl.view.bounds = CGRectMake(0, 0, 320, deviceHeight);
	articleViewCtrl.myWebView.frame = CGRectMake(15.0f, 40.0f, 290, deviceHeight - 60);
	articleViewCtrl.backgroundView.frame = CGRectMake(10.0f, 35.0f, 300, deviceHeight - 50);
	articleViewCtrl.backgroundView.image = PoScreenImage;
	articleViewCtrl.CloseBtn.frame = CGRectMake(280.0f, 30.0f, 30.0f, 30.0f);
	//articleViewCtrl.MailBtn.hidden = NO;
	[appDelegate.tabBarController.view addSubview:articleViewCtrl.view];
	
}


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


#pragma mark reDownload

// 면별보기 파일 재다운로드에 대한 설정
- (void)reDownload{
	ReDownload = @"YES";
}

#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	if (buttonIndex == 0) {

		// 디바이스안의 이미지 파일 저장소 패스 설정
		NSString *bookNumberPath = [documentPath stringByAppendingPathComponent:LATEST_BOOKNUM_PATH];
		
		BookNumber_Conf = @"000";
		// 취득한 책호수의 번호를 디바이스에 저장한다.
		[BookNumber_Conf writeToFile:bookNumberPath atomically:YES encoding:NSASCIIStringEncoding error:nil];	
		
		self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
		
		for (NSString *fileName	in contentsOfDirectory) {
			int count = [fileName length];
			if (count > 20) {
				if ([[fileName substringToIndex:20] isEqualToString:PAGE_IMAGE_FILE_PREFIX]) {
					[fileManager removeItemAtPath:[documentPath stringByAppendingPathComponent:fileName] error:nil];
				}
			}
		}
		appDelegate.OrientationFlg = @"NO";
	}
	else if (buttonIndex == 1) {
		
		switch (alertView.tag) {
			case screenredown:
			{
				[contentParser start:BookNumber_Conf];
			
			}
			break;
			
			case newbookdown:
			{
				
				NSFileManager *fileManager = [NSFileManager defaultManager];
				NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
				
				for (NSString *fileName	in contentsOfDirectory) {
					int count = [fileName length];
					if (count > 20) {
						if ([[fileName substringToIndex:20] isEqualToString:PAGE_IMAGE_FILE_PREFIX]) {
							[fileManager removeItemAtPath:[documentPath stringByAppendingPathComponent:fileName] error:nil];
						}
					}
				}

				/* 20100915 수정_Start
				 내용:
				 면별보기시 호수를 바꿨을 경우 이미지 파일이 표시가 안되는 문제가 발생(파일명이 기존의 패턴과 다르게 생성되었을 경우)
				 면별보기시에 호수를 바꿨을 시 해당되는 페이지에 대한 변수를 NULL로 변경 후에 작업을 하도록 설정
				*/
       			imageViewsInScrollView1 = [[NSMutableArray alloc] init];
				imageViewsInScrollView2 = [[NSMutableArray alloc] init];
				imageFileNamesForScrollView1 = [[NSMutableArray alloc] init];
				imageFileNamesForScrollView2 = [[NSMutableArray alloc] init];
				 
				pageNumber = 1;
				/* 20100915 수정_End*/
				
				// 새로 다운로드 시작한다.
				[contentParser start:BookNumber_Conf];
			}
				break;

			default:
				break;
		}
		appDelegate.OrientationFlg = @"YES";
	}
}

@end
