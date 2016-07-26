//
//  MusicListViewController.m
//  MTDouAsTest
//
//  Created by TomWu on 16/7/11.
//  Copyright © 2016年 TomWu_wxd. All rights reserved.
//

#import "MusicListViewController.h"
#import "PlayViewController.h"
#import "MusicListCellTableViewCell.h"
#import "MusicQueue+Provider.h"
#import "MBProgressHUD.h"

@interface MusicListViewController ()

@property (nonatomic, copy) NSMutableArray *data;

@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"MusicListCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"musicListCell"];
     [self resetData];
}

#pragma mark - TableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 57;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     MusicListCellTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"musicListCell" forIndexPath:indexPath];
    cell.musicNumber = indexPath.row + 1;
    if (self.remote) {
        MusicQueue *musicQueue = _data[indexPath.row];
        NSLog(@"数据%@",musicQueue);
        cell.musicTitleLabel.text = musicQueue.title;
        cell.musicArtistLabel.text = musicQueue.artist;
    }else{
        MusicQueue *musicQueue = _data[indexPath.row];
        cell.musicTitleLabel.text = musicQueue.title;
        cell.musicArtistLabel.text = nil;
    }

    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PlayViewController *playViewController = [[PlayViewController alloc]init];
    [playViewController setCurrentTrackIndex:indexPath.row];
    if (self.remote) {
        
        [playViewController setTitle:@"Remote Music ♫"];
        [playViewController setMusicQueue:[MusicQueue remoteQueue]];
    }else{
        
        [playViewController setTitle:@"Local Music Library ♫"];
        [playViewController setMusicQueue:[MusicQueue localQueue]];
    }
    [[self navigationController] pushViewController:playViewController
                                           animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_remote) {
        return NO;
    }else{
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete && !_remote) {
        [self removeLocalMusic:indexPath];
        _data = (NSMutableArray *)[MusicQueue localQueue];
        [self.tableView reloadData];
    }
}

- (void)removeLocalMusic:(NSIndexPath *)indexPath{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *path = [NSString stringWithFormat:@"%@/Documents/Cache/",NSHomeDirectory()];
    NSArray *arr = [manager subpathsOfDirectoryAtPath:path error:nil];
    NSString *allPath = [NSString stringWithFormat:@"%@%@",path,arr[indexPath.row]];
    if ([manager removeItemAtPath:allPath error:nil]) {
        NSLog(@"删除成功！");
    }else{
        NSLog(@"删除失败");
    }
    
}

#pragma mark - private Methods

- (void)resetData{
    
    if (_remote) {
        if (self.musicList.count == 0) {
            [self showMiddleHint:@"暂无在线歌曲播放"];
        } else {
            _data = (NSMutableArray *)self.musicList;
            NSLog(@"数据输出%@",_data);
        }
    } else {
        [self localReload];
    }
}

- (void)localReload{
    if (!_remote) {
        self.data = (NSMutableArray *)[MusicQueue localQueue];
        NSLog(@"输出%@",self.data);
        if (self.data.count == 0) {
            [self showMiddleHint:@"暂无本地歌曲播放"];
        }else{
            [self.tableView reloadData];
        }
    }
}

#pragma mark - HUD
- (void)showMiddleHint:(NSString *)hint {
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.labelFont = [UIFont systemFontOfSize:15];
    hud.margin = 10.f;
    hud.yOffset = 0;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
}


@end
