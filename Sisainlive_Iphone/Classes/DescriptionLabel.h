//
//  DescriptionLabel.h
//  sisain
//
//  Created by Jupiter on 10. 8. 4..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DescriptionLabelDelegate <NSObject>
@optional
- (void)articleLabelWasTapped:(NSInteger)index;
@end

@interface DescriptionLabel : UILabel {
@private
	NSInteger	index;	
	BOOL		dragging;
	id <DescriptionLabelDelegate> delegate;
}

@property (nonatomic, assign) NSInteger	index;
@property (nonatomic, assign) id <DescriptionLabelDelegate> delegate;

@end
