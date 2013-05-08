//
//  ArticleImageView.h
//  sisain
//
//  Created by Jupiter on 10. 8. 3..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleListContent.h"
@protocol ArticleImageViewDelegate <NSObject>
@optional
- (void)articleImageViewWasTapped:(NSInteger)index;
@end

@interface ArticleImageView : UIImageView {
@private
	NSInteger	index;
	BOOL		dragging;
	NSThread	*thread;
	// 다운로드된 파일들이 저장되는 경로를 지정
	NSString *documentPath;
	UIImage *img;
	UIImage *deleteImage;
	id <ArticleImageViewDelegate> delegate;
}

@property (nonatomic, assign) NSInteger	index;
@property (nonatomic, assign) id <ArticleImageViewDelegate> delegate;

- (void)setupImage:(ArticleListContent *)url;
- (void)removeImage:(NSArray *)contentArray atTO:(NSInteger)indexNo;

@end
