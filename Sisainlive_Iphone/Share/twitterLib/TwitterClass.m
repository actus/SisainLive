//
//  TwitterClass.m
//  TastyBlog
//
//  Created by SUNGMAN LEE on 3/18/10.
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import "TwitterClass.h"
#import "SA_OAuthTwitterEngine.h"

typedef enum {
	loginAlertView = 1,
	infoErrorAlertView,
	messageAlertView,
	limitAlertView
} alertViewMode;


@implementation TwitterClass

@synthesize delegate,_engine;
@synthesize ConsumerKey;
@synthesize ConsumerSecret;
@synthesize title,url;


- (void)dealloc {
	[message release];
	[ConsumerKey release];
	[ConsumerSecret release];
	[title release];
	[url release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)start {
	
	showMesFlg = YES;
	
	if ([title length] > 0 && [url length] > 0) {
		message = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"「%@」\n%@\n", title, url]];
	}else if ([title length] > 0 && [url length] <= 0) {
		message = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"「%@」\n", title]];
	}else if ([title length] <= 0 && [url length] > 0) {
		message = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@\n", url]];
	}else {
		message = [[NSMutableString alloc] initWithString:@""];
	}

	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
		
	if (controller) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(showTwitterViewCtrl:)]) {
			[self.delegate showTwitterViewCtrl:controller];
		}
	}else {
		[self showMessageAlertView];
	}
}

- (void)initWithViewCtrl{

	if (_engine == nil) {
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey = ConsumerKey;
		_engine.consumerSecret = ConsumerSecret;
	}
}


# pragma mark showAlertView

- (void)showMessageAlertView {
	msgAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n", NSLocalizedString(@"메세지 보내기", @"메세지 보내기")]
										  message:nil
										 delegate:self
								cancelButtonTitle:NSLocalizedString(@"취소", @"취소")
								otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
	
	msgAlert.tag = messageAlertView;
	
	titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(15.0f, 35.0f, 255.0f, 40.0f)];
	[titleTextView setEditable:NO];
	[titleTextView setBackgroundColor:[UIColor clearColor]];
	[titleTextView setTextColor:[UIColor whiteColor]];
	[titleTextView setText:title];
	[msgAlert addSubview:titleTextView];
	[titleTextView release];
	
	msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(15.0f, 65.0f, 255.0f, 60.0f)];
	msgTextView.delegate = self;
	[msgTextView setBackgroundColor:[UIColor whiteColor]];
	[msgTextView setFont:[UIFont systemFontOfSize:14]];
	msgTextView.text = message;
	[msgAlert addSubview:msgTextView];
	[msgTextView release];
	
	limitLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0f, 126.0f, 70.0f, 18.0f)];
	limitLabel.textAlignment = UITextAlignmentRight;
	limitLabel.backgroundColor = [UIColor clearColor];
	limitLabel.textColor = [UIColor whiteColor];
	limitLabel.text = [NSString stringWithFormat:@"%d%@", 140 - [msgTextView.text length], NSLocalizedString(@"자", @"자")];
	[msgAlert addSubview:limitLabel];
	[limitLabel release];
	
	[msgAlert show];
	[msgAlert release];
}



#pragma mark textView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	// iOS 버전에 따라 UI가 다름
	UIDevice *device = [UIDevice currentDevice];
	
	if ([device.systemVersion doubleValue] <= 3.2) {
		CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, -110.0);
		[msgAlert setTransform: moveUp];
	}
	
	return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
	if (limitLabel) {
		limitLabel.text = [NSString stringWithFormat:@"%d%@", 140 - [textView.text length], NSLocalizedString(@"자", @"자")];
	}
}


- (void)twitterSendMsg:(NSString *)aMsg {

	[_engine sendUpdate:aMsg];
}



//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
	
	if ([data length] == 0) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(twitterLogOutIsSuccessed)]) {
			[self.delegate twitterLogOutIsSuccessed];
		}
	}
	
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}
//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {

	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(twitterLoginIsSuccessed)]) {
		[self.delegate twitterLoginIsSuccessed];
	}
	
	if (showMesFlg) {
		[self showMessageAlertView];	
	}
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(twitterLoginIsFailed)]) {
		[self.delegate twitterLoginIsFailed];
	}
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {

	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(twitterLoginIsCanceled)]) {
		[self.delegate twitterLoginIsCanceled];
	}
}
//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {

	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(twitterSendMsgIsSuccessed)]) {
		[self.delegate twitterSendMsgIsSuccessed];
	}else {
		[self showAlertView:NSLocalizedString(@"메세지 전송 완료", @"메세지 전송 완료")];		
	}
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(twitterSendMsgIsFaild)]) {
		[self.delegate twitterSendMsgIsFaild];
	}else {
		[self showAlertView:NSLocalizedString(@"메세지 전송 실패", @"메세지 전송 실패")];		
	}
}
//=============================================================================================================================
#pragma mark shot alertView

- (void)showAlertView:(NSString *)aMessage {
	UIAlertView *resAlert = [[UIAlertView alloc] initWithTitle:nil
													   message:aMessage
													  delegate:self
											 cancelButtonTitle:NSLocalizedString(@"확인", @"확인") 
											 otherButtonTitles:nil];
	[resAlert show];
	[resAlert release];
}

# pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		if (alertView.tag == limitAlertView) {
			[self showMessageAlertView];
		}else if (alertView.tag == messageAlertView) {
			if (self.delegate != nil && [self.delegate respondsToSelector:@selector(twitterSendMsgIsCanceled)]) {
				[self.delegate twitterSendMsgIsCanceled];
			}
		}
	}
	else if (buttonIndex == 1) {
		switch (alertView.tag) {
			case messageAlertView:
			{
				if ([msgTextView.text length] > 140) {
					[message setString:msgTextView.text];
					
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"트위터 경고", @"트위터 경고")
																	message:nil
																   delegate:self
														  cancelButtonTitle:nil
														  otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
					
					alert.tag = limitAlertView;
					[alert show];
					[alert release];
				}
				else {
					[self twitterSendMsg:msgTextView.text];
				}
			}
				break;
		}
	}
}

@end
