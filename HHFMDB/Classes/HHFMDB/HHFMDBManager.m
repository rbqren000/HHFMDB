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

#pragma mark useTransaction
- (void)useTransaction_Queue {
    ///使用事务
    FMDatabaseQueue *queue;
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        ///
    }];
    //    ///不使用事务
    //    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
    //        ///
    //    }];
}

#pragma mark useTransaction
- (void)useTransaction {
    FMDatabase *fmdb;
    if ([fmdb beginTransaction]) {
        BOOL isRollBack = NO;
        @try
        {
            //这里面写增删改查操作 for循环 多个操作
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
