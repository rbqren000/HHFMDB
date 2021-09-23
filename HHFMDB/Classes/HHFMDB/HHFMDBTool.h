//
//  HHFMDBTool.h
//  MyFMDB
//
//  Created by 崔辉辉 on 2018/7/20.
//  Copyright © 2018年 huihui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHFMDBTool : NSObject

+ (nonnull instancetype)sharedTool;


/**
 切换（创建）数据库
 */
+ (FMDatabase *)defaultDatabase;

/**
 切换（创建）数据库

 @param dbName 数据库名
 */
+ (FMDatabase *)databaseWithName:(NSString *)dbName;

/**
 切换（创建）数据库
 */
+ (FMDatabaseQueue *)defaultDatabaseQueue;

/**
 切换（创建）数据库
 
 @param dbName 数据库名
 */
+ (FMDatabaseQueue *)databaseQueueWithName:(NSString *)dbName;



/**
 创建表

 @param tableName 表名
 @param parameters 存储的model或字典类型
 @param nameArr 不保存到数据库 model中的属性或者字典的键值对
 @return <#return value description#>
 */
- (BOOL)createTableWithTableName:(NSString *)tableName
                      dicOrModel:(id)parameters
                     excludeName:(NSArray * _Nullable)nameArr
                              db:(FMDatabase * _Nonnull)db;

- (BOOL)createTableWithTableName:(NSString *)tableName
                      dicOrModel:(id)parameters
                     excludeName:(NSArray * _Nullable)nameArr
                              db:(FMDatabase * _Nonnull)db
                   primaryKeyDic:(NSDictionary * _Nullable)primaryKeyDic;

/**
 插入数据（支持插入一个数据或者一个数组）

 @param tableName 表名
 @param dataSource <#dataSource description#>
 @param db <#db description#>
 */
- (void)insertWithTableName:(NSString *)tableName
                 dataSource:(id)dataSource
                         db:(FMDatabase * _Nonnull)db;

/**
 删除数据

 @param tableName 表名
 @param whereFormat 删除的条件
 */
- (BOOL)deleteDatabase:(FMDatabase * _Nonnull)db Table:(NSString *)tableName whereFormat:(NSString *)whereFormat;

/**
 更新数据

 @param db <#db description#>
 @param tableName 表名
 @param dataSource <#dataSource description#>
 @param format 更新的条件
 @return 是否更新成功
 */
- (BOOL)updateDatabase:(FMDatabase * _Nonnull)db
                 Table:(NSString *)tableName
            dataSource:(id)dataSource
           whereFormat:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION;

/// 查找数据
/// @param db <#db description#>
/// @param tableName 表名
/// @param parameters 数据类型model或字典
/// @param format 查找的条件 注：默认不带WHERE关键字，需要手动添加
- (NSArray *_Nullable)selectDatabase:(FMDatabase * _Nonnull)db
                               table:(NSString *)tableName
                          dicOrModel:(id)parameters
                         whereFormat:(NSString * _Nullable)format;

/**
 清空表

 @param tableName <#tableName description#>
 @return <#return value description#>
 */
- (BOOL)deleteAllDataFromTable:(NSString *)tableName
                            db:(FMDatabase * _Nonnull)db;

#pragma mark - 数据库中表是否存在
- (BOOL)hasTable:(NSString *)tableName
              db:(FMDatabase * _Nonnull)db;

//- (BOOL)dbOpen;
//- (BOOL)dbClose;
@end

NS_ASSUME_NONNULL_END
