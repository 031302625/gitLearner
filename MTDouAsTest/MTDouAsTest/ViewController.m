//
//  ViewController.m
//  MTDouAsTest
//
//  Created by TomWu on 16/7/7.
//  Copyright © 2016年 TomWu_wxd. All rights reserved.
//

#import "ViewController.h"
#import "PlayViewController.h"
#import "MusicQueue+Provider.h"
#import "MusicListViewController.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainView;//菜单界面

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainView.delegate = self;
    self.mainView.dataSource = self;
    self.navigationItem.title = @"♫♫♫";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kCellIdentifier = @"MainViewController_CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    switch ([indexPath row]) {
        case 0:
            [[cell textLabel] setText:@"Remote Music(在线)"];
            break;
            
        case 1:
            [[cell textLabel] setText:@"Local Music Library(本地)"];
            break;
            
        default:
            abort();
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MusicListViewController *musicListVC = [[MusicListViewController alloc]init];
    
    switch ([indexPath row]) {
        case 0:
            [musicListVC setTitle:@"Remote Music ♫"];
            [musicListVC setRemote:YES];
            [musicListVC setMusicList:[MusicQueue remoteQueue]];
            break;
            
        case 1:
            [musicListVC setTitle:@"Local Music Library ♫"];
            [musicListVC setRemote:NO];
            [musicListVC setMusicList:[MusicQueue musicLibraryQueue]];
            break;
            
        default:
            abort();
    }
    
    [[self navigationController] pushViewController:musicListVC
                                           animated:YES];
}

@end
