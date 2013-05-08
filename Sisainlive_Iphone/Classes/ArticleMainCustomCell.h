//
//  ArticleMainCustomCell.h
//  Sisainlive
//
//  Created by snow leopard on 10. 8. 26..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 기사리스트 메인 테이블 커스텀 뷰
 */
@interface ArticleMainCustomCell : UITableViewCell {

	BOOL myImageFlag;
	
	UIImageView	*myImageView;
	UILabel		*myTextLabel;
	
	BOOL threadFlag;
	UIActivityIndicatorView *spin;
}
@property (nonatomic, retain) UIImageView *myImageView;
@property (nonatomic, retain) UILabel *myTextLabel;
@property (nonatomic, assign) BOOL myImageFlag;



- (void)setupMode:(BOOL)imgView;
- (void)setupThumbNail:(NSString *)url;

@end
