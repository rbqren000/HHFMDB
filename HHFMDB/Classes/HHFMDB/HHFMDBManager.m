//
//  HHFMDBManager.m
//  MyFMDB
//
//  Created by 崔辉辉 on 2019/5/24.
//  Copyright © 2019 huihui. All rights reserved.
//

#import "HHFMDBManager.h"
#import "HHFMDBUtil.h"
#import "HHMacros.h"

@implementation HHFMDBManager
+ (nonnull instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark DatabaseQueue
- (void)hh_inDatabase_queue:(void (^)(void))block
{
    ///不使用事务
    FMDatabaseQueue *queue;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        block();
    }];
}
- (void)hh_inTransaction_queue:(void (^)(void))block
{
    ///使用事务
    FMDatabaseQueue *queue;
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        block();
    }];
}

#pragma mark useTransaction
- (void)hh_useTransaction:(void (^)(void))block
{
    FMDatabase *fmdb;
    if ([fmdb beginTransaction]) {
        BOOL isRollBack = NO;
        @try
        {
            //这里面写增删改查操作 for循环 多个操作
            block();
        }
        @catch (NSException *exception)
        {
            isRollBack = YES;
            [fmdb rollback];
        }
        @finally
        {
            if (!isRollBack)
            {
                [fmdb commit];
            }
        }
    }
}
@end
