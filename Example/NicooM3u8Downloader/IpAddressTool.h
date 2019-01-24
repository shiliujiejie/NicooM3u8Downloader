//
//  IpAddressTool.h
//  NicooM3u8Downloader_Example
//
//  Created by pro5 on 2019/1/22.
//  Copyright © 2019年 CocoaPods. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IpAddressTool : NSObject
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
@end

NS_ASSUME_NONNULL_END
