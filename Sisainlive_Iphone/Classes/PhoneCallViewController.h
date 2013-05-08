//
//  PhoneCallViewController.h
//  Sisainlive
//
//  Created by snow leopard on 10. 9. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewCtrl.h"
#import "SisainliveAppDelegate.h"


@interface PhoneCallViewController : BaseViewCtrl<UIWebViewDelegate> {
	IBOutlet UIWebView		*myWebView;
	SisainliveAppDelegate *appDelegate;
}

@end
