//
//  MusicQueue+Provider.m
//  MTDouAsTest
//
//  Created by TomWu on 16/7/7.
//  Copyright © 2016年 TomWu_wxd. All rights reserved.
//

#import "MusicQueue+Provider.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MusicQueue(Provider)


//初始化时单次初始化扫描本地、远端
+ (void)load
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self remoteQueue];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self musicLibraryQueue];
    });
}


//预请求播放网络库或本地库的曲目，欲请求一遍歌单列表获取曲目，url
+ (NSArray *)remoteQueue
{
    static NSArray *tracks = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tracks = [self onlineQueue];
    });
    
    return tracks;
}

//本地曲库查询,初始化时扫描一遍本地曲库
+ (NSArray *)musicLibraryQueue
{
    static NSArray *tracks = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tracks = [self localQueue];
    });
    
    return tracks;
}

+ (NSArray *)localQueue{
    
    static NSArray *tracks = nil;
    NSMutableArray *allTracks = [NSMutableArray array];
    NSString *path = [NSString stringWithFormat:@"%@/Documents/Cache/",NSHomeDirectory()];//沙盒
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *arr = [mgr subpathsOfDirectoryAtPath:path error:nil];
    
    if (arr) {
        for ( long int i = arr.count-1; i>=0 ;i--) {
            MusicQueue *musicQueue = [[MusicQueue alloc] init];
            
            NSString *allPath = [NSString stringWithFormat:@"%@%@",path,arr[i]];
            [musicQueue setTitle:arr[i]];
            NSURL *url = [NSURL fileURLWithPath:allPath];
            [musicQueue setAudioFileURL:url];
            [allTracks addObject:musicQueue];

        }
    }
    tracks = [allTracks copy];
    return tracks;
    
}

+ (NSArray *)onlineQueue{
    
    static NSArray *tracks = nil;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://oakbcmhd4.bkt.clouddn.com/music_list2.txt"]];
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:NULL
                                                         error:NULL];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    NSMutableArray *allTracks = [NSMutableArray array];
    
    for (NSDictionary *data in [dict objectForKey:@"data"]) {
        MusicQueue *musicQueue = [[MusicQueue alloc] init];
    
        [musicQueue setArtist:[data objectForKey:@"artist"]];
        [musicQueue setTitle:[data objectForKey:@"title"]];
        [musicQueue setAudioFileURL:[NSURL URLWithString:[data objectForKey:@"music_url"]]];
        [allTracks addObject:musicQueue];
    }
    
    tracks = [allTracks copy];
    return tracks;
}

@end
