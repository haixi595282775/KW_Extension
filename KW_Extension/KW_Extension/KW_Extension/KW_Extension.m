//
//  KW_Extension.m
//  KW_Extension
//
//  Created by LKW on 2018/5/31.
//  Copyright © 2018年 Udo. All rights reserved.
//

#import "KW_Extension.h"
#import "KW_Function.h"
#import "UIView+HXFrame.h"
#import <objc/runtime.h>

@implementation KW_Extension

@end

#pragma mark  UIDevice 

@implementation UIDevice (HXDeviceInfo)

+ (NSString *)appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBuildVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)UUID
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString *)projectName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

+ (NSString *)bundleIdentifier
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

+ (NSString *)deviceVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

@end

#pragma mark  NSObject 

@implementation NSObject (KW_Object)

+ (NSString *)kClassName
{
    return NSStringFromClass(self);
}

- (void)kw_resignFirstResponder
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

@end

#pragma mark  UIView 

@implementation UIView (KW_View)

- (NSArray<UIView *> *)allSubViews
{
    return [self kw_allSubViews];
}

- (UIImage *)kw_screenShot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (NSArray *)kw_allSubViews
{
    NSMutableArray * views = [[NSMutableArray alloc] initWithCapacity:0];
    [self kw_ergodicSubView:self views:views];
    return views;
}

- (NSMutableArray *)kw_viewsWithSubView:(UIView *)view views:(NSMutableArray *)views
{
    if (view == nil) {
        return views;
    } else if (!view.subviews.count) {
        [views addObject:view];
    } else {
        [views addObject:view];
        [self kw_ergodicSubView:view views:views];
    }
    return views;
}

- (void)kw_ergodicSubView:(UIView *)view views:(NSMutableArray *)views
{
    for (UIView * subView in view.subviews) {
        [self kw_viewsWithSubView:subView views:views];
    }
}


@end

#pragma mark  UIColor 

@implementation UIColor (KW_Color)

+ (UIColor *)KWColorWithHexString:(NSString *)hexString
{
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#"withString: @""] uppercaseString];
    
    CGFloat alpha, red, blue, green;
    
    switch ([colorString length]) {
            
        case 3: // #RGB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            
            break;
            
        case 4: // #ARGB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            
            break;
            
        case 6: // #RRGGBB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            
            break;
            
        case 8: // #AARRGGBB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            
            break;
            
        default:
            
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            
            break;
            
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    
    return hexComponent / 255.0;
    
}

+ (UIColor *)colorOfPoint:(CGPoint)point layer:(CALayer *)layer
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);
    [layer renderInContext:context];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIColor * color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    return color;
}

@end


#pragma mark  NSString 

#include <time.h>

@implementation NSString (KW_String)

- (BOOL)isEmpty
{
    return (self.length == 0 || [self isEqual:[NSNull null]]);
}

- (BOOL)isPhoneNumber
{
    NSString * regex = @"^134[0-8]\\d{7}$|^13[^4]\\d{8}$|^14[5-9]\\d{8}$|^15[^4]\\d{8}$|^16[6]\\d{8}$|^17[0-8]\\d{8}$|^18[\\d]{9}$|^19[8,9]\\d{8}$";
    return [self kw_predicateWithString:regex];
}

- (BOOL)isIDCard
{
    return [self kw_predicateWithString:@"^(\\d{14}|\\d{17})(\\d|[xX])$"];
}

- (BOOL)isNumber
{
    return [self kw_predicateWithString:@"^[0-9]+(\\.[0-9]{1,2})?$"];
}

- (NSString *)base64Encode
{
    return KWEncodeBase64(self);
}

- (id)base64Decode
{
    return KWDecodeBase64(self);
}

- (CGSize)kw_sizeWithFont:(CGFloat)font size:(CGSize)size bold:(BOOL)bold
{
    UIFont * ft = nil;
    if (bold) {
        ft = [UIFont boldSystemFontOfSize:font];
    } else {
        ft = [UIFont systemFontOfSize:font];
    }
    return [self boundingRectWithSize:size
                              options:(NSStringDrawingOptions)0
                           attributes:@{NSFontAttributeName: ft}
                              context:nil].size;
}

- (NSString *)kw_dateStringToTimestamp:(NSString *)format
{
    NSDateFormatter * formatter = NSDateFormatter.kDateFormatter;
    formatter.dateFormat = format;
    NSDate * date = [formatter dateFromString:self];
    return [NSString stringWithFormat:@"%.f", [date timeIntervalSince1970]];
}

- (NSString *)kw_timestampToDateString:(NSString *)format
{
    NSTimeInterval time = [self doubleValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter * formatter = NSDateFormatter.kDateFormatter;
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

- (NSString *)kw_dateToAnotherDate:(NSString *)format toFormat:(NSString *)anotherFormat
{
    NSString * timestamp = [self kw_dateStringToTimestamp:format];
    return [timestamp kw_timestampToDateString:anotherFormat];
}

+ (NSString *)kw_todayDate:(NSString *)format
{
    NSTimeInterval today = [[NSDate date] timeIntervalSince1970];
    NSString * todayString = [NSString stringWithFormat:@"%.f", today];
    return [todayString kw_timestampToDateString:format];
}

- (BOOL)kw_predicateWithString:(NSString *)regex
{
    if (self.isEmpty) { return NO;}
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@", regex];
    return [predicate evaluateWithObject:self];
}

- (NSString *)kw_format:(NSString *)format roundingMode:(NSNumberFormatterRoundingMode)mode
{
    NSNumber * number = [NSNumber numberWithDouble:[format doubleValue]];
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    formatter.positiveFormat = format;
    formatter.roundingMode = mode;
    return [formatter stringFromNumber:number];
}

- (nullable NSDictionary *)kw_parametersFromURL
{
    return KWParametersFromURL(self);
}

- (NSArray<NSValue *> *)hx_allRangesWithSubString:(NSString *)subString
{
    NSAssert(self.length != 0, @"%@不能为空", self);
    NSAssert(subString.length != 0, @"%@不能为空", subString);
    NSMutableArray * ranges = [[NSMutableArray alloc] initWithCapacity:0];
    NSRegularExpression * regular = [NSRegularExpression regularExpressionWithPattern:subString
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:nil];
    NSArray * array = [regular matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    for (NSTextCheckingResult * result in array) {
        [ranges addObject:[NSValue valueWithRange:result.range]];
    }
    return ranges;
}

@end

#pragma mark  NSArray 

@implementation NSArray (KW_Array)

- (id)anyObject
{
    if (!self.count) { return nil;}
    if (self.count == 1) { return [self firstObject];}
    NSInteger idx = arc4random() % self.count;
    return [self objectAtIndex:idx];
}

- (NSString *)base64Encode
{
    return KWEncodeBase64(self);
}

- (NSArray *)kw_allObjects
{
    if (!self.count) { return @[];}
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    [self kw_objectInArray:self toArray:array];
    return array;
}

- (void)kw_objectInArray:(NSArray *)array toArray:(NSMutableArray *)toArray
{
    for (id element in array) {
        if ([element isKindOfClass:[self class]]) {
            [self kw_objectInArray:element toArray:toArray];
        } else {
            [toArray addObject:element];
        }
    }
}

@end

#pragma mark  NSDictionary 

@implementation NSDictionary (KW_Dictionary)

- (NSString *)base64Encode
{
    return KWEncodeBase64(self);
}

@end

#pragma mark  NSDateFormatter 

@implementation NSDateFormatter (KW_DateFormatter)

+ (NSDateFormatter *)kDateFormatter
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = NSTimeZone.systemTimeZone;
    return formatter;
}

@end

#pragma mark  UIAlertController 

@implementation UIAlertController (HXAlert)

- (void)hx_addActions:(NSArray<UIAlertAction *> *)actions
{
    [actions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addAction:obj];
    }];
}

- (void)hx_show
{
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:self
                                                                                             animated:YES
                                                                                           completion:nil];
}

@end


#pragma mark  UIViewController 

#import "NSObject+KW_MethodSwizzling.h"

@implementation UIViewController (HXPresentViewController)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self methodSwizzlingWithOriginalSelector:@selector(presentViewController:animated:completion:)
                               bySwizzledSelector:@selector(hx_presentViewController:animated:completion:)];
    });
}

- (void)hx_presentViewController:(UIViewController *)viewControllerToPresent
                        animated:(BOOL)flag
                      completion:(void (^)(void))completion
{
    if (self != viewControllerToPresent) {
        [KWCurrentVisibleViewController() hx_presentViewController:viewControllerToPresent
                                                          animated:flag
                                                        completion:completion];
    } else {
        NSLog(@"could not use %@ present %@", NSStringFromClass([self class]),
               NSStringFromClass([viewControllerToPresent class]));
    }
}

@end




