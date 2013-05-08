//
//  Tad_iOS_ViewController.h
//  

#import <UIKit/UIKit.h>


#ifndef __TadViewController_Header_Is_Already_Included__
#define __TadViewController_Header_Is_Already_Included__



/**	
 @ingroup	GROUP_AD_USERINTERFACE
*/ 
typedef enum _BANNER_POSITION
{
	BANNER_POSITION_TOP,		// 화면 상단
	BANNER_POSITION_BOTTOM,		// 화면 하단
	BANNER_POSITION_FULL		// 전체 화면
	
} BANNER_POSITION;


@interface TadViewController : UIViewController 
{
}


/**	
 @ingroup	GROUP_AD_USERINTERFACE
 
 @brief		광고 모듈을 초기화하고 자동으로 광고 모듈을 활성화한다.
 
 @param		AD ID				광고 어플리케이션 등록 시 부여받은 ID. ID가 잘못 입력되면 정상적으로 광고가 수신이 안되거나 정산이 이루어지지 않을 수 있음에 주의하여야 한다.
			bannerPosition		광고를 노출하기 위한 기본 띠 배너의 위치(BANNER_POSITION). 화면을 기준으로 위/아래/전면을 지정할 수 있다.
			applicationTitle	광고를 사용하는 어플리케이션의 타이틀.
			view				광고가 노출될 View. 
 
 @return	없음

 @see		adDelegate
			setParentView
 */
+(void)initialize:(NSString *)applicationID bannerPosition:(BANNER_POSITION)position applicationTitle:(NSString *)title view:(UIView*)view; 

/**	
 @ingroup	GROUP_AD_USERINTERFACE
 
 @brief		Application에서 처리하는 자동 회전 여부를 결정한다. 
			기본 값은 NO이며, 설정된 값에 따라 회전 여부를 결정한다. 
			어플리케이션에서 원하는 값으로 설정하지 않을 경우 화면 회전이 의도와 다르게 동작할 수 있음에 주의한다.
 
 @param		없음
 
 @return	없음
 */
+ (void)enableAutoRotation:(BOOL)enable;

/**	
 @ingroup	GROUP_AD_USERINTERFACE
 
 @brief		전면 광고를 호출한다. 전면 광고가 호출되는 동안 동작 중인 이전 배너는 자동으로 일시 정지된다.
 
 @param		없음
 
 @return	없음

 @see		없음
 */
+ (void)showFullBanner;

/**	
 @ingroup	GROUP_AD_USERINTERFACE
 
 @brief		띠배너 광고의 위치를 설정한다.
 
 @param		bannerPosition		광고를 노출하기 위한 기본 띠 배너의 위치(BANNER_POSITION).
			setPortraitY		position을 기준으로 portrait Y좌표 지정(양수)
			setLandscapeY		position을 기준으로 landscape Y좌표 지정(양수)
 
 @return	없음
 
 @see		없음
 */
+(void)setBannerPosition:(BANNER_POSITION)position setPortraitY:(CGFloat)setPortraitY setLandscapeY:(CGFloat)setLandscapeY;

/**	
 @ingroup	GROUP_AD_USERINTERFACE
 
 @brief		광고가 동작할 부모 view의 최상위 view를 설정한다. 
			현재 활성화되어 있는 view가 아닐 경우 광고는 나타나지 않을 수 있다.
 
 @param		view				광고가 노출될 View. 
 
 @return	없음
 
 @see		없음
 */
+ (void)bringToFront:(UIView*)view;

/**	
 @ingroup	GROUP_AD_USERINTERFACE
 
 @brief		Delegate를 호출한다. 전면배너 콜백을 받기 위해서는 반드시 호출되어야 한다.
 
 @param		object		
 
 @return	없음
 
 @see		없음
 */
+ (void)setAdDelegate:(id)object;

/**	
 @ingroup	GROUP_AD_USERINTERFACE
 
 @brief		전면 광고 종료 시 호출된다. 전면광고 노출 후 띠 배너를 설정하고 싶을 경우 콜백이 호출되면 띠 배너 광고를 요청할 수 있다.
 
 @param		
 
 @return	없음
 
 @see		없음
 */

- (void)TadCloseFullBanner:(id)popup;

/**	
 @ingroup	GROUP_AD_USERINTERFACE
 
 @brief		전면 광고 요청 실패 시 호출된다. 전면광고 노출 후 띠 배너를 호출하고 싶을 경우 콜백이 호출되면 띠 배너 광고를 호출할 수 있다.
 
 @param				
 
 @return	없음
 
 @see		없음
 */
- (void)TadFailToFullBanner:(id)popup;




@end

#endif // __TadViewController_Header_Is_Already_Included__