//
//  BaseTableViewCtrl.h
//  sisain
//
//  Created by Jupiter on 10. 8. 3..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SisainliveAppDelegate.h"
#import "Constants.h"

/**
 기본 테이블베이스 뷰
 */
@interface BaseTableViewCtrl : UITableViewController <UIWebViewDelegate> {
	SisainliveAppDelegate	*appDelegate;
}
- (void)setupBarButtons:(UINavigationItem *)navigationIem buttonFlag:(NSInteger)buttonFlag;

@end
