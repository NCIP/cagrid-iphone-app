//
//  AsyncImageView.m
//  CaGrid
//
//  Created by Konrad Rokicki on 11/11/09.
//

#import "AsyncImageView.h"
#import "ServiceMetadata.h"

@implementation AsyncImageView
@synthesize url;
@synthesize connection;
@synthesize data;
@synthesize imageView;

- (id) initWithFrame:(CGRect)frame andImage:(UIImage *)image {
	if (self = [super initWithFrame:frame]) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:image];
        self.imageView = iv;
        [iv release];
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight );
        imageView.frame = self.bounds;
        
        [self addSubview:imageView];
        [self setNeedsLayout];
   	}
	return self;
}

- (void)dealloc {
	[connection cancel];
    self.url = nil;
	self.connection = nil;
    self.imageView = nil;
	self.data = nil;
    [super dealloc];
}

- (void)loadImageFromURL:(NSURL*)imageURL {
    
    self.url = imageURL;
    
    // Cancel existing connection
	if (connection != nil) { 
        [connection cancel];
    	[connection release]; 
    } 
    
    // Clear data
	if (data != nil) { 
        [data release];
    }
	
    NSLog(@"Loading %@",url);
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
    
    if (connection) {
        self.data = [[NSMutableData alloc] initWithCapacity:2048];
    }
	else {
        NSLog(@"Connection was null");
    }
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	[data appendData:incrementalData];
}


- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    
	[connection release];
	self.connection = nil;
    
    if (data.length == 0) return;
     
    UIImage *img = [UIImage imageWithData:data];
    if (img.size.width <= 0 || img.size.height <= 0) return;
     
    self.imageView.image = img;
	[data release]; 
	self.data = nil;

    // TODO: this should call a delegate. This code shouldn't know about hosts or ServiceMetadata.
    [[ServiceMetadata sharedSingleton].hostImagesByUrl setObject:img forKey:url];
    
	[self.imageView setNeedsLayout];
	[self setNeedsLayout];
}


@end
