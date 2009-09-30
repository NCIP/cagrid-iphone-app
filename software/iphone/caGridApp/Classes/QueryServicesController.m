//
//  QueryServicesController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 9/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryServicesController.h"
#import "QueryResultsController.h"
#import "QueryServiceCell.h"
#import "ServiceMetadata.h"

@implementation QueryServicesController
@synthesize navController;
@synthesize detailController;
@synthesize request;
@synthesize urls;
@synthesize failedUrls;

- (void)displayRequest:(NSMutableDictionary *)requestDict {
    self.request = requestDict;
    
    NSMutableDictionary *results = [request objectForKey:@"results"];
    self.urls = (NSMutableArray *)[results allKeys];
	self.failedUrls = [request objectForKey:@"failedUrls"];
    
	[self.tableView reloadData];
}

- (void)viewDidLoad {
	self.title = @"Services Searched";
}

- (void)dealloc {
	self.navController = nil;
	self.request = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
 		numberOfRowsInSection:(NSInteger)section {
	return [urls count] + [failedUrls count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Get a cell
    
	static NSString *cellIdentifier = @"QueryServiceCell";	
	QueryServiceCell *cell = (QueryServiceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    NSUInteger row = [indexPath row];
    BOOL failed = row >= [urls count];
    
    NSString *url = failed ? [failedUrls objectAtIndex:(row-[urls count])] : [urls objectAtIndex:row];
    NSMutableArray *results = [[request objectForKey:@"results"] objectForKey:url];
    NSMutableDictionary *service = [[ServiceMetadata sharedSingleton] getServiceByUrl:url];
    
    if (failed) {
     	cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (service == nil) {
        cell.titleLabel.text = url;
        cell.descLabel.text = @"";
        cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@.png",
			[Util getIconNameForClass:@"DataService" andStatus:failed?@"inactive":@"active"]]];
        cell.countLabel.text = failed ? @"Failed" : [NSString stringWithFormat:@"%d results",[results count]];
        return cell;
    }
    
    if (failed) {
        // Update service status in the service summary and the service metadata
        NSMutableDictionary *metadata = [[ServiceMetadata sharedSingleton] getMetadataById:[service objectForKey:@"id"]];
        [metadata setObject:@"inactive" forKey:@"status"];
        [service setObject:@"inactive" forKey:@"status"];
    }
    
	// Get service metadata
	
	NSString *class = [service objectForKey:@"class"];
	NSString *status = [service objectForKey:@"status"];
	
	// Populate the cell
	
	cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@",[service objectForKey:@"name"],[service objectForKey:@"version"]];
	cell.descLabel.text = [[service objectForKey:@"hosting_center"] objectForKey:@"short_name"];
	cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@.png",[Util getIconNameForClass:class andStatus:status]]];
	cell.countLabel.text = failed ? @"Failed" : [NSString stringWithFormat:@"%d results",[results count]];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.detailController == nil) {
		self.detailController = [[QueryResultsController alloc] init];
		detailController.navController = navController;
	}
        
    NSUInteger row = [indexPath row];
    BOOL failed = row >= [urls count];
        
    if (failed) {
        [Util displayCustomError:@"Service Failure" withMessage:@"Service could not be reached."];
        return;
	}            
    
    NSString *url = failed ? [failedUrls objectAtIndex:(row-[urls count])] : [urls objectAtIndex:row];
    NSMutableArray *results = [[request objectForKey:@"results"] objectForKey:url];
    NSMutableDictionary *service = [[ServiceMetadata sharedSingleton] getServiceByUrl:url];
    
    [detailController displayResults:results forService:service];
        
	
	[navController pushViewController:detailController animated:YES];	
}

- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}

@end


