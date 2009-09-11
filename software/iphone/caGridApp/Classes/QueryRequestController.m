//
//  QueryRequestController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryRequestController.h"
#import "QueryResultsController.h"
#import "QueryRequestCell.h"
#import "ServiceMetadata.h"
#import "Util.h"

@implementation QueryRequestController
@synthesize searchBarOutlet;
@synthesize requestsTable;
@synthesize navController;
@synthesize resultsController;
@synthesize queryRequests;
@synthesize service;

#pragma mark -
#pragma mark Object Methods

- (void)viewDidLoad {
    self.queryRequests = [NSMutableArray array];
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    smdata.delegate = self;    
    [super viewDidLoad];
}

- (void)resetView {
    self.service = nil;
    
    self.title = @"Search";        
	self.searchBarOutlet.showsScopeBar = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    [UIView beginAnimations:@"frame" context:nil];	
    [UIView setAnimationDuration:0.3];
   	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
	CGRect sframe = searchBarOutlet.frame;
    sframe.size.height = 88;
	searchBarOutlet.frame = sframe;
    
    CGRect tframe = requestsTable.frame;
    tframe.size.height = 280;
    tframe.origin.y = 88;
	requestsTable.frame = tframe;
    
	[UIView commitAnimations];
}

- (void)clickDoneButton:(id)sender {
    [self resetView];
}

- (void)viewWillAppear:(BOOL)animated {
	if (service == nil) {
        [self resetView];
    }
    else {
        self.title = [NSString stringWithFormat:@"%@ at %@", 
                      [service objectForKey:@"name"],
                      [service objectForKey:@"hosting_center_name"]];
        self.searchBarOutlet.showsScopeBar = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
				initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				target:self 
				action:@selector(clickDoneButton:)];
        
        CGRect sframe = searchBarOutlet.frame;
        sframe.size.height = 44;
        searchBarOutlet.frame = sframe;
        
        CGRect tframe = requestsTable.frame;
        tframe.size.height = 324;
        tframe.origin.y = 44;
        requestsTable.frame = tframe;
    }
    [super viewWillAppear:animated];
}

- (void)dealloc {
    self.navController = nil;
    self.queryRequests = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Search Bar Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
    
    NSString *searchString = [searchBar text];
    NSString *scope = [[searchBar scopeButtonTitles] objectAtIndex:[searchBar selectedScopeButtonIndex]];
    
    NSLog(@"Search %@ for %@",scope,searchString);
    
    NSMutableDictionary *queryRequest = [NSMutableDictionary dictionary];
    [queryRequest setObject:searchString forKey:@"searchString"];
    
    if (service != nil) {
	    [queryRequest setObject:[service objectForKey:@"url"] forKey:@"serviceUrl"];
	    [queryRequest setObject:[service objectForKey:@"name"] forKey:@"service_name"];
	    [queryRequest setObject:[service objectForKey:@"hosting_center_name"] forKey:@"hosting_center_name"];        
    }
    else {
	    [queryRequest setObject:scope forKey:@"scope"];
    }
    
    [queryRequests insertObject:queryRequest atIndex:0];
    [self.requestsTable reloadData];
    
    [[ServiceMetadata sharedSingleton] executeQuery:queryRequest];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {	
	[searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
	return YES;
}

#pragma mark -
#pragma mark Search Result Delegate Methods

- (void)requestCompleted:(NSMutableDictionary *)request {
    [self.requestsTable reloadData];
}

- (void)requestHadError:(NSMutableDictionary *)request {
    NSMutableDictionary *error = [request objectForKey:@"error"];
    NSString *errorType = [error objectForKey:@"error"];
    NSString *message = [error objectForKey:@"message"];
    NSLog(@"%@: %@",errorType,message);
    [Util displayDataError];
    [self.requestsTable reloadData];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
 		numberOfRowsInSection:(NSInteger)section {
	return [queryRequests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Get a cell
    
	static NSString *cellIdentifier = @"QueryRequestCell";	
	QueryRequestCell *cell = (QueryRequestCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    cell.alertImageView.hidden = YES;
    
    NSMutableDictionary *queryRequest = [queryRequests objectAtIndex:[indexPath row]];
        
    if ([queryRequest objectForKey:@"results"] != nil) {
	    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    	[cell.indicator stopAnimating];
    }
    else if ([queryRequest objectForKey:@"error"] != nil) {
    	[cell.indicator stopAnimating];
	    cell.alertImageView.hidden = NO;
    }
    else {
    	[cell.indicator startAnimating];
    }

    cell.titleLabel.text = [NSString stringWithFormat:@"\"%@\"", [queryRequest objectForKey:@"searchString"]];
    
    NSString *serviceName = [queryRequest objectForKey:@"service_name"];
    if (serviceName != nil) {
        cell.descLabel.text = [NSString stringWithFormat:@"%@ at %@", serviceName, [queryRequest objectForKey:@"hosting_center_name"]];
    }
    else {
        cell.descLabel.text = [NSString stringWithFormat:@"%@", [queryRequest objectForKey:@"scope"]];
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSMutableDictionary *queryRequest = [queryRequests objectAtIndex:[indexPath row]];
    if ([queryRequest objectForKey:@"results"] == nil) {
    	NSMutableDictionary *error = [queryRequest objectForKey:@"error"];
        if (error != nil) {
            [Util displayCustomError:[error objectForKey:@"error"] withMessage:[error objectForKey:@"message"]];
        }
    	return;
    }
    
	if (resultsController == nil) {
		self.resultsController = [[QueryResultsController alloc] init];
		resultsController.navController = navController;
	}
    resultsController.request = queryRequest;
	
	[resultsController.tableView reloadData];
	[navController pushViewController:resultsController animated:YES];	
}

- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return QUERY_REQUEST_CELL_HEIGHT;
}

@end
