//
//  DiskBuffer.m
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import "DiskBuffer.h"

@interface DiskBuffer ()
{
    NSFileHandle *_fileHandle;
}

@property (nonatomic, copy, readwrite) NSString *filePath;

@end

@implementation DiskBuffer

- (void)dealloc
{
    [_fileHandle closeFile];
    [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _filePath = [self __localFilePath];
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    }
    return self;
}

- (void)processBuffer:(UInt8 *)buffer withSize:(int)size
{
    [_fileHandle writeData:[NSData dataWithBytes:buffer length:size]];
}

- (NSString *)__localFilePath
{
    NSURL *directory = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] URLByAppendingPathComponent:@"buffers" isDirectory:YES];
    NSString *fileName = [NSString stringWithFormat:@"%d", (int)[NSDate date].timeIntervalSince1970];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSURL *fileURL = [directory URLByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] createFileAtPath:fileURL.path contents:nil attributes:nil];

    return fileURL.path;
}

@end
