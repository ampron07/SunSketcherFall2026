//
//  OpenCVWrapper.h
//  Sunsketcher
//
//  Created by Kelly Miller on 2/23/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (NSString *)getOpenCVVersion;
+ (UIImage *)makeUIImageGrayScale:(UIImage *)image;
+ (UIImage *)croppingUIImage:(UIImage *)image withCoords:(NSArray<NSNumber *> *)boxCoords;
+ (NSArray<NSNumber *> *)getEclipseBox:(UIImage *)img;

@end

NS_ASSUME_NONNULL_END

