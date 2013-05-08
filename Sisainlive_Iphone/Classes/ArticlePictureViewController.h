//
//  ArticlePictureViewController.h
//  sisain
//
//  Created by Jupiter on 10. 8. 3..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleImageView.h"
#import "DescriptionLabel.h"
#import "BaseViewCtrl.h"

@protocol ArticlePictureViewControllerDelegate <NSObject>
@optional
- (void)articleWasTapped:(NSInteger)index;
@end
/**
 기사사진 뷰
 */
@interface ArticlePictureViewController : BaseViewCtrl <ArticleImageViewDelegate, DescriptionLabelDelegate> {
@private
	IBOutlet UIScrollView	*scrollView;
	IBOutlet UIView			*leftView;
	IBOutlet UIView			*rightView;
	IBOutlet UIButton		*leftButton;
	IBOutlet UIButton		*rightButton;
	DescriptionLabel		*descriptionLabel;
	
	NSArray			*contentArray;
	
	NSMutableSet	*reusableTiles;
	
	NSInteger		firstVisibleIndex;
	NSInteger		lastVisibleIndex;
	
	NSInteger		currentPage;
	
	id <ArticlePictureViewControllerDelegate> delegate;
	
	NSInteger networkStatus;
	
	NSString *Section_Code;
	
}
@property (nonatomic, retain) NSString *Section_Code;
@property (nonatomic, retain) NSArray *contentArray;
@property (nonatomic, assign) id <ArticlePictureViewControllerDelegate> delegate;

- (IBAction)buttonAction:(id)sender;

- (void)setupScrollViewContentSize;

- (void)downloadImageDecision:(NSString *)sectionName;

- (void)reSetupadView;

//- (void)timerStart;
//- (void)timerStop;

@end
