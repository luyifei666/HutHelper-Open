//
//  UserViewController.m
//  HutHelper
//
//  Creatde by nine on 2016/11/19.
//  Copyright © 2016年 nine. All rights reserved.
//

#import "UserViewController.h"
#import "JSHeaderView.h"
#import "UserInfoCell.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "MBProgressHUD+MJ.h"
#import "YYModel.h"
#import "User.h"
static NSString *const kUserInfoCellId = @"kUserInfoCellId";

@interface UserViewController () <UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, copy)NSString *m_auth;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JSHeaderView *headerView;
@end

@implementation UserViewController
UIImage* img ;
- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //    NSString *path_document = NSHomeDirectory();
    //    NSString *imagePath = [path_document stringByAppendingString:@"/img/pic.jpg"];//把图片直接保存到指定的路径
    //    UIImage *getimage2 = [UIImage imageWithContentsOfFile:imagePath];
    //
    NSDictionary *User_Data=[defaults objectForKey:@"User"];
    User *user=[User yy_modelWithJSON:User_Data];
    if ([defaults objectForKey:@"head_img"]!=NULL) {
        self.headerView = [[JSHeaderView alloc] initWithImage:[UIImage imageWithData:[defaults objectForKey:@"head_img"]]];
    }
    else if(user.head_pic_thumb!=NULL){
        NSString *image_url=user.head_pic_thumb;
        image_url=[@"http://218.75.197.121:8888/" stringByAppendingString:image_url];
        NSURL *url                   = [NSURL URLWithString: image_url];//接口地址
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data!=NULL&&![image_url isEqualToString:@"http://218.75.197.121:8888/"]) {
            [defaults setObject:data forKey:@"head_img"];
            [defaults synchronize];
            self.headerView = [[JSHeaderView alloc] initWithImage:[UIImage imageWithData:data]];
        }
        else{
            self.headerView = [[JSHeaderView alloc] initWithImage:[UIImage imageNamed:@"header.jpg"]];
        }
    }
    else{
        self.headerView = [[JSHeaderView alloc] initWithImage:[UIImage imageNamed:@"header.jpg"]];
    }
    
    
    [self.headerView reloadSizeWithScrollView:self.tableView];
    self.navigationItem.titleView = self.headerView;
    
    [self.headerView handleClickActionWithBlock:^{
        [self getImageFromIpc];
        
    }];

    /** 标题栏样式 */
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}
- (void)getImageFromIpc
{
    // 1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    // 2. 创建图片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    /**
     typedef NS_ENUM(NSInteger, UIImagePickerControllerSourceType) {
     UIImagePickerControllerSourceTypePhotoLibrary, // 相册
     UIImagePickerControllerSourceTypeCamera, // 用相机拍摄获取
     UIImagePickerControllerSourceTypeSavedPhotosAlbum // 相簿
     }
     */
    // 3. 设置打开照片相册类型(显示所有相簿)
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    // 照相机
    // ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    // 4.设置代理
    ipc.delegate = self;
    // 5.modal出这个控制器
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark -- <UIImagePickerControllerDelegate>--
// 获取图片后的操作
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    img = info[UIImagePickerControllerEditedImage]; //获得修改后
    // img = [info objectForKey:UIImagePickerControllerOriginalImage];   //获得原图
    NSData *imageData = UIImageJPEGRepresentation(img,1.0);
    int length = [imageData length]/1024;
    if (length<=2500) {
        [self postimage:img];
    }
    else{
        UIAlertView *alertView                    = [[UIAlertView alloc] initWithTitle:@"头像大小过大"
                                                                               message:@"请重新选择"
                                                                              delegate:self
                                                                     cancelButtonTitle:@"取消"
                                                                     otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}
NSData* data;
- (void)postimage:(UIImage *)img
{
    

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *User_Data=[defaults objectForKey:@"User"];
    User *user=[User yy_modelWithJSON:User_Data];

    
    NSString *url_String=[NSString stringWithFormat:@"http://218.75.197.121:8888/api/v1/set/avatar/%@/%@",user.studentKH,[defaults objectForKey:@"remember_code_app"]];

    NSURL* url = [NSURL URLWithString:url_String];//请求url
    // UIImage* img = [UIImage imageNamed:@"header.jpg"];
    data = UIImagePNGRepresentation(img);
    //ASIFormDataRequest请求是post请求，可以查看其源码
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    request.tag = 20;
    request.delegate = self;
    [request setPostValue:self.m_auth forKey:@"m_auth"];
    //    [request setFile:@"tabbar.png" forKey:@"haoyou"];//如果有路径，上传文件
    [request setData:data  withFileName:@"header.jpg" andContentType:@"image/jpg" forKey:@"file"];
    //               数据                文件名,随便起                 文件类型            设置key
    
    
    [request startAsynchronous];

    [request setDidFinishSelector:@selector(postsucces)];//当成功后会自动触发 headPortraitSuccess 方法
    [request setDidFailSelector:@selector(postfailure)];//如果失败会 自动触发 headPortraitFail 方法
    [MBProgressHUD showMessage:@"上传中" toView:self.view];
    // [request startSynchronous];
}

-(void)postsucces{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD showSuccess:@"上传成功"];
    [defaults setObject:data forKey:@"head_img"];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -2)] animated:YES];  //返回Home
    
}

-(void)postfailure{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD showError:@"上传失败"];
}

#pragma mark -
#pragma mark - tableView protocal methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 183.f;
    }
    return 85.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *User_Data=[defaults objectForKey:@"User"];
    User *user=[User yy_modelWithJSON:User_Data];

    NSString *TrueName=user.TrueName; //真实姓名
    NSString *studentKH=user.studentKH; //学号
    NSString *dep_name=user.dep_name; //学院
    NSString *class_name=user.class_name;  //班级
    NSString *sex=user.sex;  //性别
    if(sex ==NULL){
        sex=@"";
    }
    if (indexPath.row == 0) {
        UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoCellId];
        if (!cell) {
            cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kUserInfoCellId];
        }
        return cell;
    }
    if(indexPath.row == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reUse" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"姓名:%@", TrueName];
        return cell;
    }
    if(indexPath.row == 2){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reUse" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"性别:%@", sex];
        return cell;
    }
    if(indexPath.row == 3){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reUse" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"学号:%@", studentKH];
        return cell;
    }
    if(indexPath.row == 4){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reUse" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"学院:%@", dep_name];
        return cell;
    }
    if(indexPath.row == 5){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reUse" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"班级:%@", class_name];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reUse" forIndexPath:indexPath];
    return cell;
    // cell.textLabel.text = [NSString stringWithFormat:@"ro %zd", indexPath.row];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
@end
