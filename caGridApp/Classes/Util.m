//
//  Util.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "Label2.h"
#import "UserPreferences.h"
#import "ServiceMetadata.h"

// has the user been alerted that there is a network problem?
static BOOL alerted = NO;

@implementation Util

+ (NSString *) getIconNameForServiceOfType:(NSString *)class {
    return [class isEqualToString:@"DataService"] ? @"database" : @"chart_bar";
}


+ (BOOL)string:(NSString *)searchStr isFoundIn:(NSString *)text {
    if (searchStr == nil || text == nil) return NO;
	return ([text rangeOfString:searchStr options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound);
}


+ (NSDate *) getDateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"]; // 2009-02-01 19:50:41 PST
	NSDate *date = [dateFormat dateFromString:dateString];
    [dateFormat release];
    return date;
}

+ (NSString *) getStringFromDate:(NSDate *)date {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"]; // 2009-02-01 19:50:41 PST
	NSString *dateString = [dateFormat stringFromDate:date];
    [dateFormat release];
    return dateString;
}

+ (NSString *) getDateStringFromDate:(NSDate *)date {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"MM/dd/yyyy"]; // 01/02/2009 
	NSString *dateString = [dateFormat stringFromDate:date];
    [dateFormat release];
    return dateString;
}

+ (NSString *)dateDifferenceStringFromDate:(NSDate *)date {
    double time = [date timeIntervalSinceDate:[NSDate date]];
    time *= -1;
    if(time < 1) {
        return [self getStringFromDate:date];
    } 
    else if (time < 60) {
        return @"less than a minute ago";
    } 
    else if (time < 3600) {
        int diff = round(time / 60);
        if (diff == 1) 
            return [NSString stringWithFormat:@"1 minute ago", diff];
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } 
    else if (time < 86400) {
        int diff = round(time / 60 / 60);
        if (diff == 1)
            return [NSString stringWithFormat:@"1 hour ago", diff];
        return [NSString stringWithFormat:@"%d hours ago", diff];
    } 
    else if (time < 604800) {
        int diff = round(time / 60 / 60 / 24);
        if (diff == 1) 
            return [NSString stringWithFormat:@"yesterday", diff];
        if (diff == 7) 
            return [NSString stringWithFormat:@"last week", diff];
        return[NSString stringWithFormat:@"%d days ago", diff];
    } 
    else {
        int diff = round(time / 60 / 60 / 24 / 7);
        if (diff == 1)
            return [NSString stringWithFormat:@"last week", diff];
        return [NSString stringWithFormat:@"%d weeks ago", diff];
    }   
}


+ (void) displayNetworkError {
    @synchronized(self) {    
        if (!alerted) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving data (ERR01)" 
                                                            message:@"Could not connect to the server." 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert autorelease];
            alerted = YES;
        }
    }
}


+ (void) clearNetworkErrorState {
    @synchronized(self) {
 		alerted = NO;   
    }
}


+ (void) displayCustomError:(NSString *)title withMessage:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:message 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert autorelease];
}


+ (NSString *)getPathFor:(NSString *)filename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingPathComponent:filename];
}


+ (NSString *)getLabelForDataType:(DataType)dataType {
    
    switch (dataType) {
        case DataTypeMicroarray:
            return @"Microarray";
        case DataTypeImaging:
            return @"Imaging";
        case DataTypeBiospecimen:
            return @"Biospecimen";
        case DataTypeNanoparticle:
            return @"Nanoparticle";
        default:
            return @"Unknown";
    }
}


+ (NSString *)getNameForDataType:(DataType)dataType {
    
    switch (dataType) {
        case DataTypeMicroarray:
            return @"microarray";
        case DataTypeImaging:
            return @"imaging";
        case DataTypeBiospecimen:
            return @"biospecimen";
        case DataTypeNanoparticle:
            return @"nanoparticle";
        default:
            return nil;
    }
}

+ (NSString *)getLabelForDataTypeName:(NSString *)dataTypeName {
    if ([dataTypeName isEqualToString:@"microarray"]) {
        return @"Microarray";
    }
    else if ([dataTypeName isEqualToString:@"imaging"]) {
        return @"Imaging";
    }    
    else if ([dataTypeName isEqualToString:@"biospecimen"]) {
        return @"Biospecimen";
    }
    else if ([dataTypeName isEqualToString:@"nanoparticle"]) {
        return @"Nanoparticle";
    }
    else {
        return @"Unknown";
    }
}

+ (DataType)getDataTypeForDataTypeName:(NSString *)dataTypeName {
    if ([dataTypeName isEqualToString:@"microarray"]) {
        return DataTypeMicroarray;
    }
    else if ([dataTypeName isEqualToString:@"imaging"]) {
        return DataTypeImaging;
    }    
    else if ([dataTypeName isEqualToString:@"biospecimen"]) {
        return DataTypeBiospecimen;
    }
    else if ([dataTypeName isEqualToString:@"nanoparticle"]) {
        return DataTypeNanoparticle;
    }
    else {
        return -1;
    }
}

+ (NSMutableDictionary *)getError:(NSString *)errorType withMessage:(NSString *)message {
	NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    [errorDict setObject:errorType forKey:@"error"];
    [errorDict setObject:message forKey:@"message"];    
    return errorDict;
}

+ (FavorableCell *)getServiceCell:(NSMutableDictionary *)service fromTableView:(UITableView *)tableView {
	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *subtitle = [defaults stringForKey:@"service_subtitle"];
	
	// Get a cell

	NSString *cellIdentifier = [subtitle isEqualToString:@"none"] ? @"FavorableCell" : @"FavorableDescCell";
	FavorableCell *cell = (FavorableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	
	// Get service metadata
	NSString *class = [service objectForKey:@"class"];
	NSString *name = [service objectForKey:@"display_name"];
	
	// Populate the cell
	cell.titleLabel.text = name;
	
	if ([subtitle isEqualToString:@"software"]) {
		cell.descLabel.text = [NSString stringWithFormat:@"%@ %@",[service objectForKey:@"name"],[service objectForKey:@"version"]];
	}
	else if ([subtitle isEqualToString:@"url"]) {
		cell.descLabel.text = [service objectForKey:@"url"];
	}	
	else if ([subtitle isEqualToString:@"host"]) {
		NSString *hostId = [service valueForKey:@"host_id"];
		if (hostId != nil) {
			ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
			NSMutableDictionary *host = [sm.hostsById valueForKey:hostId];
			cell.descLabel.text = [host valueForKey:@"long_name"];
		}
		else {		
			cell.descLabel.text = @"";
		}
	}
	else {
		cell.descLabel.text = @"";
	}
	
	cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[Util getIconNameForServiceOfType:class]]];
    cell.tickIcon.hidden = YES;
    cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavoriteService:[service objectForKey:@"id"]];
    
	if (service == nil || [name isEqualToString:@"Unknown"]) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	} 
	else {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; 
	}
	
	return cell;
}


+ (CGFloat)heightForLabel:(NSString *)value constrainedToWidth:(CGFloat)width {
	CGSize withinSize = CGSizeMake(width, MAXFLOAT); 
	CGSize size = [value sizeWithFont: [UIFont systemFontOfSize: [UIFont systemFontSize]] constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap]; 
	return size.height; 
}


+ (UITableViewCell *)getKeyValueCell:(KeyValuePair *)pair fromTableView:(UITableView *)tableView {

	NSString *key = pair.key;
	NSString *value = pair.value;
	
	// Calculate cellHeight 
	CGFloat valueWidth = tableView.bounds.size.width - (sidePadding*2 + insetPadding + keyWidth + valueSpacing);
	// I can't figure out why the +10 is needed, but without it, values that have spaces can reserve 2 lines even if they fit on 1
	CGFloat h1 = [Util heightForLabel:key constrainedToWidth:keyWidth+10];
	CGFloat h2 = [Util heightForLabel:value constrainedToWidth:valueWidth];
	CGFloat cellHeight = ((h1 > h2) ? h1:h2) + verticalSpacing;
	
	// Calculate labelHeight by subtracting the vertical padding 
	float labelHeight = cellHeight - verticalSpacing;
	
	CGRect keyLabelFrame = CGRectMake(insetPadding / 2, verticalSpacing / 2, 
									  (insetPadding / 2) + keyWidth, labelHeight); 
	
	// The +8 to width is to get around the right margin issue with UITextView (ContentInset doesn't do anything)
	CGRect valueLabelFrame = CGRectMake((insetPadding / 2) + keyWidth + valueSpacing, verticalSpacing / 2, 
										valueWidth+8, labelHeight); 
	
	CGRect cellFrame = CGRectMake(0, 0, 0, cellHeight); 
	
	static NSString *cellIdentifier = @"VariableHeightCell"; 
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
		
		Label2 *keyLabel = [[Label2 alloc] initWithFrame: keyLabelFrame]; 
		[keyLabel setTag:10];
		[keyLabel setNumberOfLines:0];  // auto-expand
		[keyLabel setFont:[UIFont systemFontOfSize: [UIFont systemFontSize]]];
		[keyLabel setVerticalAlignment:VerticalAlignmentTop];
		[keyLabel setTextColor: [UIColor grayColor]];
		[cell.contentView addSubview:keyLabel];
		[keyLabel release];
		
		UITextView *valueLabel = [[UITextView alloc] initWithFrame: valueLabelFrame]; 
		[valueLabel setTag:11];
		[valueLabel setFont:[UIFont systemFontOfSize: [UIFont systemFontSize]]];
		[valueLabel setEditable:NO];
		[valueLabel setDataDetectorTypes:UIDataDetectorTypeLink];
		[valueLabel setUserInteractionEnabled:YES];
		[valueLabel setScrollEnabled:NO];
		[valueLabel setContentInset:UIEdgeInsetsMake(-9,-6,0,0)];

		[cell.contentView addSubview:valueLabel];
		[valueLabel release];
	}
	
	Label2 *keyLabel = (Label2 *)[cell viewWithTag:10];
	Label2 *valueLabel = (Label2 *)[cell viewWithTag:11];
	
	cell.bounds = cellFrame;
	[keyLabel setFrame: keyLabelFrame]; 
	[valueLabel setFrame: valueLabelFrame]; 
	[keyLabel setText:key];
	[valueLabel setText:value];
	
	return cell; 	
}


@end
