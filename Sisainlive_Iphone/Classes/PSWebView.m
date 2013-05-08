// Created by Satoshi Nakagawa.
// You can redistribute it and/or modify it under the new BSD license.

#import <objc/runtime.h>
#import "PSWebView.h"

@interface PSWebView (Private)
- (void)ListArticleUp;
- (void)ListArticleDown;
@end



@implementation UIView (__TapHook)

- (void)__touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
//	UITouch *touch = [touches anyObject];
//  CGPoint currentPosition = [touch locationInView:self];
}

@end

@implementation PSWebView
@synthesize delegate;

//static BOOL hookInstalled = NO;

//static void installHook()
- (void)installHook
{
	if (hookInstalled) return;
	
	hookInstalled = YES;

	Class klass1 = objc_getClass("UIWebDocumentView");
	
	Method MovetargetMethod = class_getInstanceMethod(klass1, @selector(touchesMoved:withEvent:));
	Method MovenewMethod = class_getInstanceMethod(klass1, @selector(__touchesMoved:withEvent:));
	method_exchangeImplementations(MovetargetMethod, MovenewMethod);
}

- (void)uninstallHook {
	if (!hookInstalled) return;
	
	hookInstalled = NO;
	
	
	Class klass1 = objc_getClass("UIWebDocumentView");
	
	Method MovetargetMethod = class_getInstanceMethod(klass1, @selector(touchesMoved:withEvent:));
	Method MovenewMethod = class_getInstanceMethod(klass1, @selector(__touchesMoved:withEvent:));
	method_exchangeImplementations(MovenewMethod, MovetargetMethod);
	
}

- (void)dealloc {
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		hookInstalled = NO;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

	
}
- (void)ListArticleUp{
	[delegate ArticleCountUP];
}

- (void)ListArticleDown{
	[delegate ArticleCountDown];
}

@end
