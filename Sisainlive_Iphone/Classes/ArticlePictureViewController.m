//
//  ArticlePictureViewController.m
//  sisain
//
//  Created by Jupiter on 10. 8. 3..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import "ArticlePictureViewController.h"
#import "ArticleListContent.h"
#import	"SisainliveAppDelegate.h"
#import "Constants.h"
#define PICTURE_IMAGE_FILE_PREFIX @"PictureImage_"

#define IMAGEVIEW_TAG	100
#define IMAGE_SPACE		5.0f

/**
 기사사진 뷰
 */
@interface ArticlePictureViewController ()
- (void)setupLabel;
- (void)setupData:(NSInteger)page;

- (void)setupScrollViewData;
- (void)setupadView;

//- (ArticleImageView *)dequeueReusableTile;
- (ArticleImageView *)dequeueReusableTile:(ArticleListContent*)content;
- (void)setAlpha;
- (void)setupDescriptionData:(NSInteger)page;
@end



@implementation ArticlePictureViewController

@synthesize contentArray;
@synthesize delegate;
@synthesize Section_Code;


- (void)dealloc {
	[Section_Code release];
	[scrollView release];
	[descriptionLabel release];
	[contentArray release];
	[reusableTiles release];
	[super dealloc];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		reusableTiles = [[NSMutableSet alloc] init];
		
		firstVisibleIndex = NSIntegerMax;
        lastVisibleIndex = NSIntegerMin;
    }
    return self;
}

- (void)downloadImageDecision:(NSString *)sectionName{
	
	if ([Section_Code isEqualToString:sectionName]) {
	}else {
		Section_Code = sectionName;
		
		// 다운로드된 파일들이 저장되는 경로를 지정
		NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] retain];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
		for (NSString *fileName in contentsOfDirectory) {
			int count = [fileName length];
			if (count > 13) {
				if ([[fileName substringToIndex:13] isEqualToString:PICTURE_IMAGE_FILE_PREFIX]) {
					[fileManager removeItemAtPath:[documentPath stringByAppendingPathComponent:fileName] error:nil];
				}
			}
		}
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	
    [super viewDidLoad];
	
	Section_Code = @"ALL";
	
	UIImage *leftbutton = [[UIImage alloc] init];
	UIImage *rightbutton = [[UIImage alloc] init];
	
	leftbutton = LeftButtonPicture3G;
	rightbutton = RightButtonPicture3G;
	
	[leftButton setImage:leftbutton forState:UIControlStateNormal];
	leftButton.backgroundColor = [UIColor blackColor];
	
	[rightButton setImage:rightbutton forState:UIControlStateNormal];
	rightButton.backgroundColor = [UIColor blackColor];
	
	[self setupLabel];
	
	[self setupadView];
}

- (void)viewWillAppear:(BOOL)animated {
}
- (void)viewWillDisappear:(BOOL)animated {
}
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

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



- (IBAction)buttonAction:(id)sender {
	if ([sender tag] == 1) {
		[self setupData:currentPage - 1];
		
	}
	else if ([sender tag] == 2) {
		[self setupData:currentPage + 1];
	}
}



#pragma mark public methods


- (void)setupScrollViewContentSize {
	[reusableTiles removeAllObjects];
	
	networkStatus = [self checkNetworkStatus];
	if (networkStatus != network_disable) {
		
		[self NOshowNetworkError];
		if (contentArray == nil || [contentArray count] == 0) {
			
			leftButton.enabled = NO;
			rightButton.enabled = NO;
			descriptionLabel.userInteractionEnabled = NO;
			
			scrollView.contentSize = CGSizeMake(0.0f, 0.0f);
			
		}
		else {
			leftButton.enabled = YES;
			rightButton.enabled = YES;
			descriptionLabel.userInteractionEnabled = YES;
			
			scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * [contentArray count], scrollView.bounds.size.height);
			[self setupScrollViewData];
			
			CGFloat pageWidth = scrollView.frame.size.width;
			NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
			[self setupDescriptionData:page];
		}
		
	}
	else {
		[self showNetworkError];
	}
	
}

#pragma mark UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)a_scrollView {
	[self setAlpha];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)a_scrollView {
	CGFloat pageWidth = scrollView.frame.size.width;
	NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[self setupDescriptionData:page];
	[self setAlpha];
	
}


- (void)scrollViewDidScroll:(UIScrollView *)a_scrollView {
	[self setupScrollViewData];
}

#pragma mark private methods

- (void)setupLabel {
	descriptionLabel = [[DescriptionLabel alloc] initWithFrame:CGRectMake(40.0f, 240.0f, 240.0f, 70.0f)];
	descriptionLabel.textAlignment = UITextAlignmentCenter;
	descriptionLabel.textColor = [UIColor whiteColor];
	descriptionLabel.backgroundColor = [UIColor clearColor];
	descriptionLabel.numberOfLines = 0;
	descriptionLabel.delegate = self;
	[self.view addSubview:descriptionLabel];
}

- (void)setupadView{

	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	[self.view addSubview:appDelegate.adview];
	
}

- (void)reSetupadView{

	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	appDelegate.adview.frame = CGRectMake(0.0f, 320, 320.0f, 48.0f);
	
	if ([appDelegate.adview superview]) {
		[appDelegate.adview removeFromSuperview];
		[self.view addSubview:appDelegate.adview];
	}else {
		[self.view addSubview:appDelegate.adview];
	}

	
}


- (void)setupData:(NSInteger)page {
	if (0 <= page && page < [contentArray count]) {
		CGRect frame = CGRectMake((scrollView.bounds.size.width * page), 0.0f, scrollView.bounds.size.width, scrollView.bounds.size.height);
		[scrollView scrollRectToVisible:frame animated:YES];
		[self setupDescriptionData:page];
	}
}

- (void)setupScrollViewData {
	
	CGFloat x = scrollView.bounds.origin.x - ((self.view.bounds.size.width - scrollView.bounds.size.width) / 2.0f);
	if (x < 0.0f)
		x = 0.0f;
	
	CGRect visibleBounds = CGRectMake(x , 0.0f, self.view.bounds.size.width, scrollView.bounds.size.height);
	
	NSArray *subViews = [scrollView subviews];
	
	for (UIView *aiv in subViews) {
		if (aiv.tag == IMAGEVIEW_TAG) {
			if (!CGRectIntersectsRect(aiv.frame, visibleBounds)) {
				[reusableTiles addObject:aiv];
				[aiv removeFromSuperview];
			}
		}
    }
	
	NSInteger maxIndex = [contentArray count];
	
	if (maxIndex > 0) {
		NSInteger firstNeededIndex = MAX(0, floorf(visibleBounds.origin.x / scrollView.bounds.size.width));
		NSInteger lastNeededIndex  = MIN(maxIndex - 1, floorf(CGRectGetMaxX(visibleBounds) / scrollView.bounds.size.width));
		
		
		for (NSInteger i = firstNeededIndex; i <= lastNeededIndex; i++) {
			BOOL tileIsMissing = (firstVisibleIndex > i || lastVisibleIndex  < i);
			if (tileIsMissing) {
				
				ArticleListContent *content = [contentArray objectAtIndex:i];
				
				ArticleImageView *tile = [self dequeueReusableTile:content];
				
				// 대표이미지 ////////////////////////////////////////////////////////////////////////////////////////
				[tile setupImage:content];
				////////////////////////////////////////////////////////////////////////////////////////////////////
				
				tile.tag = IMAGEVIEW_TAG;
				tile.index = i;
				
				[tile setFrame:CGRectMake((scrollView.bounds.size.width) * i + IMAGE_SPACE, IMAGE_SPACE, scrollView.bounds.size.width - (IMAGE_SPACE * 2.0), scrollView.bounds.size.height - (IMAGE_SPACE * 2.0))];
				[scrollView addSubview:tile];
				
				[tile removeImage:contentArray atTO:i];
			}
		}
		
		firstVisibleIndex = firstNeededIndex;
		lastVisibleIndex  = lastNeededIndex;
	}
}






- (ArticleImageView *)dequeueReusableTile:(ArticleListContent*)content {
	
	ArticleImageView *tile = [reusableTiles anyObject];
	
    if (tile) {
        [[tile retain] autorelease];
		
        [reusableTiles removeObject:tile];
    }
	else {
		tile = [[[ArticleImageView alloc] initWithFrame:scrollView.bounds] autorelease];
		
		tile.delegate = self;
	}
    return tile;
}



- (void)setAlpha {
	NSInteger alpha = leftView.alpha;
	
	if (alpha == 0.0f) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
	}
	
	leftView.alpha = !leftView.alpha;
	rightView.alpha = !rightView.alpha;
	
	if (alpha == 0.0f) {
		[UIView commitAnimations];
	}
}



#pragma mark ArticleImageView delegate

- (void)articleImageViewWasTapped:(NSInteger)index {
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(articleWasTapped:)]) {
		[self.delegate articleWasTapped:index];
	}
}



- (void)setupDescriptionData:(NSInteger)page {
	currentPage = page;
	ArticleListContent *content = [contentArray objectAtIndex:currentPage];
	descriptionLabel.text = content.title;
	descriptionLabel.index = page;
}



#pragma mark DescriptionLabel delegate

- (void)articleLabelWasTapped:(NSInteger)index {
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(articleWasTapped:)]) {
		[self.delegate articleWasTapped:index];
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

@end
