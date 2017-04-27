//
//  PlayerDelegate.m
//  StreamingAudio
//
//  Created by HyanCat on 09/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import "PlayerDelegate.h"
@import StreamingKit;

@interface PlayerDelegate () <STKAudioPlayerDelegate>

@property (nonatomic, weak, readwrite) __kindof Player *player;

@end

@implementation PlayerDelegate

- (instancetype)initWithPlayer:(__kindof Player *)player
{
    self = [super init];
    if (self) {
        _player = player;
    }
    return self;
}

#pragma makr - Delegate

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer logInfo:(NSString *)line
{

}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didStartPlayingQueueItemId:(NSObject *)queueItemId
{

}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{

}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject *)queueItemId
{

}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    switch (stopReason) {
        case STKAudioPlayerStopReasonNone:
            [self performSelector:@selector(__fixStopNone:) withObject:audioPlayer afterDelay:0.1];
            break;
        case STKAudioPlayerStopReasonEof:
            [self __finished];
            break;
        default:
            break;
    }
}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{

}

- (void)__fixStopNone:(STKAudioPlayer *)player
{
    if (player.stopReason == STKAudioPlayerStopReasonEof) {
        [self __finished];
    }
}

- (void)__finished
{
    switch (self.player.mode) {
        case PlayerModeOnce:
            [self.player stop];
            break;
        case PlayerModeSingle:
            [self.player replay];
            break;
        case PlayerModeLoop:
        case PlayerModeRandom:
        default:
            break;
    }
}

@end
