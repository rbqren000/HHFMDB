//
//  ModelTool.h
//  MyFMDB
//
//  Created by 崔辉辉 on 2018/7/20.
//  Copyright © 2018年 huihui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHFMDBUtil : NSObject

+ (NSString *)dbPathForName:(NSString *)name;

/**
 存储类型转为字典

 @param parameters 存储数据的类型
 @return 存储数据的类型
 */
+ (NSDictionary *)storageTypeTodictionary:(id)parameters;

/**
 模型转Class 获取model的类

 @param parameters <#parameters description#>
 @return <#return value description#>
 */
+ (Class)getModelClass:(id)parameters;

/**
 获取model属性的key和value

 @param model <#model description#>
 @param clomnArr <#clomnArr description#>
 @return <#return value description#>
 */
+ (NSDictionary *)getModelPropertyKeyValue:(id)model
                                  clomnArr:(NSArray *)clomnArr;

+ (NSString *)getFileName:(NSString *)filePath;

@end
