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

@interface DiskBufferingDataSource : STKAutoRecoveringHTTPDataSource

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong, readonly) DiskBuffer *diskBuffer;

@end

NS_ASSUME_NONNULL_END
