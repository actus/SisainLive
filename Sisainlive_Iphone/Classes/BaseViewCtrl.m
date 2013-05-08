    //
//  BaseViewCtrl.m
//  sisain
//
//  Created by snow leopard on 10. 7. 13..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseViewCtrl.h"

/**
 기본 베이스 뷰
 */
@implementation BaseViewCtrl
@synthesize networklabel;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	networklabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 60.0f)];
    [self setDeviceHeight];
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
	[networklabel release];
}

#pragma mark check current NetworkStatus

/**
 네트워크 체크
 */
- (NSInteger)checkNetworkStatus {
	NSInteger stauts = 0;
	Reachability2 *internetReach = [Reachability2 reachabilityForInternetConnection];
	NetworkStatus networkStatus = [internetReach currentReachabilityStatus];
	
	if (networkStatus == ReachableViaWiFi)
		stauts = network_wifi;
	else if (networkStatus == ReachableViaWWAN)
		stauts = network_3g;
	else if (networkStatus == NotReachable)
		stauts = network_disable;
	
	return stauts;
}


#pragma mark show alertView
/**
 네트워크 에러표시
 */
- (void)showNetworkError {
	
	networklabel.center = self.view.center;
	networklabel.numberOfLines = 0;
	networklabel.textAlignment = UITextAlignmentCenter;
	networklabel.textColor = [UIColor darkGrayColor];
	networklabel.backgroundColor = [UIColor clearColor];
	networklabel.text = NSLocalizedString(@"network error", @"network error");
	[self.view addSubview:networklabel];
}

/**
 네트워크 에러해제
 */
- (void)NOshowNetworkError {
	
	if ([networklabel superview]) {
		[networklabel removeFromSuperview];
	}
}

/**
 *기기 높이 설정하기
 */
-(void) setDeviceHeight{
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    deviceHeight = floor(screenSize.height);
    
    NSLog(@"%d",deviceHeight);
    
}

@end
