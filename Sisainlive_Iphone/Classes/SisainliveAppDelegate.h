//
//  SisainliveAppDelegate.h
//  Sisainlive
//
//  Created by snow leopard on 10. 8. 24..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookMarkListContent.h"
#import "FacebookClass.h"
#import "AdViewCtrl.h"

@interface SisainliveAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	
	NSString *OrientationFlg;
	
	NSMutableArray		*bookmarkIndex;
	NSMutableDictionary *bookmarkList;
	
	BOOL bookmarkFlag;
	
	NSString *mailviewFlg;
	
	NSString *me2dayid;
	NSString *me2daypwd;
	
	NSString *twitterusername;
	
	
	
	FacebookClass *facebook;

	BOOL redownloadflg;
	
	AdViewCtrl		*adview;
	
}
@property (nonatomic, retain) FacebookClass *facebook;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSString *OrientationFlg;
@property (nonatomic, retain) NSString *mailviewFlg;
@property (nonatomic, retain) NSString *me2dayid;
@property (nonatomic, retain) NSString *me2daypwd;
@property (nonatomic, retain) NSString *twitterusername;
@property (nonatomic, retain) NSMutableArray *bookmarkIndex;
@property (nonatomic, retain) NSMutableDictionary *bookmarkList;
@property (nonatomic, assign) BOOL bookmarkFlag;
@property (nonatomic, assign) BOOL redownloadflg;
@property (nonatomic, retain) AdViewCtrl *adview;

- (void)getBookmarkList;
- (BOOL)checkBookmark:(NSString *)pid;
- (void)insertBookmark:(BookMarkListContent *)List;
- (void)deleteBookmark:(NSString *)pid;
- (NSInteger)checkNetworkStatus;
- (void)showNetworkError;
- (NSString *) platform;

@end
