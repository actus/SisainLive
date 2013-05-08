//
//  me2dayClass.m
//  me2dayLib
//
//  Created by snow leopard on 10. 10. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "me2dayClass.h"
#import "me2dayLoginContent.h"
#import "me2daySendMsgParser.h"


typedef enum {
	loginAlertView = 1,
	infoErrorAlertView,
	messageAlertView,
	limitAlertView,
	loginsuccessed
} alertViewMode;

@interface me2dayClass()

- (void)showLoginAlertView:(BOOL)flag;
- (void)setUsername:(NSString *)newUsername password:(NSString *)newPassword;
- (void)requestSucceed;
- (void)showMessageAlertView;
- (void)sendMessageAction;
- (void)msgrequestSucceeded;
- (void)showAlertView:(NSString *)aMessage;

@end

@implementation me2dayClass

@synthesize delegate;
@synthesize title;
@synthesize tag;
@synthesize link;
@synthesize apikey;
@synthesize md5key;
@synthesize loginParser;
@synthesize msgSendParser;


/**
 TEST
 */
- (void)dealloc {
	[title release];
	[tag   release];
	[link  release];
	[apikey  release];
	[md5key  release];
	[loginParser release];
	[loginContentArray release];
	[msgSendParser release];
	[sendMsgContentArray release];
    [super dealloc];
}

- (void)login{
	[self showLoginAlertView:YES];
}

- (void)logout{
	NSUserDefaults *me2dayContent = [NSUserDefaults standardUserDefaults];
	[me2dayContent setObject:@"" forKey:@"me2dayId"];
	[me2dayContent setObject:@"" forKey:@"me2dayPwd"];
	
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(me2dayLogoutIsSuccessed)]) {
		[self.delegate me2dayLogoutIsSuccessed];
	}
	msgSendBtnFlg = NO;
}

- (void)setLinkTitle:(NSString *)aTitle atLink:(NSString *)aLink{

	NSString *text;
	
	if ([aTitle length] > 0 && [aLink length] > 0) {
		text = [NSString stringWithFormat:@"「\"%@\":%@ 」",aTitle,aLink];
	}else if ([aTitle length] > 0 && [aLink length] <= 0) {
		text = [NSString stringWithFormat:@"「%@」",aTitle];
	}else if ([aTitle length] <= 0 && [aLink length] > 0) {
		text = [NSString stringWithFormat:@"「\"%@\":%@ 」",aTitle,aLink];
	}

	if ([aTitle length] <= 0 && [aLink length] <= 0) {
		message = [[NSMutableString alloc] initWithString:@""];
	}
	else {
		message = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@\n ", text]];
	}
}


- (void)sendMessage{

	NSUserDefaults *me2dayContent = [NSUserDefaults standardUserDefaults];
	NSString *me2Id  =  [me2dayContent stringForKey:@"me2dayId"];
	NSString *me2Pwd =  [me2dayContent stringForKey:@"me2dayPwd"];

	if ([me2Id length] <= 0 || [me2Pwd length] <=0 ) {
		[self showLoginAlertView:YES];
		msgSendBtnFlg = YES;
	}
	else {
		[self showMessageAlertView];
	}
}

- (void)showLoginAlertView:(BOOL)flag {

	NSUserDefaults *me2dayContent = [NSUserDefaults standardUserDefaults];
	NSString *me2Id  =  [me2dayContent stringForKey:@"me2dayId"];
	
	NSString *titleBuf;
	
	if (flag)
		titleBuf = [NSString stringWithFormat:@"%@ %@\n\n\n\n\n", NSLocalizedString(@"미투데이", @"미투데이"), NSLocalizedString(@"로그인", @"로그인")];
	else
		titleBuf = [NSString stringWithFormat:@"%@ %@\n\n\n\n\n", NSLocalizedString(@"미투데이", @"미투데이"), NSLocalizedString(@"로그인 실패", @"로그인 실패")];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleBuf
													message:nil
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"취소", @"취소")
										  otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
	
	alert.tag = loginAlertView;
	
	idTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
	[idTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[idTextField setBackgroundColor:[UIColor clearColor]];
	[idTextField setPlaceholder:NSLocalizedString(@"ID", @"ID")];
	[idTextField setBorderStyle:UITextBorderStyleRoundedRect];
	idTextField.text = me2Id;
	[alert addSubview:idTextField];
	[idTextField release];
	
	pwTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 80.0, 245.0, 25.0)];
	[pwTextField setSecureTextEntry:YES];
	[pwTextField setBackgroundColor:[UIColor clearColor]];
	[pwTextField setPlaceholder:NSLocalizedString(@"Api사용자키", @"Api사용자키")];
	[pwTextField setBorderStyle:UITextBorderStyleRoundedRect];
	[alert addSubview:pwTextField];
	[pwTextField release];
	
	userkeyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 105.0f, 245.0, 30.0f)];
	userkeyLabel.textAlignment = UITextAlignmentLeft;
	userkeyLabel.backgroundColor = [UIColor clearColor];
	userkeyLabel.textColor = [UIColor whiteColor];
	userkeyLabel.text = NSLocalizedString(@"미투데이 환경설정 > 외부연동 > api사용자키", @"미투데이 환경설정 > 외부연동 > api사용자키");
	userkeyLabel.font = [UIFont boldSystemFontOfSize:12];
	[alert addSubview:userkeyLabel];
	[userkeyLabel release];
	
	
	// iOS 버전에 따라 UI가 다름
	UIDevice *device = [UIDevice currentDevice];
	
	if ([device.systemVersion doubleValue] <= 3.2) {
		[alert setTransform:CGAffineTransformMakeTranslation(0.0, 100 )];
	}
	else {
		[alert setTransform:CGAffineTransformMakeTranslation(0.0, -20 )];
	}
	
	[alert show];
	[alert release];
	
	[idTextField becomeFirstResponder];
	
}

# pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	if(buttonIndex == 1){
		switch (alertView.tag) {
			case loginAlertView:
				[self setUsername:idTextField.text password:pwTextField.text];
				break;
			case messageAlertView:
				[self sendMessageAction];
				break;

			default:
				break;
		}
	}
	else if(buttonIndex == 0){
		switch (alertView.tag) {
			case messageAlertView:
				if (self.delegate != nil && [self.delegate respondsToSelector:@selector(me2daySendMsgIsCancled)]) {
					[self.delegate me2daySendMsgIsCancled];
				}
				break;	
				
			case limitAlertView:
				[self showMessageAlertView];
				break;
			case loginAlertView:
				if (self.delegate != nil && [self.delegate respondsToSelector:@selector(me2dayLoginCancled)]) {
					[self.delegate me2dayLoginCancled];
				}
				break;
				
			default:
				break;
		}
	}
}
	
// Login Start
- (void)setUsername:(NSString *)newUsername password:(NSString *)newPassword{
	NSUserDefaults *me2dayContent = [NSUserDefaults standardUserDefaults];
	if ([newUsername length] <= 0 || [newPassword length] <= 0) {
		if ([newUsername length] > 0) {
			[me2dayContent setObject:newUsername forKey:@"me2dayId"];
		}
		[self showLoginAlertView:NO];
	}
	else {
		NSString *me2day_apikey  =  [me2dayContent stringForKey:@"setApikey"];
		NSString *me2day_md5key  =  [me2dayContent stringForKey:@"setMd5key"];
		
		[me2dayContent setObject:newUsername forKey:@"me2dayId"];
		[me2dayContent setObject:newPassword forKey:@"me2dayPwd"];
		if ([me2day_apikey length] <= 0) {
			[me2dayContent setObject:apikey forKey:@"setApikey"];
		}
		if ([me2day_md5key length] <= 0) {
			[me2dayContent setObject:md5key forKey:@"setMd5key"];			
		}
		loginContentArray = [[NSMutableArray alloc] initWithCapacity:0];
		self.loginParser = [[[me2dayLoginCheckParser alloc] init] autorelease];
		loginParser.delegate = self;
		
		[loginParser loginCheckStart];
		
	}
}

- (void)parser:(id)parser didParseContents:(NSArray *)parsedContents {
	
	[loginContentArray addObjectsFromArray:parsedContents];
	me2dayLoginContent *content = [loginContentArray objectAtIndex:0];
	

	if ([content.code isEqualToString:@"0"]) {
		[self requestSucceed];
	}
}

// 로그인 성공
- (void)requestSucceed{

	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(me2dayLoginIsSuccessed)]) {
		[self.delegate me2dayLoginIsSuccessed];
	}else {
		[self sendMessage];		
	}
}

// 로그인 실패
- (void)requestFailed{
	NSUserDefaults *me2dayContent = [NSUserDefaults standardUserDefaults];
	[me2dayContent setObject:@"" forKey:@"me2dayPwd"];
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(me2dayLoginIsFaild)]) {
		[self.delegate me2dayLoginIsFaild];
	}
	
}


- (void)showMessageAlertView {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n", NSLocalizedString(@"메세지 보내기", @"메세지 보내기")]
													message:nil
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"취소", @"취소")
										  otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
	alert.tag = messageAlertView;
	
	titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(15.0f, 35.0f, 255.0f, 40.0f)];
	[titleTextView setEditable:NO];
	[titleTextView setBackgroundColor:[UIColor clearColor]];
	[titleTextView setTextColor:[UIColor whiteColor]];
	[titleTextView setText:title];
	[alert addSubview:titleTextView];
	[titleTextView release];
	
	msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(15.0f, 65.0f, 255.0f, 60.0f)];
	msgTextView.delegate = self;
	[msgTextView setBackgroundColor:[UIColor whiteColor]];
	[msgTextView setFont:[UIFont systemFontOfSize:14]];
	msgTextView.text = message;
	[alert addSubview:msgTextView];
	[msgTextView release];
	
	limitLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0f, 125.0f, 70.0f, 18.0f)];
	limitLabel.textAlignment = UITextAlignmentRight;
	limitLabel.backgroundColor = [UIColor clearColor];
	limitLabel.textColor = [UIColor whiteColor];
	limitLabel.text = [NSString stringWithFormat:@"%d%@", 140 - [msgTextView.text length], NSLocalizedString(@"자", @"자")];
	[alert addSubview:limitLabel];
	[limitLabel release];
	
	
	// iOS 버전에 따라 UI가 다름
	UIDevice *device = [UIDevice currentDevice];
	
	if ([device.systemVersion doubleValue] <= 3.2) {
		CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 90.0);
		[alert setTransform: moveUp];
	}
	
	[alert show];
	[alert release];
	
	[msgTextView becomeFirstResponder];
	
}

#pragma mark textView delegate

- (void)textViewDidChange:(UITextView *)textView {
	if (limitLabel) {
		limitLabel.text = [NSString stringWithFormat:@"%d%@", 140 - [msgTextView.text length], NSLocalizedString(@"자", @"자")];
	}
}

- (void)sendMessageAction{
	
	[message setString:msgTextView.text];
	if ([message length] > 140 || [message length] <= 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"메세지를 확인해주세요", @"메세지를 확인해주세요")
														message:nil
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
		
		alert.tag = limitAlertView;
		[alert show];
		[alert release];
	}else {
		
		sendMsgContentArray = [[NSMutableArray alloc] initWithCapacity:0];
		self.msgSendParser = [[[me2daySendMsgParser alloc] init] autorelease];
		msgSendParser.delegate = self;
		
		[msgSendParser sendMessage:message atTag:tag];
	}

}


#pragma mark ArticleParser delegate
- (void)msgparser:(id)parser didParseContents:(NSArray *)parsedContents {
	
	[sendMsgContentArray addObjectsFromArray:parsedContents];
	me2dayMsgContent *content = [sendMsgContentArray objectAtIndex:0];
	
	if ([content.body length] > 0 ) {
		[self msgrequestSucceeded];
	}
}

- (void)msgrequestFailed{
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(me2daySendMsgIsFaild)]) {
		[self.delegate me2daySendMsgIsFaild];
	}else {
		[self showAlertView:NSLocalizedString(@"메세지 전송 실패",@"메세지 전송 실패")];		
	}
}

- (void)msgrequestSucceeded{
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(me2daySendMsgIsSuccessed)]) {
		[self.delegate me2daySendMsgIsSuccessed];
	}else {
		[self showAlertView:NSLocalizedString(@"메세지 전송 완료",@"메세지 전송 완료")];		
	}
}


#pragma mark shot alertView

- (void)showAlertView:(NSString *)aMessage {
	
	
	UIAlertView *resAlert = [[UIAlertView alloc] initWithTitle:nil
													   message:aMessage
													  delegate:self
											 cancelButtonTitle:NSLocalizedString(@"확인", @"확인")
											 otherButtonTitles:nil ];
	[resAlert show];
	[resAlert release];
}


@end
