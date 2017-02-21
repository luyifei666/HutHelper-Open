//
//  Config.h
//  HutHelper
//
//  Created by nine on 2017/2/10.
//  Copyright © 2017年 nine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HUTAPI.h"

#define HideAllHUD  [MBProgressHUD hideHUDForView:self.view animated:YES];
@interface Config : NSObject

+ (void)setIsxp:(int )Isxp;
+ (int )getIsxp;

+ (void)setIssay:(int )Issay;
+ (int )getIssay;
@end
