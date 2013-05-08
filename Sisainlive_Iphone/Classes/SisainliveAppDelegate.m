//
//  SisainliveAppDelegate.m
//  Sisainlive
//
//  Created by snow leopard on 10. 8. 24..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SisainliveAppDelegate.h"
#import "BookmarkListViewController.h"
#import "Constants.h"
//#import "FlurryAPI.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation SisainliveAppDelegate
@synthesize window;
@synthesize tabBarController;
@synthesize OrientationFlg;
@synthesize mailviewFlg;
@synthesize me2dayid;
@synthesize me2daypwd;
@synthesize facebook;
@synthesize twitterusername;
@synthesize bookmarkList;
@synthesize bookmarkIndex,bookmarkFlag,redownloadflg;
@synthesize adview;


#pragma mark Device Version
- (NSString *) platform  {  
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);  
	
	sysctlbyname("hw.machine", machine, &size, NULL, 0);  
	/* 
	 Possible values: 
	 "iPhone1,1" = iPhone 1G 
	 "iPhone1,2" = iPhone 3G 
	 "iPhone2,1" = iPhone 3GS 
	 "iPhone3,1" = iPhone4
	 "iPod1,1"   = iPod touch 1G 
	 "iPod2,1"   = iPod touch 2G 
	 */  
	NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
	free(machine);  
	return platform;
}

#pragma mark -
#pragma mark Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

	
    // FlurryAPI
    //[FlurryAPI startSession:@"12K3NYCV257W5IUBNLWC"];

    // Override point for customization after application launch.

    // Add the tab bar controller's view to the window and display.
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];

	facebook = [[FacebookClass alloc]init];
	[facebook setKApiKey:@"eaeff8a4e1d6f8e7064dada5a035c4e1"];
	[facebook setKApiSecret:@"f07252913a6e7ce365ad713cf56adb12"];
	[facebook facebookStart];
	
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	
	adview = [[AdViewCtrl alloc] init];
	
	adview.frame = CGRectMake(0.0f, 320, 320.0f, 48.0f);
	
	[adview setAdView];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	[NSUserDefaults resetStandardUserDefaults];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (bookmarkIndex){
		[defaults setObject:bookmarkIndex forKey:defaults_bookmarkIndex];
	}
	
	if (bookmarkList){
		[defaults setObject:bookmarkList forKey:defaults_bookmarkList];
	}

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[NSUserDefaults resetStandardUserDefaults];
	
	 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	 
	 if (bookmarkIndex){
		 [defaults setObject:bookmarkIndex forKey:defaults_bookmarkIndex];
	 }
	 
	 if (bookmarkList){
		 [defaults setObject:bookmarkList forKey:defaults_bookmarkList];
	 }
	
}
#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[facebook release];
    [tabBarController release];
    [window release];
	[OrientationFlg release];
	[mailviewFlg release];
	[me2dayid release];
	[me2daypwd release];
	[twitterusername release];
	[adview release]; 
    [super dealloc];
}


#pragma mark check current NetworkStatus

- (NSInteger)checkNetworkStatus {
	
	NSInteger stauts = 0;
	Reachability2 *internetReach = [Reachability2 reachabilityForInternetConnection];
	NetworkStatus networkStatus = [internetReach currentReachabilityStatus];
	
	if (networkStatus == ReachableViaWiFi)
		stauts = network_wifi;
	else if (networkStatus == ReachableViaWWAN)
		stauts = network_3g;
	else if (networkStatus == NotReachable)
		stauts = 0;
	
	return stauts;
	
}



#pragma mark show alertView

- (void)showNetworkError {
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 60.0f)];
	label.center = window.center;
	label.numberOfLines = 0;
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor darkGrayColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = NSLocalizedString(@"network error", @"network error");
	[window addSubview:label];
	[label release];
	
}


#pragma mark bookmark methods

- (void)getBookmarkList {
	
	bookmarkIndex = nil;
	bookmarkList = nil;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	bookmarkIndex	= [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:defaults_bookmarkIndex]];
	bookmarkList	= [[NSMutableDictionary alloc] initWithDictionary:[defaults dictionaryForKey:defaults_bookmarkList]];

	bookmarkFlag = YES;
}


- (BOOL)checkBookmark:(NSString *)pid{
	BOOL result = NO;
	if ([bookmarkIndex indexOfObject:pid] != NSNotFound)
		result = YES;
	
	return result;
}


- (void)insertBookmark:(BookMarkListContent *)List{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if ([bookmarkIndex indexOfObject:List.idnum] == NSNotFound) {
		[bookmarkIndex addObject:List.idnum];
		[defaults setObject:bookmarkIndex forKey:defaults_bookmarkIndex];
		
		NSDictionary *postDic = [NSDictionary dictionaryWithObjectsAndKeys:List.idnum,book_idnum,List.title,book_title,List.description,book_description,List.content,book_content,List.image,book_image,nil];
		[bookmarkList setObject:postDic forKey:List.idnum];
		[defaults setObject:bookmarkList forKey:defaults_bookmarkList];
	
	}
	bookmarkFlag = YES;
}

- (void)deleteBookmark:(NSString *)idnum{
	
	[bookmarkIndex removeObject:idnum];
	[bookmarkList removeObjectForKey:idnum];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:bookmarkIndex forKey:defaults_bookmarkIndex];
	[defaults setObject:bookmarkList forKey:defaults_bookmarkList];
	
	bookmarkFlag = YES;
}


@end

