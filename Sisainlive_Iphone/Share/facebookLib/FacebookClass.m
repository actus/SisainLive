//
//  FacebookClass.m
//  Sisainlive
//
//  Created by snow leopard on 10. 11. 30..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookClass.h"
#import "FBConnect.h"
///////////////////////////////////////////////////////////////////////////////////////////////////
// This application will not work until you enter your Facebook application's API key here:

// Enter either your API secret or a callback URL (as described in documentation):
//static NSString* kGetSessionProxy = nil; // @"<YOUR SESSION CALLBACK)>";


@interface FacebookClass ()

- (void)publishFeed:(id)target;

@end

/**
 페이스북 클래스
 */

@implementation FacebookClass
@synthesize delegate;
@synthesize _session;
@synthesize titleExplain;
@synthesize description;
@synthesize kApiKey;
@synthesize kApiSecret;

- (void)facebookStart{
	
	viewFlg = YES;
	_session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBSessionDelegate
- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	
	NSString* fql = [NSString stringWithFormat:
					 @"select uid,name from user where uid == %lld", session.uid];
	
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}

- (void)sessionDidNotLogin:(FBSession*)session {

	
}

- (void)sessionDidLogout:(FBSession*)session {
		[self usercertificationStatus:@"3"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

- (void)request:(FBRequest*)request didLoad:(id)result {

	if ([request.method isEqualToString:@"facebook.fql.query"]) {

		if (viewFlg) {
			[self usercertificationStatus:@"1"];
		}else {
			viewFlg = YES;
			[self publishFeed:nil];
		}
	}
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {

	if (viewFlg) {
		[self facebookLogin];
	}
	
}

- (void)usercertificationStatus:(NSString *)index{

	[[NSNotificationCenter defaultCenter] postNotificationName:@"usercertificationStatus" object:index];
	
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)publishFeed:(id)target {
	FBStreamDialog* dialog = [[[FBStreamDialog alloc] init] autorelease];
	dialog.delegate = self;
	NSString * subTitle = [NSString stringWithFormat:@"%@",title];
	dialog.userMessagePrompt = titleExplain;
	NSString *uploadString = [NSString stringWithFormat:@"{\"name\":\"%@\",\"href\":\"%@\",\"description\":\"%@\",\"media\":[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@/\"}],}",subTitle,linkUrl,description,imgUrl,imgUrl];
	dialog.attachment = uploadString;
	// replace this with a friend's UID
	// dialog.targetId = @"999999";
	[dialog show];
}

- (void)dealloc {
	[_session release];
	[titleExplain release];
	[title release];
	[linkUrl release];
	[imgUrl release];
	[description release];
	[kApiKey release];
	[kApiSecret release];
	[super dealloc];
}

- (void)facebookLogOut{
	[_session logout];
}

- (void)facebookLogin{
	FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:_session] autorelease];
	[dialog show];
}


- (void)sendMsg:(NSString *)Uptitle atTo:(NSString *)UpimgUrl atTo:(NSString *)UpbitlyURL{
	title = Uptitle;
	imgUrl = UpimgUrl;
	linkUrl = UpbitlyURL;

	if (_session.isConnected) {
		[self publishFeed:nil];
	} else {
		viewFlg = NO;
		[self facebookLogin];
	}
}

@end
