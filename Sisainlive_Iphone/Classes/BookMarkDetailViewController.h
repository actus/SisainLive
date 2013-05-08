//
//  BookMarkDetailViewController.h
//  sisain
//
//  Created by snow leopard on 10. 8. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewCtrl.h"
#import "PSWebView.h"

// mail
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BookMarkDetailViewController : BaseViewCtrl <UIActionSheetDelegate,PSWebViewDelegate,MFMailComposeViewControllerDelegate>{

	NSString               *title;
	NSString			   *permalink;
	NSString			   *content;
	PSWebView  *web;
	
	NSMutableDictionary    *DetailList;
	NSMutableArray		   *DetailIndex;
	
	NSInteger row;
}
@property (nonatomic, retain) NSString           *title;
@property (nonatomic, retain) NSString           *content;
@property (nonatomic, retain) NSString           *permalink;
@property (nonatomic)		  NSInteger          row;
@property (nonatomic, retain) NSMutableDictionary *DetailList;
@property (nonatomic, retain) NSMutableArray      *DetailIndex;


@end
