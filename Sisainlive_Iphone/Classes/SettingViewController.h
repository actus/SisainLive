//
//  SettingViewController.h
//  sisain
//
//  Created by snow leopard on 10. 8. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCtrl.h"
#import "me2dayClass.h"
//#import "SA_OAuthTwitterController.h"

//@class SA_OAuthTwitterEngine;


@protocol SettingViewControllerDelegate <NSObject>


@optional

- (void)reDownload;

@end



@interface SettingViewController : BaseTableViewCtrl<UITextViewDelegate,UIAlertViewDelegate,UITextViewDelegate,me2dayClassDelegate>{
    
    //,SA_OAuthTwitterControllerDelegate>{
	
    id <SettingViewControllerDelegate> delegate;
	
	UITextField	*setidTextField;
	UITextField	*setpwTextField;
	UILabel		*userkeyLabel;
	
	NSArray			*sectionArray;
	NSMutableArray	*snsArray;
	NSArray			*aboutArray;
	NSArray			*reDownloadArray;
	
	
	UITextField	*idTextField;
	UITextField	*pwTextField;
	
	me2dayClass	 *me2day;
	//SA_OAuthTwitterEngine *_engine;

}
@property (nonatomic, assign) id <SettingViewControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray     *contentArray;


- (void)setupArray;

- (void)screenBook;
@end


