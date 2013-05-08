//
//  ArticleDetailViewController.h
//  sisain
//
//  Created by snow leopard on 10. 8. 3..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewCtrl.h"
#import "ArticleParser.h"
#import "SisainliveAppDelegate.h"
// mail
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "PSWebView.h"
#import "me2dayClass.h"
//#import "TwitterClass.h"
//#import "kakaotalkClass.h"

@interface ArticleDetailViewController : BaseViewCtrl<PSWebViewDelegate,
														UIWebViewDelegate,
														UIActionSheetDelegate,
														ArticleParserDelegate,
														MFMailComposeViewControllerDelegate,
                                                        me2dayClassDelegate>{
//,
//														TwitterClassDelegate> {
	
	NSString          *idnumber;
	NSString	      *ViewFlg;
	NSMutableArray	  *contentArray;
	NSMutableArray	  *ListDataArray;
	NSMutableArray	  *CountDataArray;

	ArticleParser	  *contentParser;
	
	NSInteger         row;
	NSString		  *bitlyURL;

	PSWebView         *web;
															
	NSInteger	      kingofShare;
	
	me2dayClass       *me2day;
//	TwitterClass      *twitter;
//	kakaotalkClass    *kakaotalk;
															
				
	BOOL			  contentSendFlg;
															
}
@property (nonatomic, assign) BOOL           contentSendFlg;
@property (nonatomic, retain) NSString           *idnumber;
@property (nonatomic, retain) NSString           *ViewFlg;
@property (nonatomic)		  NSInteger          row;
@property (nonatomic, retain) NSMutableArray     *contentArray;
@property (nonatomic, retain) NSMutableArray     *ListDataArray;
@property (nonatomic, retain) NSMutableArray     *CountDataArray;
@property (nonatomic, retain) ArticleParser      *contentParser;






@end
