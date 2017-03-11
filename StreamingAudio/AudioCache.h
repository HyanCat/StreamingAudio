//
//  AudioCache.h
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AudioCacheUnit;

typedef void(^AudioCacheCompletion)(AudioCacheUnit *unit);

@protocol AudioCacheProtocol <NSObject>

+ (instancetype)sharedCache;

- (NSArray <AudioCacheUnit *> *)cachedAudios;

- (void)cacheAudioWithURL:(NSURL *)url finished:(AudioCacheCompletion)finished;
- (nullable AudioCacheUnit *)cachedAudioWithURL:(NSURL *)url;
- (void)cancelCacheAudioWithURL:(NSURL *)url;

@end

@interface AudioCacheUnit : NSObject

@property (nonatomic, copy) NSURL *location;

@end

@interface AudioCache : NSObject <AudioCacheProtocol>

@end

NS_ASSUME_NONNULL_END
