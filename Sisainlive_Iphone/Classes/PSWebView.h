// Created by Satoshi Nakagawa.
// You can redistribute it and/or modify it under the new BSD license.

#import <UIKit/UIKit.h>

@protocol PSWebViewDelegate <NSObject>

- (void)ArticleCountUP;

- (void)ArticleCountDown;

@optional


@end


@interface PSWebView : UIWebView{
	
    id <PSWebViewDelegate> delegate;
	BOOL hookInstalled;

}
@property (nonatomic, assign) id <PSWebViewDelegate> delegate;

- (void)installHook;
- (void)uninstallHook;
@end

