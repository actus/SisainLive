//
//  AboutViewCtrl.m
//  sisain
//
//  Created by Jupiter on 10. 8. 3..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import "AboutViewCtrl.h"
#import "SisainliveAppDelegate.h"

@implementation AboutViewCtrl

- (void)dealloc {
	[myWebView release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	NSMutableString *file = [[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about.html" ofType:nil] encoding:NSUTF8StringEncoding error:nil];

	[file replaceOccurrencesOfString:@"bg_img" withString:group_background options:NSCaseInsensitiveSearch range:NSMakeRange(0, [file length])];
	[[NSString stringWithFormat:file, app_version] writeToFile:[documents_folder stringByAppendingPathComponent:@"about.html"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[documents_folder stringByAppendingPathComponent:@"about.html"]]]];


}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



#pragma mark webView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *identifier = [[request URL] scheme];
	
	BOOL result = NO;
	if ([identifier isEqualToString:@"file"]) {
		result = YES;
	}
	else if ([identifier isEqualToString:@"http"]) {
		[[UIApplication sharedApplication] openURL:[request URL]];
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	SisainliveAppDelegate *sisaappDelegate = (SisainliveAppDelegate *) [[UIApplication sharedApplication] delegate];
	if ([sisaappDelegate.OrientationFlg isEqualToString:@"YES"]) {
		return YES;
	}
    else{
		return NO; 
    }
}
@end
