//
//  ArticleListViewCtrl.h
//  Sisainlive
//
//  Created by snow leopard on 10. 8. 24..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"BaseViewCtrl.h"
#import "ArticleListContent.h"
#import "ArticleListParser.h"
// 2010.8.3 Lee Sungman
#import "ArticlePictureViewController.h"


@interface ArticleListViewCtrl : BaseViewCtrl<UIScrollViewDelegate,ArticlePictureViewControllerDelegate,ArticleListParserDelegate,UITableViewDataSource, UITableViewDelegate> {
	UITableView	       *myTableView;
	NSMutableString	   *contentIndex;
	NSMutableArray	   *contentArray;
   	ArticleListParser  *ListContentParser;
	
	NSMutableArray		*contentArraySub;
	
	NSMutableString	   *MaincontentIndex;
	NSMutableArray	   *MaincontentArray;
	ArticleListParser  *MainListContentParser;
	
	UIScrollView	   *CategoryScrollView;
	

	NSInteger networkStatus;
	
	NSInteger pageNumber;
	
	NSInteger totalNumber;
	
	NSString *Section_Code;
	
	BOOL	SelectedCell;
	
	BOOL	FirstPictureView;
	BOOL	FirstListView;
	BOOL	reloadTableView;
	
	BOOL	parserError;
	
	// 2010.8.3 Lee Sungman
	ArticlePictureViewController *apvc;
	BOOL	transitioning;
	
	
	UIButton	    *Button1;
	UIButton	    *Button2;
	UIButton	    *Button3;
	UIButton	    *Button4;
	UIButton	    *Button5;
	UIButton	    *Button6;
	UIButton	    *Button7;
	UIButton	    *Button8;
	UIButton	    *Button9;
	UIImageView		*LeftImage;
	UIImageView		*RightImage;
	UIImage			*categorybtnimage;
	
	UIImage *List;
	UIImage *Picture;
	
	NSInteger		cellAdViewIndex;
	
	BOOL			moreFlg;
	
}
@property (nonatomic, retain) IBOutlet UIScrollView	  *CategoryScrollView;
@property (nonatomic, assign) BOOL reloadTableView;
@property (nonatomic, retain) NSMutableArray          *contentArray;
@property (nonatomic, retain) ArticleListParser       *ListContentParser;
@property (nonatomic, retain) NSMutableArray          *MaincontentArray;
@property (nonatomic, retain) ArticleListParser   *MainListContentParser;
@property (nonatomic, retain) IBOutlet UIButton	      *Button1;
@property (nonatomic, retain) IBOutlet UIButton	      *Button2;
@property (nonatomic, retain) IBOutlet UIButton	      *Button3;
@property (nonatomic, retain) IBOutlet UIButton	      *Button4;
@property (nonatomic, retain) IBOutlet UIButton	      *Button5;
@property (nonatomic, retain) IBOutlet UIButton	      *Button6;
@property (nonatomic, retain) IBOutlet UIButton	      *Button7;
@property (nonatomic, retain) IBOutlet UIButton	      *Button8;
@property (nonatomic, retain) IBOutlet UIButton	      *Button9;
@property (nonatomic, retain) IBOutlet UIImageView	  *LeftImage;
@property (nonatomic, retain) IBOutlet UIImageView	  *RightImage;
@property (nonatomic, retain) IBOutlet UIImage		  *categorybtnimage;

// 기사리스트 데이터 취득

- (void)MainListArticle;
- (void)getListArticle;
- (void)setupTableView:(BOOL)getData;
- (void)insertContent;

// 2010.8.3 Lee Sungman
- (void)setupArticlePictureViewController;
- (void)setupArticlePictureViewControllerContent;
- (void)setupBarButtonItem:(NSInteger)flag;



// 전체
- (IBAction)TotalArticleList;
// 커버/특집
- (IBAction)SpecialArticleList;
// 정치/경제
- (IBAction)EconomyArticleList;
// 사회/문화
- (IBAction)CommunityArticleList;
// 국제/한번도
- (IBAction)InternationalArticleList;
// 인터뷰/오피니언
- (IBAction)InterviewArticleList;
// 실용/과학
- (IBAction)ScienceArticleList;
// 사진/만화
- (IBAction)PictureArticleList;
// 책꽃이
- (IBAction)BookArticleList;

- (void)ButtonAction;

@end
