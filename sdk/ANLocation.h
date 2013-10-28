//
//  ANLocation.h
//  Demo
//
//  Created by Mark Ha on 10/10/13.
//
//

#import <Foundation/Foundation.h>

@interface ANLocation : NSObject

@property (nonatomic, readwrite, assign) CGFloat latitude;
@property (nonatomic, readwrite, assign) CGFloat longitude;
@property (nonatomic, readwrite, strong) NSDate * timestamp;
@property (nonatomic, readwrite, assign) CGFloat horizontalAccuracy;

+ (ANLocation *)getLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                  timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy;

@end
