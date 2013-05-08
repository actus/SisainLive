//
//  ArticleListCustomCell.h
//  sisain
//
//  Created by snow leopard on 10. 8. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 기사리스트 테이블 커스텀 뷰
 */
@interface ArticleListCustomCell : UITableViewCell {
	BOOL myImageFlag;
	
	UIImageView	*myImageView;
	UILabel		*myTextLabel;
	UILabel		*myDetailTextLabel;

	BOOL threadFlag;
	UIActivityIndicatorView *spin;
	
	BOOL adViewFlg;
	
	NSInteger adViewIndexPath;
	
	
}
@property (nonatomic, retain) UIImageView *myImageView;
@property (nonatomic, retain) UILabel *myTextLabel;
@property (nonatomic, retain) UILabel *myDetailTextLabel;
@property (nonatomic, assign) BOOL myImageFlag;
@property (nonatomic, assign) NSInteger adViewIndexPath;



- (void)setupMode:(BOOL)imgView;
- (void)setupThumbNail:(NSString *)url;

- (void)setupADView:(NSInteger)indexPath;



@end
