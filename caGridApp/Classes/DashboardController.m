//
//  DashboardController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 10/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DashboardController.h"
#import "DashboardCell.h"
#import "CaGridAppDelegate.h";
#import "QueryExecutionController.h"
#import "Util.h"
#import "ServiceMetadata.h"

// Uncomment this line to create the splash screen used for Default.png
//#define DEFAULT_PNG_SCREENSHOT 

@implementation DashboardController
@synthesize navController;
@synthesize queryExecutionController;
@synthesize summaryLabel;
@synthesize infoView;
@synthesize infoText;
@synthesize summaryTable;
@synthesize infoButton;

- (void)dealloc {
    self.navController = nil;
    self.queryExecutionController = nil;
    self.summaryLabel = nil;
    self.infoView = nil;
    self.infoText = nil;
    self.infoButton = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
    [infoText loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    
    UIButton *infoButtonType = [[UIButton buttonWithType:UIButtonTypeInfoLight] retain];
    infoButtonType.frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
    infoButtonType.backgroundColor = [UIColor clearColor];
    [infoButtonType addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButtonType];
    self.navigationItem.rightBarButtonItem = infoButton;
    [infoButtonType release];
    [infoButton release];

    [super viewDidLoad];
}

- (void)reload {
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSUInteger c1 = [[sm getServices] count];
    NSUInteger c2 = [[sm getHosts] count];
    self.summaryLabel.text = (c1 > 0 && c2 > 0) ? [NSString stringWithFormat:@"%d services hosted by %d institutions",c1,c2] : @"";
    
	#ifdef DEFAULT_PNG_SCREENSHOT
    	self.summaryLabel.text = @"";
	#endif
	    
    [self.summaryTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // reload data
	[self reload];
    
    // restore default view
    [infoView removeFromSuperview];
    self.navigationItem.rightBarButtonItem = infoButton;
    
    [super viewWillAppear:animated];
}

- (IBAction) clickMoreButton:(id)sender {
    CaGridAppDelegate *delegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.tabBarController.selectedIndex = 2;
}


#pragma mark -
#pragma mark Internal Methods

- (NSUInteger)getSumForClass:(NSString *)className {
	ServiceMetadata* sm = [ServiceMetadata sharedSingleton];
	NSDictionary *objectCounts = [sm getCounts];
	NSDictionary *dict = [objectCounts valueForKey:className];
	if (dict == nil || [dict count] == 0) {
		return 0;
	}
	NSUInteger sum = 0;
	for(NSString *serviceId in [dict allKeys]) {
		NSString *value = [dict valueForKey:serviceId];
		if (value != nil) {
			sum += [value intValue];
		}
	}
	return sum;
}

#pragma mark -
#pragma mark Info Button Methods

- (void)infoButtonPressed:(id)sender {
	//self.view.superview.userInteractionEnabled = NO;
	[UIView beginAnimations:@"frame" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[self.view addSubview: infoView];
    
    [UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
    
	[UIView commitAnimations];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeInfoButtonPressed:)];
}

- (IBAction)closeInfoButtonPressed:(id)sender {
	//self.view.superview.userInteractionEnabled = NO;
	[UIView beginAnimations:@"frame" context:nil];
	[UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[infoView removeFromSuperview];
	[UIView commitAnimations];
    self.navigationItem.rightBarButtonItem = infoButton;
}

- (void)transitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	// re-enable user interaction when the flip is completed.
	//self.view.superview.userInteractionEnabled = YES;
}

- (NSString *)getLabelForCount:(NSUInteger)count {
	return count > 1 ? @"services" : @"service";	
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
 		numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
    
	// Get a cell
    
	static NSString *cellIdentifier = @"DashboardCell";
	DashboardCell *cell = (DashboardCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	
	// Get service metadata
	
    DataType dataType = (DataType)row;
    
    cell.titleLabel.text = [Util getLabelForDataType:dataType];
	
	ServiceMetadata* sm = [ServiceMetadata sharedSingleton];
    NSUInteger serviceCount = [[sm getServicesOfType:dataType] count];
	NSUInteger objectCount = [self getSumForClass:[Util getMainClassForDataType:dataType]];
	NSString *servicePlural = [self getLabelForCount:serviceCount];
	NSString *plural = [Util getMainClassPluralForDataType:dataType forCount:objectCount];
	
    static NSString *none = @"";
    
    if (row == DataTypeMicroarray) {
        cell.descLabel.text = serviceCount > 0 ? [NSString stringWithFormat:@"%d caArray %@",serviceCount,servicePlural] : none;
		cell.objectCount.text = objectCount > 0 ? [NSString stringWithFormat:@"%d %@",objectCount,plural] : none;
        cell.icon.image = [UIImage imageNamed:@"db_microarray.png"];
    }
    else if (row == DataTypeImaging) {
        cell.descLabel.text = serviceCount > 0 ? [NSString stringWithFormat:@"%d NBIA %@",serviceCount,servicePlural] : none;
		cell.objectCount.text = objectCount > 0 ? [NSString stringWithFormat:@"%d %@",objectCount,plural] : none;	
        cell.icon.image = [UIImage imageNamed:@"db_imaging.png"];
    }
    else if (row == DataTypeBiospecimen) {
        cell.descLabel.text = serviceCount > 0 ? [NSString stringWithFormat:@"%d caTissue %@",serviceCount,servicePlural] : none;
		cell.objectCount.text = objectCount > 0 ? [NSString stringWithFormat:@"%d %@",objectCount,plural] : none;	
        cell.icon.image = [UIImage imageNamed:@"db_biospecimen.png"];
    }
    else if (row == DataTypeNanoparticle) {
        cell.descLabel.text = serviceCount > 0 ? [NSString stringWithFormat:@"%d caNanoLab %@",serviceCount,servicePlural] : none;
		cell.objectCount.text = objectCount > 0 ? [NSString stringWithFormat:@"%d %@",objectCount,plural] : none;
        cell.icon.image = [UIImage imageNamed:@"db_nanoparticles.png"];
    }

    #ifdef DEFAULT_PNG_SCREENSHOT
        cell.descLabel.text = @"";
    #endif
    
	return cell;
}


- (void)selectDataType:(DataType)dataType {
	if (queryExecutionController == nil) {
        self.queryExecutionController = [[QueryExecutionController alloc] initWithNibName:@"QueryExecutionView" bundle:nil];
        queryExecutionController.navController = navController;
	}
    
    queryExecutionController.dataType = dataType;
    [navController pushViewController:queryExecutionController animated:YES];
}

- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [self selectDataType:indexPath.row];
}


- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DASHBOARD_CELL_HEIGHT;
}

@end
