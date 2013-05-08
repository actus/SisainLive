//
//  BaseTableViewCtrl.m
//  sisain
//
//  Created by Jupiter on 10. 8. 3..
//  Copyright 2010 모빌리스 솔루션즈. All rights reserved.
//

#import "BaseTableViewCtrl.h"

/**
 기본 테이블베이스 뷰
 */

@implementation BaseTableViewCtrl

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		appDelegate	= (SisainliveAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark setup barButtons

- (void)setupBarButtons:(UINavigationItem *)navigationIem buttonFlag:(NSInteger)buttonFlag {
	switch (buttonFlag) {
		case close_barButton:	//Info TableView
		{
			navigationIem.leftBarButtonItem = nil;
			UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"닫기", @"닫기")
																		  style:UIBarButtonItemStyleBordered
																		 target:self
																		 action:@selector(barButtonAction:)];
			barButton.tag = close_barButton;
			navigationIem.leftBarButtonItem = barButton;
			[barButton release];
		}
			break;
	}
}

@end

