//
//  DiskBufferingDataSource.m
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import "DiskBufferingDataSource.h"

@interface DiskBufferingDataSource ()

@property (nonatomic, strong, readwrite) DiskBuffer *diskBuffer;

@end

@implementation DiskBufferingDataSource

- (DiskBuffer *)diskBuffer
{
    if (!_diskBuffer) {
        _diskBuffer = [[DiskBuffer alloc] init];
    }
    return _diskBuffer;
}

- (int)readIntoBuffer:(UInt8 *)buffer withSize:(int)size
{
    int read = [super readIntoBuffer:buffer withSize:size];

    if (self.enabled) {
        [self __hookBuffer:buffer withSize:size];
    }

    return read;
}

- (void)__hookBuffer:(UInt8 *)buffer withSize:(int)size
{

    [self.diskBuffer processBuffer:buffer withSize:size];
}

@end
