//
//  Article.h
//  sisain
//
//  Created by snow leopard on 10. 7. 27..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 기사변수 설정 클래스
 */
@interface Article : NSObject {
@private
	NSString *idnum;
	NSString *category_id;
	NSString *permalink;
	NSString *title;
	NSString *content;
	NSString *description;
	NSString *image;
}

@property (nonatomic, copy) NSString *idnum;
@property (nonatomic, copy) NSString *category_id;
@property (nonatomic, copy) NSString *permalink;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *image;

@end
