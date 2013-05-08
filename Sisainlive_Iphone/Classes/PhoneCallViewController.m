//
//  PhoneCallViewController.m
//  Sisainlive
//
//  Created by snow leopard on 10. 9. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PhoneCallViewController.h"
#import "SettingViewController.h"
#import "BookScreenViewCtrl.h"

@implementation PhoneCallViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	myWebView.delegate = self;
	// 타이틀 설정
	self.navigationItem.title =@"구독신청";
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
	
	// 페이지에 표시될 파일에 관한 설정	
	NSMutableString *file = [[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PhoneCall.html" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
	
	// BackGround이미지 설정
	[file replaceOccurrencesOfString:@"bg_img" withString:group_background options:NSCaseInsensitiveSearch range:NSMakeRange(0, [file length])];
	[[NSString stringWithFormat:file, app_version] writeToFile:[documents_folder stringByAppendingPathComponent:@"PhoneCall.html"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[documents_folder stringByAppendingPathComponent:@"PhoneCall.html"]]]];
	
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
	[myWebView release];
}



#pragma mark webView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *identifier = [[request URL] scheme];
	NSMutableURLRequest *requestlink = (NSMutableURLRequest *)request;

	
	BOOL result = NO;
	if ([identifier isEqualToString:@"file"]) {
		result = YES;
	}
	else if ([identifier isEqualToString:@"http"]) {
		
		// 직접적인 링크로 페이지를 열 경우 User-Agent가 설정되어 있으므로 모바일 페이지로 이동하여 버린다.
		// 이러한 기능을 없애어서 직접적으로 원하는 페이지로 이동하게 끔 해주는 부분
		[requestlink setValue:[NSString stringWithFormat:@"", [requestlink valueForHTTPHeaderField:@"User-Agent"]] forHTTPHeaderField:@"User_Agent"];
		[[UIApplication sharedApplication] openURL:[requestlink URL]];
		//[[UIApplication sharedApplication] openURL:[request URL]];
	}
	else if ([identifier isEqualToString:@"mailto"]) {
		[[UIApplication sharedApplication] openURL:[request URL]];
	}
	else if ([identifier isEqualToString:@"tel"]) {
		[[UIApplication sharedApplication] openURL:[request URL]];
	}
	
	return result;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark Orientation

// 화면 회전에 따른 변환
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
