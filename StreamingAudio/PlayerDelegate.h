//
//  PlayerDelegate.h
//  StreamingAudio
//
//  Created by HyanCat on 09/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import "Player.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlayerDelegate : NSObject

@property (nonatomic, weak, readonly) __kindof Player *player;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPlayer:(__kindof Player *)player;

@end

NS_ASSUME_NONNULL_END
