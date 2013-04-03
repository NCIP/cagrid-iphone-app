//
//  DownloadManager.h
//
//  Created by Konrad Rokicki on 11/13/09.
//  Copyright 2009 SAIC. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! 
 @class DownloadManager
 
 @abstract A DownloadManager object manages several asynchronous 
 HTTP GET downloads. 
 
 @discussion A client can call beginDownload on several URLs. 
 The client will be notified with the methods in DownloadDelegate.
 */
@interface DownloadManager : NSObject {
	@private CFMutableDictionaryRef connectionRequestMap;
}

/*! 
 @method beginDownload:
 @abstract Begins downloading the given URL.
 @discussion This method begins a download and returns. Whenever
 the download is over (either complete or has an error), one of the 
 methods in DownloadDelegate is called.
 @param url The url to request with an HTTP GET.
 @param delegate The object which implements DownloadDelegate methods.
 */
- (void)beginDownload:(NSURL *)url delegate:(id)delegateObj;

@end

/*!
 @category NSObject(DownloadDelegate)

 The DownloadDelegate category on NSObject defines
 DownloadDelegate delegate methods that can be implemented by
 objects to receive informational callbacks about the asynchronous
 download of URL requests. 
 */
@interface NSObject(DownloadDelegate)

/*!
 @method download:failedWithError:
 @abstract This method notifies the delegate that the download failed.
 @discussion If implemented, provides the delegate with the error 
 encountered when downloading a given URL. Note that there is no way to 
 distinguish between more than one download of the same URL.
 @param url the URL for which downloading failed. 
 @param error an NSError propagated from the NSURLConnection which failed.
 */
- (void)download:(NSURL *)url failedWithError:(NSError *)error;

/*!
 @method download:completedWithData:
 @abstract This method notifies the delegate that the download completed.
 @discussion If implemented, provides the delegate with the data 
 retrieved from a given URL. Note that there is no way to 
 distinguish between more than one download of the same URL.
 @param url the URL for which downloading completed.
 @param data the NSData retrieved from the url.
 */
- (void)download:(NSURL *)url completedWithData:(NSMutableData *)data;

@end