//
//  LuaObjcFun.mm
//  hotupdate
//
//  Created by yangtao on 14-12-26.
//
//

#import "LuaObjcFun.h"

using namespace cocos2d;

@implementation LuaObjcFun

+ (int) getAppVersionCode
{
    NSDictionary *bundleDic = [[NSBundle mainBundle] infoDictionary];
    NSString* versionCode = [bundleDic objectForKey:@"CFBundleVersion"];
    return [versionCode intValue];
}

@end
