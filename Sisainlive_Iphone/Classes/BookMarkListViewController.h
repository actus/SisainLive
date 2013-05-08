//
//  BookMarkListViewController.h
//  sisain
//
//  Created by snow leopard on 10. 8. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewCtrl.h"
#import "SisainliveAppDelegate.h"
#import "BookMarkListContent.h"

@interface BookMarkListViewController : BaseViewCtrl<UITableViewDelegate,UITableViewDataSource> {

	SisainliveAppDelegate *appDelegate;
	
	UITableView		      *myTableView;
	
	NSMutableString	      *contentIndex;
	
	NSInteger             networkStatus;
	
	BOOL	              reloadTableView;
}

- (void)setupTableView:(BOOL)getData;

@end
