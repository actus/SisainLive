//
//  kakaotalkClass.m
//  Sisainlive
//
//  Created by snow leopard on 11/03/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "kakaotalkClass.h"
#import "Constants.h"
#import "GTMNSDictionary+URLArguments.h"

typedef enum {
	messageAlertView= 1,
	limitAlertView,
	noInstalled
	
} alertViewMode;

NSString *const KakaoConnectScheme = KAKAOLINK;
NSString *const KakaoConnectMethod = SENDURL;
static NSString *ConnectBaseURL;

NSString *GetConnectBaseURL() {
	
	if (!ConnectBaseURL) {
		ConnectBaseURL = [[NSString alloc] initWithFormat:@"%@://%@", KakaoConnectScheme, KakaoConnectMethod];
	}
	return ConnectBaseURL;
}



NSString *GetConnectURLStringWithParameters(NSDictionary *parameters) {
	return [NSString stringWithFormat:@"%@?%@", GetConnectBaseURL(), [parameters gtm_httpArgumentsString]];
}

@interface kakaotalkClass ()

- (void)showMessageAlertView;
- (void)sendKakaotalkMsg;
- (NSDictionary *)dictionaryFromParameters;
@end



@implementation kakaotalkClass
@synthesize msg,url;
@synthesize delegate;
@dynamic canOpenConnect;



- (void)dealloc {
	[msg   release];
	[url  release];
	[message release];	
    [super dealloc];
}


- (void)sendMessage{

    BOOL isInstalled = [self canOpenConnect];
	
	if (isInstalled) {
		message = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"「%@」\n", msg]];
		
		[self showMessageAlertView];
	}else {
		NSString *errormsg = @"커넥트가 가능한 카카오톡이 설치되어 있지 않습니다.";
		msgAlert = [[UIAlertView alloc] initWithTitle:nil
															message:errormsg
														   delegate:self
												  cancelButtonTitle:@"확인"
												  otherButtonTitles:nil];
		msgAlert.tag = noInstalled;
		[msgAlert show];
		[msgAlert release];
		
	}
}


- (BOOL)canOpenConnect {

	NSURL *appurl = [NSURL URLWithString:GetConnectBaseURL()];
	return [[UIApplication sharedApplication] canOpenURL:appurl];
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
	[titleTextView setText:message];
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

- (void)textViewDidChange:(UITextView *)textView {
	if (limitLabel) {
		limitLabel.text = [NSString stringWithFormat:@"%d%@", 140 - [textView.text length], NSLocalizedString(@"자", @"자")];
	}
}

# pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 0) {
		if (alertView.tag == limitAlertView) {
			[self showMessageAlertView];
		}
		else {
			if (self.delegate != nil && [self.delegate respondsToSelector:@selector(kakaotalkSendMessageEnd)]) {
				[self.delegate kakaotalkSendMessageEnd];
			}								
		}
	}
	else if (buttonIndex == 1) {
		switch (alertView.tag) {
			case messageAlertView:
			{
				if ([msgTextView.text length] > 140) {
					[message setString:msgTextView.text];					
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"카카오톡 경고", @"카카오톡 경고")
																	message:nil
																   delegate:self
														  cancelButtonTitle:nil
														  otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
					
					alert.tag = limitAlertView;
					[alert show];
					[alert release];
				}
				else {
					if (self.delegate != nil && [self.delegate respondsToSelector:@selector(kakaotalkSendMessageEnd)]) {
						[self.delegate kakaotalkSendMessageEnd];
					}					
					[self sendKakaotalkMsg];
				}
			}
			break;
			case noInstalled:
			{
				if (self.delegate != nil && [self.delegate respondsToSelector:@selector(kakaotalkSendMessageEnd)]) {
					[self.delegate kakaotalkSendMessageEnd];
				}		
			}
			break;
		}
	}
}

- (void)sendKakaotalkMsg{

	NSString *urlString = GetConnectURLStringWithParameters([self dictionaryFromParameters]);

    NSURL *urlToLaunch = [NSURL URLWithString:urlString];
	
    [[UIApplication sharedApplication] openURL:urlToLaunch];
}

- (NSDictionary *)dictionaryFromParameters {
	return GetParametersDictionary(APPID, APPVERSION, url, msgTextView.text);
}


NSDictionary *GetParametersDictionary(NSString *appid, NSString *appver, NSString *url, NSString *msg) {

 if (!appid || !appver || !url) { // msg is optional
		@throw [NSException exceptionWithName:@"NullParameterException"
									   reason:@"appid, appver, url cannot be nil"
									 userInfo:nil];
	}
	NSDictionary *parametersDictionary;
	
	if (msg) {
		parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								appid, @"appid",
								appver, @"appver",
								url, @"url",
								msg, @"msg", nil];
	} else {
		parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								appid, @"appid",
								appver, @"appver",
								url, @"url", nil];
	}

	return parametersDictionary;
}


@end
