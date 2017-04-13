//
//  Player.h
//  StreamingAudio
//
//  Created by HyanCat on 09/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

@import Foundation;
@import StreamingKit;
#import "FrequencyOutputEntry.h"
#import "AudioCache.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PlayerProtocol <NSObject>

@end

typedef NS_ENUM(NSUInteger, PlayerState) {
    PlayerStateError = -1,
    PlayerStateNone = 0,
    PlayerStatePlaying,
    PlayerStatePausing,
    PlayerStateStopped,
};

typedef NS_ENUM(NSUInteger, PlayerMode) {
    PlayerModeOnce = 0,
    PlayerModeSingle,
    PlayerModeLoop,
    PlayerModeRandom,
};

@interface Player : NSObject <PlayerProtocol>

+ (instancetype)default;

@property (nonatomic, copy, readonly) NSString *queueID;
@property (nonatomic, strong, readonly) STKAudioPlayer *audioPlayer;
@property (nonatomic, assign) Float32 volume;
@property (nonatomic, assign, readonly) PlayerState state;
@property (nonatomic, assign) PlayerMode mode;

@property (nonatomic, assign) BOOL enableCache;
@property (nonatomic, copy, nullable, readonly) NSURL *current;

- (void)play:(NSURL *)url;
- (void)queue:(NSURL *)url;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)replay;

- (void)appendFrequencyOutputName:(NSString *)name output:(FrequencyOutput)output;
- (void)removeFrequencyOutputName:(NSString *)name;


@property (nonatomic, assign, readonly) id <AudioCacheProtocol> cache;

@end

NS_ASSUME_NONNULL_END
