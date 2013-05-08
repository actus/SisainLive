//
//  ArticleListViewCtrl.m
//  Sisainlive
//
//  Created by snow leopard on 10. 8. 24..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArticleListViewCtrl.h"
#import "SisainliveAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "MoreCell.h"
#import "ArticleListCustomCell.h"
#import "ArticleMainCustomCell.h"
#import "ArticleDetailViewController.h"
#import "SettingViewController.h"
#import "BookScreenViewCtrl.h"



#define FIRSTAD			2
#define SECONDAD		7

@implementation ArticleListViewCtrl
@synthesize contentArray;
@synthesize MaincontentArray;
@synthesize ListContentParser;
@synthesize MainListContentParser;
@synthesize reloadTableView;
@synthesize CategoryScrollView;
@synthesize Button1;
@synthesize Button2;
@synthesize Button3;
@synthesize Button4;
@synthesize Button5;
@synthesize Button6;
@synthesize Button7;
@synthesize Button8;
@synthesize Button9;
@synthesize LeftImage;
@synthesize RightImage;
@synthesize categorybtnimage;

#pragma mark -
#pragma mark viewDidLoad

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	moreFlg = NO;
	
	cellAdViewIndex = 1;
	[self setupArticlePictureViewController];
	
	categorybtnimage = [[UIImage alloc] init];
	categorybtnimage = categoryButton;

	LeftImage = [[UIImageView alloc] initWithImage:cateLBtn];
	RightImage = [[UIImageView alloc] initWithImage:cateRBtn];
				 
	LeftImage.frame = CGRectMake(0, 3, 30, 30); 
	RightImage.frame = CGRectMake(290, 3, 30, 30); 

	FirstPictureView = YES;
	FirstListView = YES;
	CategoryScrollView.backgroundColor = [UIColor blackColor];
	CategoryScrollView.contentSize = CGSizeMake(800.0f, 30.0f);
	CategoryScrollView.showsHorizontalScrollIndicator = NO;
	CategoryScrollView.delegate = self;
	
	[Button1 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];
	[Button2 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button3 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button4 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button5 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button6 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button7 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button8 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button9 setBackgroundImage:nil forState:UIControlStateNormal];	
	
	// 네트워크 상태 확인
	networkStatus = [self checkNetworkStatus];
	
	reloadTableView = NO;
	SelectedCell = YES;

	// 타이틀 설정
	self.navigationItem.title =@"시사IN";
	// 2010.8.3 Lee Sungman
	[self setupBarButtonItem:2];
	
	
	// XML파서 플래그 설정
	parserError = NO;
	
	// 화면상에 보여지는 테이블 셋팅
	[self setupTableView:YES];
	
	Section_Code = nil;
	// settingimage
	UIImage *img = [[UIImage alloc] init];
	
	
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Titleimage.png"]];
	
	img = setting3G;
	UINavigationBar *bar = [self.navigationController navigationBar]; 
	[bar setTintColor:[UIColor colorWithRed:.059 green:0.153 blue:0.376 alpha:1]]; 
	UIBarButtonItem *barButtonItem = nil;
	
	barButtonItem = [[UIBarButtonItem alloc] initWithImage:img
													 style:UIBarButtonItemStyleBordered
													target:self
													action:@selector(settingAction)];
	
	self.navigationItem.leftBarButtonItem = barButtonItem;
	[barButtonItem release];
}

#pragma mark -
#pragma mark setupTableView
/**
 기사파일 리스트 세팅
*/
- (void)setupTableView:(BOOL)getData {
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	if (FirstPictureView) {
		
		networkStatus = [self checkNetworkStatus];
		if (getData) {
			if (networkStatus != network_disable) {
				[self MainListArticle];
				[self getListArticle];
			}
			else {
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
				//[self showNetworkError];
			}
		}
		else {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
	}
	else {
		if (FirstListView) {
			
			FirstListView = NO;
			
            [self resetMyTalbleView];
			/*
			if (myTableView) {
				[myTableView removeFromSuperview];
				[myTableView release];
				myTableView = nil;
			}
			myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 38.0f, 320.0f, 330.0f) style:UITableViewStylePlain];
			myTableView.dataSource = self;
			myTableView.delegate = self;
			[self.view addSubview:myTableView];
			*/
			networkStatus = [self checkNetworkStatus];
			if (getData) {
				if (networkStatus != network_disable) {
					[self getListArticle];
				}
				else {
					[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
					//[self showNetworkError];
				}
			}
			else {
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			}
		}
	}	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark ArticleListViewCtrl_Start
/**
 기동시 기사파일리스트 테이블 생성
 */
- (void)viewWillAppear:(BOOL)animated {
		
	if ([apvc.view superview]) {
		
		[apvc reSetupadView];
	}else {
		if ([contentArraySub count] > 0) {
			if (!myTableView.dragging && !myTableView.tracking && !myTableView.decelerating) {
				[myTableView reloadData];
			}
		}
	}
	
	networkStatus = [self checkNetworkStatus];
	if (networkStatus != network_disable) {
		
		[self NOshowNetworkError];
		
		if (reloadTableView) {
			[self setupTableView:NO];
			reloadTableView = NO;
		}
		if (parserError) {
			parserError = NO;
			[self setupTableView:YES];
		}
		else {
			if (SelectedCell) {
				if (animated) {
					NSArray *rows = [myTableView indexPathsForVisibleRows];
					
					if ([rows count] > 0) {
						NSIndexPath *start	= [rows objectAtIndex:0];
						NSIndexPath *end	= [rows lastObject];
						
						NSInteger index = [contentIndex integerValue];
						
						if (index == -1) {
						}
						else {
							if (start.row > index) {
								NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
								[myTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
							}
							else if (end.row < index) {
								NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
								[myTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
							}
							else {
								NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
								[myTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewRowAnimationNone];
							}
							[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:YES];
						}
					}
				}
			}
			else {
				[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:NO];
			}
		}
	}
	else {
		[self showNetworkError];
	}
	
	
}

#pragma mark ArticleListViewCtrl_End

- (void)viewWillDisappear:(BOOL)animated {
	
//	[apvc timerStop];
	
	if (ListContentParser) {
		[ListContentParser stop];
		self.ListContentParser = nil;
	}
	SelectedCell = NO;
}

#pragma mark -
#pragma mark MainArticleListXMLParser
/**
 메인기사리스트 취득
*/
- (void)MainListArticle {
	
	MaincontentIndex = [[NSMutableString alloc] initWithFormat:@"%d", 0];
	MaincontentArray = [[NSMutableArray alloc] initWithCapacity:0];
	self.MainListContentParser = [[[ArticleListParser alloc] init] autorelease];
	MainListContentParser.sectionFlg = YES;
	MainListContentParser.delegate = self;
	[MainListContentParser start:[NSString stringWithFormat:ArticleMain_url]];
}

/**
 XML에서 취득한 데이터 화면상에 표시
 */
- (void)Mainparser:(id)parser didParseContents:(NSArray *)parsedContents{
	[MaincontentArray addObjectsFromArray:parsedContents];
}


- (void)MainparserDidEndParsingData:(id)parser {
	self.ListContentParser = nil;
}


#pragma mark -
#pragma mark ArticleListXMLParser
/**
 기사리스트 취득
*/
- (void)getListArticle {
	
	pageNumber = 1;
	contentIndex = [[NSMutableString alloc] initWithFormat:@"%d", 0];
	contentArray = [[NSMutableArray alloc] initWithCapacity:0];
	self.ListContentParser = [[[ArticleListParser alloc] init] autorelease];
	ListContentParser.sectionFlg = NO;
	ListContentParser.delegate = self;
	if(Section_Code == nil){
		[ListContentParser start:[NSString stringWithFormat:ArticleList_url,pageNumber]];
	}else {
		[ListContentParser start:[NSString stringWithFormat:ArticleList_code_url,pageNumber,Section_Code]];
	}
}

/**
 리스트 더보기 클릭시 리스트 추가
 */
- (void)insertContent {
	
	moreFlg = YES;
	
	pageNumber++;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.ListContentParser = [[[ArticleListParser alloc] init] autorelease];
	ListContentParser.delegate = self;
	if(Section_Code == nil){
		[ListContentParser start:[NSString stringWithFormat:ArticleList_url,pageNumber]];
	}else {
		[ListContentParser start:[NSString stringWithFormat:ArticleList_code_url,pageNumber,Section_Code]];
	}
}

- (void)resetMyTalbleView {
    if (myTableView) {
        [myTableView removeFromSuperview];
        [myTableView release];
        myTableView = nil;
    }
    
    if (deviceHeight == IPHONE_FIVE)
    {
        myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 38.0f, 320.0f, 418.0f) style:UITableViewStylePlain];
    }
    else
    {
        myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 38.0f, 320.0f, 330.0f) style:UITableViewStylePlain];
    }
    
    myTableView.dataSource = self;
    myTableView.delegate = self;
    [self.view addSubview:myTableView];
    
}

/**
 XML에서 취득한 데이터 테이블에 표시
 */
- (void)parser:(id)parser didParseContents:(NSArray *)parsedContents{
    [contentArray addObjectsFromArray:parsedContents];
	
	NSInteger index = 0;
	NSInteger count = 0;

	for (int i = 0; i < [contentArray count];i++) {
		// Configure the cell...
		if (i%10) {
			if (i == ((index*10)+2)) {
				count++;
			}else if (i == ((index*10)+7)) {
				count++;
			}
		}
		else {
			if (i != 0) {
				index++;
			}
		}
	}
	NSInteger TotalCount = [contentArray count]+count;
	count = 0;
	index = 0;
	
	if (contentArraySub !=nil) {
		[contentArraySub release];
		contentArraySub = nil;
	}
	
	contentArraySub = [[NSMutableArray alloc] init];
	
	for (int j = 0; j <= TotalCount; j++) {
		NSMutableDictionary *contentMudic = [NSMutableDictionary dictionaryWithCapacity:0];
		
		if (j%10) {
			if (j == ((index*10)+FIRSTAD)) {
				[contentMudic setObject:@"YES" forKey:ADFLG];
			}else if (j == ((index*10)+SECONDAD)) {
				[contentMudic setObject:@"YES" forKey:ADFLG];
			}else {
				count++;
				ArticleListContent *content = [contentArray objectAtIndex:count];
				[contentMudic setObject:@"NO" forKey:ADFLG];
				[contentMudic setObject:content forKey:CONTENTDIC];
			}
		}else {
			if (j != 0) {
				index++;
				count++;
				ArticleListContent *content = [contentArray objectAtIndex:count];
				[contentMudic setObject:@"NO" forKey:ADFLG];
				[contentMudic setObject:content forKey:CONTENTDIC];
			}else {
				ArticleListContent *content = [contentArray objectAtIndex:count];
				[contentMudic setObject:@"NO" forKey:ADFLG];
				[contentMudic setObject:content forKey:CONTENTDIC];
			}
		}
		
		[contentArraySub insertObject:contentMudic atIndex:j];

	}
	
	if (moreFlg) {
		if (!myTableView.dragging && !myTableView.tracking && !myTableView.decelerating) {
			[myTableView reloadData];
		}	
	}else {
		[self resetMyTalbleView];
		
	}

}
/**
 기사리스트 취득완료하면 화면상에 표시
 */
- (void)parserDidEndParsingData:(id)parser {
	
	totalNumber = [contentArray count];
	if (FirstPictureView) {
		FirstPictureView = NO;
		// 화면 전환
		[self setupArticlePictureViewController];
		[self setupArticlePictureViewControllerContent];
		[myTableView removeFromSuperview];
		[self.view addSubview:apvc.view];
		
		[apvc setupScrollViewContentSize];
		
		[self setupBarButtonItem:2];
		
		
		CATransition *transition = [CATransition animation];
		transition.duration = 0.5;
		transition.type = kCATransitionFade;
		
		transitioning = YES;
		transition.delegate = self;
		
		[self.view.layer addAnimation:transition forKey:nil];
		
	}
	else {
		
		if (moreFlg) {
			if (!myTableView.dragging && !myTableView.tracking && !myTableView.decelerating) {
				[myTableView reloadData];
			}	
		}else {
			[self resetMyTalbleView];
		}
		self.ListContentParser = nil;
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}




#pragma mark -
#pragma mark tableView delegate

/**
 테이블 사이즈 조정
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0.0f;
	
	if (indexPath.section == 0) {
		height = adlist_row;
	}
	else {
		height = postlist_row;
	}
	
	return height;
}


#pragma mark -
#pragma mark Table view data source
/**
 테이블 리스트수 카운트 설정
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    // Return the number of sections.
    return 3;
}


/**
 테이블 리스트수 설정
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger rowCount = 0;
	
	if (section == 0) {
		if (Section_Code == nil) {
			if ([MaincontentArray count] > 0 ) {
				rowCount = 1;
			}else {
				rowCount = 0;
			}
			
			//rowCount = 1;
		}else {
			rowCount = 0;
		}
	}
	else if (section == 1) {
		rowCount = [contentArraySub count];
	}
	else {
		if ([contentArraySub count] > 0) {
			rowCount = 1;
		}
	}
	return rowCount;
}

/**
리스트 내용표시
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


	if (indexPath.section == 0) {

		NSString *CellIdentifier = @"AdCell";

		ArticleMainCustomCell *cell = (ArticleMainCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[ArticleMainCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.tag = indexPath.row;
			[cell setupMode:YES];
			
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:DefaultImg3G];
			cell.myImageView.image = image;
			[image release];
			
		}
		
		if (indexPath.row >= [MaincontentArray count]) {
			
		}
		else{
			
			// Configure the cell...
			ArticleListContent *content = [MaincontentArray objectAtIndex:indexPath.row];
			if ([content.image length] == 0) {
				[cell setupMode:NO];
			}
			else {
				if (!cell.myImageFlag){
					[cell setupThumbNail:content.Limage];
					[cell setupMode:YES];
				}
			}
			cell.myTextLabel.text = content.title;
			
		}
		return cell;
	}
	else if (indexPath.section == 1) {
		NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%d", (indexPath.row % 200)];
		
		ArticleListCustomCell *cell = (ArticleListCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[ArticleListCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.tag = indexPath.row;
			[cell setupMode:YES];
			
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:DefaultImg3G];
			cell.myImageView.image = image;
			[image release];
			
		}
		
		if (indexPath.row >= [contentArraySub count]) {
			
		}
		else{
		
			NSMutableDictionary *cellcontentdic = [contentArraySub objectAtIndex:indexPath.row];
		
			NSString *flgString = [cellcontentdic objectForKey:ADFLG];
			
			if ([flgString isEqualToString:@"NO"]) {
				ArticleListContent *content = [cellcontentdic objectForKey:CONTENTDIC];
				if ([content.image length] == 0) {
					[cell setupMode:NO];
				}
				else {
					if (!cell.myImageFlag){
						[cell setupThumbNail:content.image];
						[cell setupMode:YES];
					}
				}
				cell.myTextLabel.text = content.title;
				cell.myDetailTextLabel.text = content.description;
				
			}else {
				
				if (cell.adViewIndexPath == 0) {
					cell.adViewIndexPath = cellAdViewIndex;
					if (cellAdViewIndex == 1) {
						cellAdViewIndex = 2;
					}else {
						cellAdViewIndex = 1;
					}					
				}


				[cell setupMode:NO];
				[cell setupADView:indexPath.row];
			}

		}

		return cell;	
		
	}
	else {
		
		NSString *CellIdentifier = @"MoreCell";
		MoreCell *cell = (MoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil) {
			cell = [[[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.textLabel.textColor = [UIColor colorWithRed:31.0/255.0 green:66.0/255.0 blue:126.0/255.0 alpha:1.0];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
		}
		
		cell.textLabel.text = @"기사 더보기...";
	
		return cell;
	}
		
}


/**
 리스트 선택  
 */
#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([contentArray count] > 0) {
		
		networkStatus = [self checkNetworkStatus];
		SelectedCell = NO;
		[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:NO];
		if (indexPath.section == 0) {

			ArticleListContent *content = [contentArray objectAtIndex:indexPath.row];
			ArticleDetailViewController *detailview = [[ArticleDetailViewController alloc] init];
			detailview.contentSendFlg = NO;
			detailview.row           = indexPath.row;
			detailview.ListDataArray = MaincontentArray;
			detailview.CountDataArray= contentArray;
			detailview.idnumber      = content.link_id;
			detailview.ViewFlg		 = @"MAIN";
			[self.navigationController pushViewController:detailview animated:YES];
			[detailview release];
			
		}else if(indexPath.section == 1) {
	
			NSMutableDictionary *cellcontentdic = [contentArraySub objectAtIndex:indexPath.row];
			
			NSString *flgString = [cellcontentdic objectForKey:ADFLG];
			
			if ([flgString isEqualToString:@"NO"]) {
				ArticleListContent *content = [cellcontentdic objectForKey:CONTENTDIC];
				ArticleDetailViewController *detailview = [[ArticleDetailViewController alloc] init];
				detailview.contentSendFlg = YES;
				detailview.row           = indexPath.row;
				detailview.ListDataArray = contentArraySub;
				detailview.CountDataArray= MaincontentArray;
				detailview.idnumber      = content.link_id;
				detailview.ViewFlg		 =@"";
				[self.navigationController pushViewController:detailview animated:YES];
				[detailview release];
				
			}		
		}
		else {

			if (networkStatus != network_disable) {
				[self insertContent];
			}
		}
	}
}


#pragma mark -
#pragma mark Orientation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
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
    [super dealloc];
	[contentArray release];
	[ListContentParser release];
	[MainListContentParser release];
	[CategoryScrollView release];
	[Button1 release];
	[Button2 release];
	[Button3 release];
	[Button4 release];
	[Button5 release];
	[Button6 release];
	[Button7 release];
	[Button8 release];
	[Button9 release];
	[LeftImage release];
	[RightImage release];
	[categorybtnimage release];
	[contentArraySub release];
	[List release];
	[Picture release];
}



// 2010.8.3 Lee Sungman

- (void)setupArticlePictureViewController {
	if (apvc == nil) {
		apvc = [[ArticlePictureViewController alloc] initWithNibName:@"ArticlePictureViewController" bundle:nil];
		apvc.delegate = self;
	}

}

- (void)setupArticlePictureViewControllerContent{
	apvc.contentArray = contentArray;
}


// navigation bar에 버튼 생성하는 함수
- (void)setupBarButtonItem:(NSInteger)flag {
	
	self.navigationItem.rightBarButtonItem = nil;
	
	UIBarButtonItem *barButtonItem = nil;
	
	
	if (List == nil) {
		List = [[UIImage alloc] init];
	}
	
	if (Picture == nil) {
		Picture = [[UIImage alloc] init];
	}


	
	Picture = ArticlePicture3G;
	List = ArticleList3G;
	
	if (flag == 1) {
		
		barButtonItem = [[UIBarButtonItem alloc] initWithImage:Picture
														 style:UIBarButtonItemStyleBordered
														target:self
														action:@selector(ListbarButtonAction:)];
		barButtonItem.tag = 1;

	}
	else if (flag == 2) {
		barButtonItem = [[UIBarButtonItem alloc] initWithImage:List
														 style:UIBarButtonItemStyleBordered
														target:self
														action:@selector(ListbarButtonAction:)];
		barButtonItem.tag = 2;
		
	}
	
	self.navigationItem.rightBarButtonItem = barButtonItem;
	[barButtonItem release];
	

	
}


/**
 사진보기뷰와 기사리스트 보기뷰로 분할
 */
#pragma mark -
#pragma mark NavigationbarButton
// navigation bar의 버튼 action
- (void)barButtonAction:(id)sender {
	
	if (transitioning)
		return;
	
	UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
	
	if (barButtonItem.tag == 1) {
		
		// 화면 전환
		[myTableView removeFromSuperview];
		[self setupArticlePictureViewController];
		[self setupArticlePictureViewControllerContent];
		[self.view addSubview:apvc.view];
		
		[apvc setupScrollViewContentSize];
		
		[self setupBarButtonItem:2];
		
		[apvc reSetupadView];
	}
	else if (barButtonItem.tag == 2) {
		// 화면 전환
		[apvc.view removeFromSuperview];
		[self.view addSubview:myTableView];
		[self setupBarButtonItem:1];
		// 화면상에 보여지는 테이블 셋팅
		[self setupTableView:YES];
	}
	
	CATransition *transition = [CATransition animation];
	transition.duration = 0.5;
	transition.type = kCATransitionFade;
	
	transitioning = YES;
	transition.delegate = self;
	
	[self.view.layer addAnimation:transition forKey:nil];
}


// navigation bar의 버튼 action
- (void)ListbarButtonAction:(id)sender {
	
	if (transitioning)
		return;
	
	UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
	
	if (barButtonItem.tag == 1) {

		// 화면 전환
		[self setupArticlePictureViewController];
		[self.view addSubview:apvc.view];
		if ([CategoryScrollView superview]) {
			CategoryScrollView.hidden =YES;
		}
		if (Section_Code == nil) {
			[apvc downloadImageDecision:@"ALL"];			
		}else {
			[apvc downloadImageDecision:Section_Code];
		}
		[apvc setupScrollViewContentSize];

		[self setupBarButtonItem:2];
		
		[apvc reSetupadView];

	}
	else if (barButtonItem.tag == 2) {

		// 화면 전환
		[apvc.view removeFromSuperview];
		CategoryScrollView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 80.0f);
		if (![LeftImage superview]) {
			[self.view addSubview:LeftImage];
			LeftImage.hidden = YES;
		}
		if (![RightImage superview]) {
			[self.view addSubview:RightImage];
			RightImage.hidden = NO;
		}
		CategoryScrollView.hidden = NO;
		[self.view addSubview:myTableView];
		[self setupBarButtonItem:1];
		// 화면상에 보여지는 테이블 셋팅
		[self setupTableView:YES];
		
		if ([contentArraySub count] > 0) {
			if (!myTableView.dragging && !myTableView.tracking && !myTableView.decelerating) {
				[myTableView reloadData];
			}
		}

	}
	
	CATransition *transition = [CATransition animation];
	transition.duration = 0.5;
	transition.type = kCATransitionFade;
	transitioning = YES;
	transition.delegate = self;
	[self.view.layer addAnimation:transition forKey:nil];
}


/**
 설정버튼 클릭시 설정화면 표시
 */
#pragma mark NavigationbarSettingAction
- (void)settingAction {
	
	
	SettingViewController *info = [[SettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	BookScreenViewCtrl *thirdViewController = [[appDelegate.tabBarController viewControllers] objectAtIndex:1];
	info.delegate = thirdViewController;
	UINavigationController *mn = [[UINavigationController alloc] initWithRootViewController:info];
	[info release];
	[self presentModalViewController:mn animated:YES];
	[mn release];

}


#pragma mark transition delegate
-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	transitioning = NO;
}



#pragma mark ArticlePictureViewController delegate

- (void)articleWasTapped:(NSInteger)index {

	ArticleListContent *content = [contentArray objectAtIndex:index];
	ArticleDetailViewController *detailview = [[ArticleDetailViewController alloc] init];
	detailview.idnumber      = content.link_id;
	detailview.contentSendFlg = NO;
	detailview.row           = index;
	detailview.ListDataArray = contentArray;
	[self.navigationController pushViewController:detailview animated:YES];
	[detailview release];

}

#pragma mark -
#pragma mark CategoryButtonEvent
/*******************************************************
카테고리 버튼 클릭시에 해당 데이터를 검색하고해당버튼에 
백그라운드 이미지를 표시하여 버튼을 클릭하였다는 것을 인식시켜 준다
*******************************************************/

// 전체
- (IBAction)TotalArticleList{

	[self MainListArticle];
	Section_Code = nil;
	[Button1 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];
	[Button2 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button3 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button4 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button5 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button6 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button7 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button8 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button9 setBackgroundImage:nil forState:UIControlStateNormal];
	FirstListView = YES;
	[self ButtonAction];
	
}
// 커버/특집
- (IBAction)SpecialArticleList{
	
	MaincontentArray = nil;
	Section_Code = @"S1N1";
	[Button1 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button2 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];
	[Button3 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button4 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button5 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button6 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button7 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button8 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button9 setBackgroundImage:nil forState:UIControlStateNormal];
	FirstListView = YES;	
	[self ButtonAction];
	
}
// 정치/경제
- (IBAction)EconomyArticleList{

	MaincontentArray = nil;
	Section_Code = @"S1N2";
	[Button1 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button2 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button3 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];
	[Button4 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button5 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button6 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button7 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button8 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button9 setBackgroundImage:nil forState:UIControlStateNormal];
	FirstListView = YES;
	[self ButtonAction];
	
}
// 사회/문화
- (IBAction)CommunityArticleList{

	MaincontentArray = nil;
	Section_Code = @"S1N3";
	[Button1 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button2 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button3 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button4 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];
	[Button5 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button6 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button7 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button8 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button9 setBackgroundImage:nil forState:UIControlStateNormal];
	FirstListView = YES;
	[self ButtonAction];
	
}
// 국제/한번도
- (IBAction)InternationalArticleList{

	MaincontentArray = nil;
	Section_Code = @"S1N4";
	[Button1 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button2 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button3 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button4 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button5 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];
	[Button6 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button7 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button8 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button9 setBackgroundImage:nil forState:UIControlStateNormal];
	FirstListView = YES;
	[self ButtonAction];
	
}
// 인터뷰/오피니언
- (IBAction)InterviewArticleList{
	
	MaincontentArray = nil;
	Section_Code = @"S1N5";
	[Button1 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button2 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button3 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button4 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button5 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button6 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];
	[Button7 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button8 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button9 setBackgroundImage:nil forState:UIControlStateNormal];	
	FirstListView = YES;
	[self ButtonAction];
	
}
// 실용/과학
- (IBAction)ScienceArticleList{

	MaincontentArray = nil;
	Section_Code = @"S1N6";
	[Button1 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button2 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button3 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button4 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button5 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button6 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button7 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];
	[Button8 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button9 setBackgroundImage:nil forState:UIControlStateNormal];	
	FirstListView = YES;
	[self ButtonAction];
}

// 사진/만화
- (IBAction)PictureArticleList{

	MaincontentArray = nil;
	Section_Code = @"S1N7";
	[Button1 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button2 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button3 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button4 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button5 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button6 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button7 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button8 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];
	[Button9 setBackgroundImage:nil forState:UIControlStateNormal];	
	FirstListView = YES;
	[self ButtonAction];
}

// 책꽃이
- (IBAction)BookArticleList{

	MaincontentArray = nil;
	Section_Code = @"S1N8";
	[Button1 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button2 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button3 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button4 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button5 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button6 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button7 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button8 setBackgroundImage:nil forState:UIControlStateNormal];
	[Button9 setBackgroundImage:categorybtnimage forState:UIControlStateNormal];	
	FirstListView = YES;
	[self ButtonAction];
	
}


#pragma mark CategoryButtonButtonAction

// 기사파일 리스트 세팅
- (void)ButtonAction{
	
	moreFlg = NO;
	[self setupTableView:YES];
}

#pragma mark -
#pragma mark scrollView delegate

// 스크롤시 페이지 번호 취득하기
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

	if (scrollView == CategoryScrollView) {
		
		NSInteger newPageNumber = ((scrollView.contentOffset.x / 20));
		
		if (newPageNumber < 2 ) {
			LeftImage.hidden = YES;
			RightImage.hidden = NO;
		}
		else if (newPageNumber >= 2 && newPageNumber <= 17) {
			LeftImage.hidden = NO;
			RightImage.hidden = NO;
		}else if (newPageNumber > 17) {
			LeftImage.hidden = NO;
			RightImage.hidden = YES;
		}
	}
	
}

@end
