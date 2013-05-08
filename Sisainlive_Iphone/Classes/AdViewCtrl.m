//
//  AdViewCtrl.m
//  Sisainlive
//
//  Created by snow leopard on 11. 1. 19..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AdViewCtrl.h"
#import "Constants.h"

@implementation AdViewCtrl


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setAdView{


	/*******************************************************
	 * 발급받은 Application ID를 입력 하시고 확인 하시기 바랍니다. 
	 *******************************************************/
	// T ad 초기화 작업 (initialize:@"ApplicationID", bannerPosition:배너 위치(상, 하) 설정 
	//					applicationTitle:@"App 이름", view:T ad 를 붙일 위치 지정)
	
//	[TadViewController initialize:ADAPPID bannerPosition:BANNER_POSITION_TOP
//				 applicationTitle:ADAPPNAME view:self];
//	
//	
//	// 배너 위치 지정 Y좌표 양수로 입력
//	[TadViewController setBannerPosition:BANNER_POSITION_TOP setPortraitY:0 setLandscapeY:0];
//	
//	// 배너의 자동 회전 기능 사용 여부 설정
//	[TadViewController enableAutoRotation:NO];
	

}


- (void)setOrView:(BOOL)Flg{
	
//	if (Flg) {
//		[TadViewController enableAutoRotation:YES];
//	}else {
//		[TadViewController enableAutoRotation:NO];
//	}

	




}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
