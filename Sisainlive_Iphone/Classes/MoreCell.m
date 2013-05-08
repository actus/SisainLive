//
//  MoreCell.m
//  sisain
//
//  Created by Jupiter on 10. 8. 3..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import "MoreCell.h"

/**
 기사더보기 테이블 셀
 */
@implementation MoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
