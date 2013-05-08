//
//  BookMarkListContent.h
//  sisain
//
//  Created by snow leopard on 10. 8. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BookMarkListContent : NSObject {
	@private

	NSString *idnum;
	NSString *title;
	NSString *content;
	NSString *permalink;
	NSString *description;
	NSString *image;

}
@property (nonatomic, copy) NSString *idnum;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *permalink;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *image;

@end
