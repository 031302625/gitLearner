//
//  MusicQueue+Provider.h
//  MTDouAsTest
//
//  Created by TomWu on 16/7/7.
//  Copyright © 2016年 TomWu_wxd. All rights reserved.
//

#import "MusicQueue.h"

@interface MusicQueue(Provider)

+ (NSArray *)remoteQueue;
+ (NSArray *)musicLibraryQueue;

//本地、远端曲目队列信息更新
+ (NSArray *)localQueue;
+ (NSArray *)onlineQueue;

@end
