//
//  ArticleImageView.m
//  sisain
//
//  Created by Jupiter on 10. 8. 3..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import "ArticleImageView.h"
#import "SisainliveAppDelegate.h"
#import "Constants.h"
#define PICTURE_IMAGE_FILE_PREFIX @"PictureImage_"

@implementation ArticleImageView

@synthesize index;
@synthesize delegate;

- (void)dealloc {
	[documentPath release];
	[img release];
	[deleteImage release];
	if (thread) {
		if ([thread isExecuting]) {
			[thread cancel];
		}
		[thread release];
		thread = nil;
	}
	
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		if (self) {
			// 다운로드된 파일들이 저장되는 경로를 지정
			documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] retain];
			[self setUserInteractionEnabled:YES];
			[self setExclusiveTouch:YES];  // block other touches while dragging a thumb view
			[self setContentMode:UIViewContentModeScaleAspectFit];
		}
    }
    return self;
}



#pragma mark touches methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	dragging = YES;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
    if (dragging) {
        dragging = NO;
    }
	else if ([touch tapCount] == 1) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(articleImageViewWasTapped:)]) {
			[self.delegate articleImageViewWasTapped:index];
		}
    }
}



- (void)setupImage:(ArticleListContent *)content {
	
	
	self.image = nil;
	self.image = DefaultImgCell3G;
	
	NSString *imageUrl = content.Limage;
	
	
	if (imageUrl != nil) {
		if (thread) {
			if ([thread isExecuting]) {
				[thread cancel];
			}
			[thread release];
			thread = nil;
		}
		
		thread = [[NSThread alloc] initWithTarget:self selector:@selector(getImageData:) object:content];
		[thread start];
	}
}


- (void)getImageData:(ArticleListContent *)url {
	NSAutoreleasePool *Pool = [[NSAutoreleasePool alloc] init];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *fileNameWithPrefix = [PICTURE_IMAGE_FILE_PREFIX stringByAppendingString:[NSString stringWithFormat:@"%@.jpg",url.link_id]]; // ex) ThirdViewController_01.jpg
	NSString *filePathInDevice = [documentPath stringByAppendingPathComponent:fileNameWithPrefix];
	
	NSData *receivedData;
	if ([fileManager fileExistsAtPath:filePathInDevice]) {
		receivedData = [[NSData alloc] initWithContentsOfFile:filePathInDevice];
	}
	else {
		receivedData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url.Limage]]];
		[receivedData writeToFile:filePathInDevice atomically:YES];
	}
	[receivedData release];
	
	NSString *imageFilePath = [documentPath stringByAppendingPathComponent:[PICTURE_IMAGE_FILE_PREFIX stringByAppendingString:[NSString stringWithFormat:@"%@.jpg",url.link_id]]];	
	
	img = [UIImage imageWithContentsOfFile:imageFilePath];
	if (img != nil) {
		self.image = nil;
		self.image = img;
	}else {
		self.image = DefaultImgCell3G;
	}
	
	[Pool release];
}


- (void)removeImage:(NSArray *)contentArray atTO:(NSInteger)indexNo{
	
	NSInteger backnumber = indexNo - 10;
	NSInteger nextnumber = indexNo + 10;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (backnumber >= 0) {
		for (int i = backnumber; backnumber >= 0; backnumber--) {
			ArticleListContent *content = [contentArray objectAtIndex:i];
			
			NSString *imageFilePath = [documentPath stringByAppendingPathComponent:[PICTURE_IMAGE_FILE_PREFIX stringByAppendingString:[NSString stringWithFormat:@"%@.jpg",content.link_id]]];	
			
			deleteImage = [UIImage imageWithContentsOfFile:imageFilePath];
			if (deleteImage != nil) {
				[fileManager removeItemAtPath:imageFilePath error:nil];
			}
		}
	}
	
	if (nextnumber <= [contentArray count]-1) {
		for (int i = nextnumber; nextnumber <= [contentArray count]-1; nextnumber++) {
			ArticleListContent *content = [contentArray objectAtIndex:i];
			NSString *imageFilePath = [documentPath stringByAppendingPathComponent:[PICTURE_IMAGE_FILE_PREFIX stringByAppendingString:[NSString stringWithFormat:@"%@.jpg",content.link_id]]];	
			deleteImage = [UIImage imageWithContentsOfFile:imageFilePath];
			if (deleteImage != nil) {
				[fileManager removeItemAtPath:imageFilePath error:nil];
			}
		}
	}
}

@end
