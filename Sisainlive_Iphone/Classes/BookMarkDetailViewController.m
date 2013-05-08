//
//  BookMarkDetailViewController.m
//  sisain
//
//  Created by snow leopard on 10. 8. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BookMarkDetailViewController.h"
#import "BookMarkListContent.h"
#import "Constants.h"
#import "SisainliveAppDelegate.h"

@interface BookMarkDetailViewController ()

- (void)loadArticle;

- (void)messageAlertView:(NSString *)aMessage;
@end

@implementation BookMarkDetailViewController
@synthesize title,permalink,content;
@synthesize row;
@synthesize DetailList,DetailIndex;

typedef enum {
	shareActionSheet = 1,
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

/* 광고 삽입을 위해서 수정 11/01/18
- (void)loadView {
	
	web = [[PSWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 400.0f)];
	self.view = web;
	
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	web = [[PSWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 400.0f-80.0f)];
	
	[self.view addSubview:web];

	[self loadArticle];
	
	UIBarButtonItem *barButtonItem = nil;
	
    barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
																  target:self 
																  action:@selector(actionSheetAction)];
	
	self.navigationItem.rightBarButtonItem = barButtonItem;
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
	[web stopLoading];
}

- (void)loadArticle {
	
	NSString *TitleString = [NSString stringWithFormat:@"%d/%d",row+1,[DetailList count]];
	
	NSDictionary *detailcontent = [DetailList objectForKey:[DetailIndex objectAtIndex:row]];
	title     = [detailcontent objectForKey:book_title];
	content   = [detailcontent objectForKey:book_content];
	permalink = [detailcontent objectForKey:book_permalink];
	
	self.navigationItem.title = TitleString;

	web.delegate = self;
	
	[web loadHTMLString:content baseURL:nil];
	
}

- (void)actionSheetAction {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"취소", @"취소")
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"이메일", @"이메일"), nil];
	actionSheet.tag = shareActionSheet;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
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
    [super       dealloc];
	[title       release];
	[content     release];
	[permalink   release];
	[DetailList  release];
	[DetailIndex release];
}

- (void)ArticleCountUP{

	if (row == 0) {
	}
	
	else {
		row = row-1;
		[self loadArticle];
	}
}

- (void)ArticleCountDown{
	if (row == [DetailList count]-1) {

	}
	else {
		row = row+1;
		[self loadArticle];
		
	}
}
#pragma mark actionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case 0:		// 메일보내기
		{
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			[picker setSubject:title];
			[picker setMessageBody:[NSString stringWithFormat:@"%@\n%@",content,permalink] isHTML:YES];
			[self presentModalViewController:picker animated:YES];
			[picker release];			
			break;
		}
	}
}

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
	
	[self dismissModalViewControllerAnimated:YES];
	
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
/*
	SisainliveAppDelegate *appDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];

	if ([appDelegate.OrientationFlg isEqualToString:@"YES"]) {
		return YES;
	}
    else{
		return NO; 
    }
*/
}

@end
