//
//  VedioTableViewController.m
//  HutHelper
//
//  Created by nine on 2017/4/2.
//  Copyright © 2017年 nine. All rights reserved.
//

#import "VedioTableViewController.h"
#import "VedioTableViewCell.h"
#import "VedioTopTableViewCell.h"
#import "VedioModel.h"
@interface VedioTableViewController ()

@end

@implementation VedioTableViewController{
    NSMutableArray *datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"视频专栏";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSDictionary *Dic=[Config getVedio];
    [self loadData:Dic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{  //多少块
    return datas.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{//每块几部分
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{///每块的高度
    if (indexPath.section==0) {
        return 228;
    }
    return 143;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.00001;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        VedioTopTableViewCell *topCell = [tableView dequeueReusableCellWithIdentifier:@"VedioTopTableViewCell"];
        if (!topCell) {
            topCell = (VedioTopTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"VedioTopTableViewCell" owner:self options:nil] lastObject];
        }
        VedioTopTableViewCell *cellTop=[[VedioTopTableViewCell alloc]init];
        return topCell;
    }else{
        
        static NSString *cellIndentifier=@"VedioTableViewCell";
        VedioTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"VedioTableViewCell"];
        if (!cell) {
            cell=[[VedioTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        }else{
            while ([cell.contentView.subviews lastObject]) {
                [(UIView*)[cell.contentView.subviews lastObject]removeFromSuperview];
            }
        }
        [self drawCell:cell withIndexPath:indexPath];
        
        return cell;
    }
}
-(void)drawCell:(VedioTableViewCell*)cell withIndexPath:(NSIndexPath *)indexPath{
    
    cell.data=datas[indexPath.section-1];
    [cell drawLeft];
}
#pragma mark - 处理数据
-(void)loadData:(NSDictionary*)JSONDic{
    datas=[[NSMutableArray alloc]init];
    for (NSDictionary *eachDic in JSONDic) {
        VedioModel *momentsModel=[[VedioModel alloc]initWithDic:eachDic];
        [datas addObject:momentsModel];
    }
}
@end
