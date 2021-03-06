//
//  DashboardController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 10/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h";

// To create the splash screen used for Default.png uncomment the following define,
// and then edit MainWindow.xib to hide the activity indicator and "Downloading" label,
// and instead show the "Loading" label.

//#define DEFAULT_PNG_SCREENSHOT 

@class QueryExecutionController;

@interface DashboardController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
	IBOutlet UINavigationController *navController;
	IBOutlet QueryExecutionController *queryExecutionController;    
    IBOutlet UILabel *summaryLabel;
    IBOutlet UIView *infoView;
	IBOutlet UIWebView *infoText;
    IBOutlet UITableView *summaryTable;
    UIBarButtonItem *infoButton;
}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) QueryExecutionController *queryExecutionController;
@property (nonatomic, retain) UILabel *summaryLabel;
@property (nonatomic, retain) UIView *infoView;
@property (nonatomic, retain) UIWebView *infoText;
@property (nonatomic, retain) UITableView *summaryTable;
@property (nonatomic, retain) UIBarButtonItem *infoButton;

- (IBAction) clickMoreButton:(id)sender;

- (IBAction) closeInfoButtonPressed:(id)sender;

- (void)selectDataType:(DataType)dataType;

- (void)reload;

@end
