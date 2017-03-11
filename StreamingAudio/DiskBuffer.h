//
//  DiskBuffer.h
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DiskBuffer : NSObject

@property (nonatomic, copy, readonly) NSString *filePath;

- (void)processBuffer:(UInt8 *)buffer withSize:(int)size;

@end

NS_ASSUME_NONNULL_END
