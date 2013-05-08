//
//  Constants.h
//  sisain
//
//  Created by snow leopard on 10. 7. 13..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#define app_version	@"1.8.0"
// network status
#define network_disable	        0
#define network_wifi	        1
#define network_3g		        2

// 스크롤 
#define HorizontalLength        10
#define kMaximumVariance        20

// Page
#define PageStart               1

#define INDICATOR_VIEW	999

#define navigationBar_tag	-10

#define documents_folder	[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#define	ADFLG			@"adflg"
#define	CONTENTDIC		@"contnetdic"


//광고 관련
#define	ADAPPID			@"IX00000B3"
#define ADAPPNAME		@"시사인 iOS"

// 화면사이즈
// 세로보기
#define porHeight				411
#define porWidth				320
#define portraitkey				@"portrait"
// 가로보기
#define lanHeight				320
#define lanWidth				480
#define landscapekey			@"landscape"


#define degreesToRadian(x) (M_PI * (x) / 180.0)

// 면별보기XML파일 URL
#define booknumber_url			@"http://app.sisainlive.com/xml/booknumber.xml"

// 면별보기XML파일 URL
#define sisainxml_url			@"http://app.sisainlive.com/xml/sisain%@"

// 기사리스트파일 URL
#define ArticleMain_url			@"http://www.sisainlive.com/news/articleListXml.html?sc_level=M"
#define ArticleList_url			@"http://www.sisainlive.com/news/articleListXml.html?page=%d"
#define ArticleList_code_url	@"http://www.sisainlive.com/news/articleListXml.html?page=%d&sc_section_code=%@"

// 기사보기파일 URL
#define entry_url				@"http://www.sisainlive.com/news/articleViewXml.html?idxno=%@"

// iPhone4의 이미지 URL
#define iPhone4_imgurl			@"http://app.sisainlive.com/"


// 기사리스트 Cell크기 설정
#define adlist_row			160.0f
#define bloglist_row		70.0f
#define postlist_row		66.0f

#define defaults_thumbnailImage	@"thumbnailImage"
#define switch_on			1
#define switch_off			-1


// base view
#define info_barButton		1
#define refresh_barButton	2
#define close_barButton		3
#define back_barButton		4
#define blue_barButton		5



// Image설정
#define setting					[[NSBundle mainBundle] pathForResource:@"setting"	ofType:@"png"]
#define ArtileList				[[NSBundle mainBundle] pathForResource:@"ArticleList"	ofType:@"jpg"]
#define ArtilePicture			[[NSBundle mainBundle] pathForResource:@"ArtilePicture"	ofType:@"jpg"]
#define twitter_logo			[[NSBundle mainBundle] pathForResource:@"twitter" ofType:@"png"]
#define me2day_logo				[[NSBundle mainBundle] pathForResource:@"me2day" ofType:@"png"]
#define default_cellbg			[[NSBundle mainBundle] pathForResource:@"default_bg" ofType:@"jpg"]
#define facebook_logo			[[NSBundle mainBundle] pathForResource:@"facebook" ofType:@"png"]
#define group_background		[[NSBundle mainBundle] pathForResource:@"groupTableViewBackground" ofType:@"png"]

#define defaults_articleImage	@"articleImage"
#define default_cellbg		    [[NSBundle mainBundle] pathForResource:@"default_bg" ofType:@"jpg"]
#define ArticleList3G           [UIImage imageNamed:@"ArticleList.png"]
#define ArticlePicture3G        [UIImage imageNamed:@"ArticlePicture.png"]
#define setting3G				[UIImage imageNamed:@"setting.png"]
#define LeftButton3G			[UIImage imageNamed:@"LeftButton.png"]
#define RightButton3G			[UIImage imageNamed:@"RightButton.png"]
#define LeftButtonPicture3G		[UIImage imageNamed:@"LeftButtonPicture.png"]
#define RightButtonPicture3G	[UIImage imageNamed:@"RightButtonPicture.png"]
#define DefaultImg3G            [[NSBundle mainBundle] pathForResource:@"DefaultImg" ofType:@"png"]
#define DefaultImgCell3G		[UIImage imageNamed:@"DefaultImg.png"]
#define TitleView3G				[UIImage imageNamed:@"TitleView.png"]
#define BookMarkBtn3G			[UIImage imageNamed:@"BookMarkBtn.png"]
#define CloseBtn3G				[UIImage imageNamed:@"CloseBtn.png"]
#define MailSendBtn3G			[UIImage imageNamed:@"MailSendBtn.png"]
#define PoScreenImage			[UIImage imageNamed:@"PoScreen.png"]
#define LaScreenImage			[UIImage imageNamed:@"LaScreen.png"]
#define categoryButton			[UIImage imageNamed:@"categoryButton.png"]
#define DefaultL				[UIImage imageNamed:@"DefaultL.png"]
#define DefaultP				[UIImage imageNamed:@"DefaultP.png"]
#define leftbtn					[UIImage imageNamed:@"LeftButton.png"]
#define cateLBtn				[UIImage imageNamed:@"categoryLBtn.png"]
#define cateRBtn				[UIImage imageNamed:@"categoryRBtn.png"]


// me2DAY관련
#define me2dayAPIKey			@"c9caae336104766472c55f55fe09cf1e"
#define nonce					@"12345678"
#define me2dayloginurl			@"http://me2day.net/api/noop?uid=%@&ukey=%@%@&akey=%@"
#define me2daytextinput			@"http://me2day.net/api/create_post/%@.xml?uid=%@&ukey=%@%@&akey=%@&post[body]=%@&post[tags]=%@"
#define me2day_url				@"http://m.me2day.net/posts/new?new_post[body]=%@"
#define sisaintags				@"시사INLive"
#define userkeycontent			@"미투데이 환경설정 > 외부연동 > api사용자키"


// Twitter 설정
#define SPINVIEW_TAG	100
#define kOAuthConsumerKey		@"DFFlo64PC8D2qaokgrH2cA"		//REPLACE ME
#define kOAuthConsumerSecret	@"LVgf7RWW4GfNAG5W6vBwc8gOdWAFOGS3UVXrglRo8"		//REPLACE ME
#define TwitterSignout			@"Disconnected"	
#define TwitterSignin			@"Connected"



// bookmark keys
#define book_idnum			@"idnum"
#define book_title			@"title"
#define book_content		@"content"
#define book_permalink		@"permalink"
#define book_description	@"description"
#define book_image			@"image"



#define defaults_bookmarkIndex	@"bookmarkIndex"
#define defaults_bookmarkList	@"bookmarkList"

//카카오톡 연동

#define APPID				@"com.CHAMEONRON.Sisainlive"
#define APPVERSION			@"1.0"

//#define KAKAOLINK			@"ConnectLauncher";
#define KAKAOLINK			@"kakaolink";
#define SENDURL				@"sendurl";











