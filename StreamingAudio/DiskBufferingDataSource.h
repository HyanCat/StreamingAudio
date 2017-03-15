//
//  DiskBufferingDataSource.h
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

@import StreamingKit;
#import "DiskBuffer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DiskBufferingDataSource : STKDataSourceWrapper

@property (nonatomic, assign) BOOL enabledDiskBuffer;
@property (nonatomic, strong, readonly) DiskBuffer *diskBuffer;

@property (nonatomic, assign) BOOL enabledCache;
@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSURL *localURL;
@property (nonatomic, strong, readonly) STKLocalFileDataSource *localDataSource;
@property (nonatomic, strong, readonly) STKHTTPDataSource *httpDataSource;

- (instancetype)initWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
