//
//  AsyncImageView.h
//  CaGrid
//
//  Created by Konrad Rokicki on 11/11/09.
//  Adapted from http://www.markj.net/iphone-asynchronous-table-image/
//

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIView {
    NSURL *url;
	NSURLConnection *connection; 
	NSMutableData *data; 
    UIImageView *imageView;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURLConnection* connection;
@property (nonatomic, retain) NSMutableData* data;
@property (nonatomic, retain) UIImageView *imageView;

- (id) initWithFrame:(CGRect)frame andImage:(UIImage *)image;

- (void)loadImageFromURL:(NSURL*)url;

@end
