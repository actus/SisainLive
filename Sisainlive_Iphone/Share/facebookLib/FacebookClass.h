//
//  FacebookClass.h
//  Sisainlive
//
//  Created by snow leopard on 10. 11. 30..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@protocol FacebookClassDelegate <NSObject>
@optional

- (void)facebookLoginStatus;

@end

@class FBSession;


/**
 페이스북 클래스
 */


@interface FacebookClass : NSObject<FBDialogDelegate, FBSessionDelegate, FBRequestDelegate> {

	FBSession* _session;
	
	NSString *titleExplain;
	NSString *description;
	NSString *title;
	NSString *linkUrl;
	NSString *imgUrl;
	
	NSString *kApiKey;
	NSString *kApiSecret;
	
	id <FacebookClassDelegate> delegate;
	BOOL viewFlg;
	
}
@property (nonatomic, assign) id <FacebookClassDelegate> delegate;
@property (nonatomic, retain) FBSession* _session;
@property (nonatomic, retain) NSString *titleExplain;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *kApiKey;
@property (nonatomic, retain) NSString *kApiSecret;


- (void)sendMsg:(NSString *)title atTo:(NSString *)imgUrl atTo:(NSString *)bitlyURL;
- (void)facebookStart;
- (void)facebookLogin;
- (void)facebookLogOut;
- (void)usercertificationStatus:(NSString *)index;
@end
