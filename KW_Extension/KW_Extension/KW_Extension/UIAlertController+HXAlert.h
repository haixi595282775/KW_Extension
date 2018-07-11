//
//  UIAlertController+HXAlert.h
//  KW_Extension
//
//  Created by TAL on 2018/7/11.
//  Copyright © 2018年 Udo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (HXAlert)

- (void)hx_addActions:(NSArray <UIAlertAction *>*)actions;

- (void)hx_show;

@end
