//
//  SettingViewController.m
//  sisain
//
//  Created by snow leopard on 10. 8. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "AboutViewCtrl.h"
#import "SisainliveAppDelegate.h"
#import	"BookScreenViewCtrl.h"
#import "Constants.h"
//#import "SA_OAuthTwitterEngine.h"


#define SPINVIEW_TAG	100

typedef enum {
	loginAlertView = 1,
	infoErrorAlertView,
	messageAlertView,
	limitAlertView,
	loginsuccessed,
	screenredown
} alertViewMode;


typedef enum {
	loginRequest = 1,
	messageRequest,
} requestMode;

@interface SettingViewController ()

- (void)fbLoginIsOk;
- (void)fbDidLogout;
- (void)initTwitterEngine;
- (void)showAlertView:(NSInteger)flag;
- (void)twitterLoginIsSuccessed;
- (void)twitterLogOutIsSuccessed;
- (void)initme2dayEngine;

@end

@implementation SettingViewController
@synthesize delegate;
@synthesize contentArray;
- (void)dealloc {
    [super dealloc];
	[snsArray        release];
	[sectionArray    release];
	[aboutArray      release];
	[reDownloadArray release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"usercertificationStatus" object:nil];

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
	

	UINavigationBar *bar = [self.navigationController navigationBar]; 
	[bar setTintColor:[UIColor colorWithRed:.059 green:0.153 blue:0.376 alpha:1]]; 
	self.title = NSLocalizedString(@"정보&설정", @"정보&설정");
	[self setupBarButtons:self.navigationItem buttonFlag:close_barButton];
	
	// me2day
	[self initme2dayEngine];
	
//	// twitter	
//	[self initTwitterEngine];
	
	[self setupArray];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginstatus:) name:@"usercertificationStatus" object:nil];
}

//- (void)initTwitterEngine {
//	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
//	_engine.consumerKey = kOAuthConsumerKey;
//	_engine.consumerSecret = kOAuthConsumerSecret;
//}
//
- (void)initme2dayEngine{
	me2day = [[me2dayClass alloc] init];
	[me2day setApikey:me2dayAPIKey];
	[me2day setMd5key:nonce];
	[me2day setDelegate:self];
}

- (void)loginstatus:(NSNotification *)notification{
	
	NSString *status = (NSString *)[notification object];
	
	if ([status isEqualToString:@"1"]) {
		[self fbLoginIsOk];
	}else if ([status isEqualToString:@"3"]) {
		[self fbDidLogout];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
	
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



#pragma mark barButton action

- (void)barButtonAction:(id)sender {
	switch ([sender tag]) {
		case close_barButton:
		{
			[self dismissModalViewControllerAnimated:YES];
		}
			break;
	}
}

// 화면에 표시될 메뉴 설정
- (void)setupArray {
	
	
	SisainliveAppDelegate *sisaappDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	
	// 입력하는 Object의 갯수에 따라서 메뉴가 추가됩
	if (!sectionArray) {
		sectionArray	= [[NSArray alloc] initWithObjects:NSLocalizedString(@"", @""), NSLocalizedString(@"SNS 계정", @"SNS 계정"), NSLocalizedString(@"면별보기", @"면별보기"), nil];
	}

	
	// 표시될 메뉴 타이틀 설정
	if (!aboutArray) {
		aboutArray	= [[NSArray alloc] initWithObjects:NSLocalizedString(@"이 어플리케이션에 관하여", @"이 어플리케이션에 관하여"), nil];
	}
	
	if (!snsArray) {
		snsArray = [[NSMutableArray alloc] initWithCapacity:0];
	}
	
	if (!reDownloadArray) {
		reDownloadArray	= [[NSArray alloc] initWithObjects:NSLocalizedString(@"  면별보기 재 다운로드", @"  면별보기 재 다운로드 "), nil];
	}
	
	[snsArray removeAllObjects];
	
	// me2day
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"me2dayId"] length] > 0 &&
		[[[NSUserDefaults standardUserDefaults] stringForKey:@"me2dayPwd"] length] > 0) {
		[snsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"미투데이 로그아웃", @"미투데이 로그아웃"), @"label", me2day_logo, @"image", nil]];
	}else {
		[snsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"미투데이", @"미투데이"), @"label", me2day_logo, @"image", nil]];
	}
	
	// FaceBook	
	if (sisaappDelegate.facebook._session.isConnected) {
		[snsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"페이스북 로그아웃", @"페이스북 로그아웃"), @"label", facebook_logo, @"image", nil]];
		
	}else {
		[snsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"페이스북", @"페이스북"), @"label", facebook_logo, @"image", nil]];
	}
	
	// Twitter
	if ([[[NSUserDefaults standardUserDefaults] objectForKey: @"authData"] length] > 0) {
		[snsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"트위터 로그아웃", @"트위터 로그아웃"), @"label", twitter_logo, @"image", nil]];
	}
	else {
		[snsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"트위터", @"트위터"), @"label", twitter_logo, @"image", nil]];
	}
	
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionArray count];
}



// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 0;
	
	if (section == 0) {
		numberOfRows = [aboutArray count];
	}
	else if (section == 1) {
		numberOfRows = [snsArray count];
	}
	else if (section == 2) {
		numberOfRows = [reDownloadArray count];
	}
	
    return numberOfRows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set up the cell...
	// 어플리케이션에 관한 설명
	if (indexPath.section == 0) {
		NSString *CellIdentifier = @"DefaultCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = [aboutArray objectAtIndex:indexPath.row];
		
		return cell;
	}
	// me2DAY, FaceBook에 관한 로그인 로그아웃 설정
	else if (indexPath.section == 1) {
		// Set up the cell...
		NSString *CellIdentifier = @"DefaultCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		NSDictionary *dic = [snsArray objectAtIndex:indexPath.row];
		
		cell.textLabel.text = [dic objectForKey:@"label"];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:[dic objectForKey:@"image"]];
		cell.imageView.image = image;
		[image release];
		
		return cell;
	}
	// 면별보기 재다운로드에 관한 설정
	else if (indexPath.section == 2) {
		// Set up the cell...
		NSString *CellIdentifier = @"DefaultCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.textLabel.text = [reDownloadArray objectAtIndex:indexPath.row];
		
		return cell;
	}
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return indexPath;

}

#pragma mark -
#pragma mark didSelectRowAtIndexPath

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section == 0) {

		AboutViewCtrl *anotherViewController = [[AboutViewCtrl alloc] initWithNibName:@"AboutViewCtrl" bundle:nil];
		anotherViewController.title = [aboutArray objectAtIndex:indexPath.row];
		[self.navigationController pushViewController:anotherViewController animated:YES];
		[anotherViewController release];

		
	}
	else if (indexPath.section == 1) {
	
		SisainliveAppDelegate *sisaappDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
		
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
		NSDictionary *dic = [snsArray objectAtIndex:indexPath.row];
		
		if ([[dic objectForKey:@"label"] isEqualToString:NSLocalizedString(@"페이스북", @"페이스북")]) {
			[sisaappDelegate.facebook facebookLogin];
			
		}
		else if ([[dic objectForKey:@"label"] isEqualToString:NSLocalizedString(@"페이스북 로그아웃", @"페이스북 로그아웃")]) {
			[sisaappDelegate.facebook facebookLogOut];
		}
		else if ([[dic objectForKey:@"label"] isEqualToString:NSLocalizedString(@"미투데이", @"미투데이")]) {
			[me2day login];
		}
		else if ([[dic objectForKey:@"label"] isEqualToString:NSLocalizedString(@"미투데이 로그아웃", @"미투데이 로그아웃")]) {
			[me2day logout];
        }
//		}else
//            if ([[dic objectForKey:@"label"] isEqualToString:NSLocalizedString(@"트위터", @"트위터")]) {
//			if (_engine == nil) {
//				[self initTwitterEngine];
//			}
//			UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
//			
//			if (controller)
//				[self presentModalViewController:controller animated: YES];
//			
//		}
//		else if ([[dic objectForKey:@"label"] isEqualToString:NSLocalizedString(@"트위터 로그아웃", @"트위터 로그아웃")]) {
//			[_engine clearAccessToken];
//		}
		
	}
	else if (indexPath.section == 2) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
		[self screenBook];
	}
}


#pragma mark -
#pragma mark screenBook

// 면별보기 재다운로드 버튼을 클릭 했을 경우 메세지 창으로 해당내용을 표시하고
// 확인을 클릭했을 경우 실행
- (void)screenBook{

	
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];

	if (appDelegate.redownloadflg) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														message:@"\n\n\n\n"
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];

		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,20,260,100)];
		textLabel.font = [UIFont systemFontOfSize:16];
		textLabel.textColor = [UIColor whiteColor];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.numberOfLines = 3;
		textLabel.textAlignment = UITextAlignmentCenter;
		textLabel.text = NSLocalizedString(@"redownNG", @"redownNG");
		[alert addSubview:textLabel];
		
		[textLabel release];
		
		[alert show];
		[alert release];
		
		
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"redown", @"redown")
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
		
		[textLabel release];
		alert.tag = screenredown;
		[alert show];
		[alert release];
	}

}

/**
 로그인 처리 후에 해당로그인 처리가 완료되었을 시: 해당되는 함수로 리턴되어서 해당되는 메세지를 표시하여 준다
 함수명은 지정되어 있으므로 해당되는 함수를 사용할 것.그이외의 함수를 사용시에는 해당되는 처리가 일어나지 않는다.
 */
- (void)me2dayLoginIsSuccessed{
	
	[self showAlertView:1];
}
/**
 로그인 처리 후에 해당로그인 처리가 실패하였을 시: 해당되는 함수로 리턴되어서 해당되는 메세지를 표시하여 준다
 함수명은 지정되어 있으므로 해당되는 함수를 사용할 것.그이외의 함수를 사용시에는 해당되는 처리가 일어나지 않는다.
 */
- (void)me2dayLoginIsFaild{
	
	[self showAlertView:2];
}

/**
 로그아웃 처리 후에 해당로그아웃 처리가 완료 되었을 시: 해당되는 함수로 리턴되어서 해당되는 메세지를 표시하여 준다
 함수명은 지정되어 있으므로 해당되는 함수를 사용할 것.그이외의 함수를 사용시에는 해당되는 처리가 일어나지 않는다.
 */
- (void)me2dayLogoutIsSuccessed{
	
	[self showAlertView:3];
	
}

#pragma mark Facebook delegate

- (void)fbLoginIsOk{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"로그인 성공", @"로그인 성공")
													message:nil 
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"확인", @"확인")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	[self setupArray];
}

- (void)fbDidLogout {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"로그아웃 성공", @"로그아웃 성공")
													message:nil 
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"확인", @"확인")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	[self setupArray];
}



- (void)fbLoginCanceled {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	if (buttonIndex == 0) {
		if(alertView.tag == infoErrorAlertView) {
			
		}
	}
	else if (buttonIndex == 1) {
		switch (alertView.tag) {
			case screenredown:
			{
				[delegate reDownload];
				break;
			}
		}
	}
}


//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
	
	if ([data length] == 0) {
		[self twitterLogOutIsSuccessed];
		[self setupArray];
	}
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}
//=============================================================================================================================
//#pragma mark SA_OAuthTwitterControllerDelegate
//- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
//	[self twitterLoginIsSuccessed];
//	[self setupArray];
//}

// 직접적인 베이직 로그인이 아니므로 따로 AlertView를 출력할 시 재로그인화면과 겹쳐져버림
//- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
//	NSLog(@"Authentication Failed!");
//}

//- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
//	NSLog(@"Authentication Canceled.");
//}
//=============================================================================================================================


#pragma mark TwitterClass delegate

- (void)showTwitterViewCtrl:(UIViewController *)controller {
	[self presentModalViewController:controller animated:YES];
}


- (void)twitterLoginIsSuccessed {
	
	[self showAlertView:1];
}


- (void)twitterLogOutIsSuccessed {
	
	[self showAlertView:3];
}

- (void)showAlertView:(NSInteger)flag {
	UIAlertView *alert;
	NSString *alertTitle;
	if (flag == 1) {
		alertTitle = NSLocalizedString(@"로그인 성공", @"로그인 성공");
	}
	else if(flag == 2){
		alertTitle = NSLocalizedString(@"로그인 실패", @"로그인 실패");
	}
	else if (flag == 3) {
		alertTitle = NSLocalizedString(@"로그아웃 성공", @"로그아웃 성공");
	}
	
	alert = [[UIAlertView alloc] initWithTitle:alertTitle
									   message:nil 
									  delegate:self 
							 cancelButtonTitle:NSLocalizedString(@"확인", @"확인")
							 otherButtonTitles:nil];
	[alert show];
	[alert release];
	[self setupArray];	
}


@end
