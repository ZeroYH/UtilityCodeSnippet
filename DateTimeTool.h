//
//  NSDateTimeTool.h
//  PaperScan
//
//  Created by YRH on 2019/1/5.
//  Copyright © 2019 SpiderMan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateTimeTool : NSObject

+(NSDateComponents *)getDateComponents:(NSDate *)date;
+(NSInteger)getWeek_AccordingToYear:(NSInteger)year;
+(NSString*)getWeekRangeDate_Year:(NSInteger)year WeakOfYear:(NSInteger)weekofYear;
+(NSDateComponents *)getCurrentDateComponents;
+(NSInteger)getCurrentWeek;
+(NSInteger)getCurrentYear;
+(NSInteger)getCurrentQuarter;
+(NSInteger)getCurrentMonth;
+(NSInteger)getCurrentDay;
+(NSDate *)dateFromString:(NSString *)dateString DateFormat:(NSString *)DateFormat;
+(NSString *)stringFromDate:(NSDate *)date DateFormat:(NSString *)DateFormat;
+(NSString *)dateByAddingTimeInterval:(NSTimeInterval)TimeInterval DataTime:(NSString *)dateStr DateFormat:(NSString *)DateFormat;
+(NSString *)getDataTime:(NSString *)dateStr DateFormat:(NSString *)DateFormat;
+(NSString *)getDataTime:(NSString *)dateStr DateFormat:(NSString *)DateFormat oldDateFormat:(NSString *)oldDateFormat;
+(int)getNumberOfCharactersInString:(NSString *)str c:(char)c;
+(NSString *)getFormat:(NSString *)dateString;
+(NSString *)interceptTimeStampFromStr:(NSString *)string DateFormat:(NSString *)DateFormat;

+ (NSInteger)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay format:(NSString *)formatl;

@end

NS_ASSUME_NONNULL_END
