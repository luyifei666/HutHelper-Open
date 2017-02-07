//
//  HomeWorkViewController.m
//  HutHelper
//
//  Created by nine on 2016/10/10.
//  Copyright © 2016年 nine. All rights reserved.
//

#import "HomeWorkViewController.h"
#import "UMMobClick/MobClick.h"
#import "MBProgressHUD+MJ.h"
#import "YYModel.h"
#import "User.h"
@interface HomeWorkViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *views;

@end

@implementation HomeWorkViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"网上作业";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *User_Data=[defaults objectForKey:@"User"];
    User *user=[User yy_modelWithJSON:User_Data];
    NSString *Url_String=[NSString stringWithFormat:@"http://218.75.197.121:8888/api/v1/get/myhomework/%@/%@",user.studentKH,[defaults objectForKey:@"remember_code_app"]];
    NSURL *url                = [[NSURL alloc]initWithString:Url_String];
    _views.delegate=self;
    [_views loadRequest:[NSURLRequest requestWithURL:url]];
    
    [MBProgressHUD showMessage:@"加载中" toView:self.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

    - (void)viewWillAppear:(BOOL)animated
 {
 [super viewWillAppear:animated];
 [MobClick beginLogPageView:@"网上作业"];//("PageOne"为页面名称，可自定义)
 }
 - (void)viewWillDisappear:(BOOL)animated
 {
 [super viewWillDisappear:animated];
 [MobClick endLogPageView:@"网上作业"];
 }
/** webView的代理方法*/
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //隐藏显示
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD showError:@"网络错误"];
}
@end
