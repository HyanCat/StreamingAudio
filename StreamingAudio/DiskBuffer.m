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
//    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *directory = [NSString stringWithFormat:@"%@/audios", NSTemporaryDirectory()];
    NSString *file = [NSString stringWithFormat:@"%@/%d", directory, (int)[NSDate date].timeIntervalSince1970];
    NSLog(@"file: %@", file);
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];

    return file;
}

@end
