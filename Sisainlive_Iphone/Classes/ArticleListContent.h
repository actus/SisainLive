//
//  ArticleListContent.h
//  sisain
//
//  Created by snow leopard on 10. 8. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 기사리스트 보기 변수
 */
@interface ArticleListContent : NSObject {
@private

	NSString *title;
	NSString *description;
	NSString *Limage;
	NSString *image;	
	NSString *link_id;
	NSString *link;
	NSString *pubDate;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *Limage;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *link_id;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *pubDate;
@end
