//
//  BaseViewCtrl.h
//  sisain
//
//  Created by snow leopard on 10. 7. 13..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SisainliveAppDelegate.h"
#import "Reachability2.h"
#import "Constants.h"

#define IPHONE_FIVE 568
#define IPHONE_FOUR 480

/**
 기본 베이스 뷰
 */
@interface BaseViewCtrl : UIViewController {
	UILabel *networklabel;
    int deviceHeight;
}

@property (nonatomic,retain)UILabel *networklabel;
- (NSInteger)checkNetworkStatus;
- (void)showNetworkError;
- (void)NOshowNetworkError;

@end
