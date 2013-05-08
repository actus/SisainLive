//
//  BookMarkListViewController.m
//  sisain
//
//  Created by snow leopard on 10. 8. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BookMarkListViewController.h"
#import "BookMarkListContent.h"
#import "BookMarkDetailViewController.h"
#import "ArticleListCustomCell.h"
#import "SettingViewController.h"
#import "BookScreenViewCtrl.h"


@implementation BookMarkListViewController


- (void)dealloc {
    [super dealloc];
	if (myTableView) {
		[myTableView removeFromSuperview];
		[myTableView release];
	}
	

	[contentIndex release];
}
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
	networkStatus = [self checkNetworkStatus];
	reloadTableView = NO;
	appDelegate.bookmarkFlag = YES;
	contentIndex = [[NSMutableString alloc] initWithFormat:@"%d", 0];
	
	UINavigationBar *bar = [self.navigationController navigationBar]; 
	[bar setTintColor:[UIColor colorWithRed:.059 green:0.153 blue:0.376 alpha:1]]; 
	UIBarButtonItem *barButtonItem = nil;
	

	UIImage *img = [[UIImage alloc] initWithContentsOfFile:setting];
	
	barButtonItem = [[UIBarButtonItem alloc] initWithImage:img
													 style:UIBarButtonItemStyleBordered
													target:self
													action:@selector(settingAction)];
	
	self.navigationItem.leftBarButtonItem = barButtonItem;
	[barButtonItem release];
	
}


// 기동시 기사파일리스트 테이블 생성
- (void)viewWillAppear:(BOOL)animated {
	
	appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	self.navigationItem.title = @"북마크";

//	[self setupTableView:NO];	

	networkStatus = [self checkNetworkStatus];
	
	[self setupTableView:YES];
	
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
	else {
		[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[self setEditing:NO animated:NO];
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




// 기사파일 리스트 세팅
- (void)setupTableView:(BOOL)getData {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	if (myTableView) {
		[myTableView removeFromSuperview];
		[myTableView release];
		myTableView = nil;
	}
	myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, deviceHeight-112) style:UITableViewStylePlain];
	myTableView.dataSource = self;
	myTableView.delegate = self;
	[self.view addSubview:myTableView];
	
	[appDelegate getBookmarkList];
	
	[myTableView reloadData];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    // Return the number of sections.
    return 2;
}


- (void)setupEditButton {
	if ([appDelegate.bookmarkIndex count] > 0) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	}
	else {
		[self setEditing:NO animated:NO];
		self.navigationItem.rightBarButtonItem = nil;
	}
}


// Invoked when the user touches Edit.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
	// Updates the appearance of the Edit|Done button as necessary.
	[super setEditing:editing animated:animated];
	[myTableView setEditing:editing animated:YES];
	
	if (editing) {
		//[myTableView beginUpdates];
		[[self editButtonItem] setTitle:NSLocalizedString(@"완료", @"완료")];
	}
	else {
		//[myTableView endUpdates];
		[[self editButtonItem] setTitle:NSLocalizedString(@"편집", @"편집")];
	}
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary *content = [appDelegate.bookmarkList objectForKey:[appDelegate.bookmarkIndex objectAtIndex:indexPath.row]];
		[appDelegate deleteBookmark:[content objectForKey:book_idnum]];
		

		
		/* 20100915 수정_Start
		 내용:북마크 리스트에서 항목을 삭제하면 타이틀 부분은 문제가 없지만 이미지가 변경되지 않음.
			 제목과 이미지가 매칭이 안됨.
		*/
		// 데이터를 지우는 듯한 표현을 해준다
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
		/* 20100915 수정_End*/
	}
}


// 테이블 리스트수 설정
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	[self setupEditButton];
    
	// Return the number of rows in the section.
	NSInteger rowCount = 0;
	
	if (section == 0) {
		rowCount = 0;
	}
	else {
		if ([appDelegate.bookmarkIndex count] > 0) {
			rowCount = [appDelegate.bookmarkIndex count];
		}
	}
	return rowCount;
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section == 0) {
		
		NSString *CellIdentifier = @"AdCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Configure the cell...
		
		return cell;
	}else {
		NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%d", (indexPath.row % 1000)];
		
		ArticleListCustomCell *cell = (ArticleListCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[ArticleListCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.tag = indexPath.row;

			[cell setupMode:YES];
			
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:DefaultImg3G];
			cell.myImageView.image = image;
			[image release];
		}
		// Configure the cell...
		NSDictionary *content = [appDelegate.bookmarkList objectForKey:[appDelegate.bookmarkIndex objectAtIndex:indexPath.row]];


		if ([[content objectForKey:book_image] length] == 0) {
			[cell setupMode:NO];
		}
		else {
			[cell setupMode:YES];
			if (!cell.myImageFlag)
				[cell setupThumbNail:[content objectForKey:book_image]];
		}


		cell.myTextLabel.text = [content objectForKey:book_title];
		cell.myDetailTextLabel.text = [content objectForKey:book_description];
		return cell;	

	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:NO];

	BookMarkDetailViewController *detailview = [[BookMarkDetailViewController alloc] init];
	detailview.DetailList  = appDelegate.bookmarkList;
	detailview.DetailIndex = appDelegate.bookmarkIndex;
	detailview.row         = indexPath.row;
	[self.navigationController pushViewController:detailview animated:YES];
	
}

#pragma mark tableView delegate

// 테이블 사이즈 조정
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark SettingAction

// 설정버튼
- (void)settingAction {
	
	SettingViewController *info = [[SettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
	appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	BookScreenViewCtrl *thirdViewController = [[appDelegate.tabBarController viewControllers] objectAtIndex:1];
	info.delegate = thirdViewController;
	UINavigationController *mn = [[UINavigationController alloc] initWithRootViewController:info];
	[info release];
	[self presentModalViewController:mn animated:YES];
	[mn release];
}



@end
