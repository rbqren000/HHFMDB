//
//  HHFMDBManager.h
//  MyFMDB
//
//  Created by 崔辉辉 on 2019/5/24.
//  Copyright © 2019 huihui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHFMDBManager : NSObject

+ (nonnull instancetype)sharedManager;

@property (nonatomic, strong)NSMutableDictionary *storageTypeDic;

//FMDatabaseQueue不使用事务
- (void)hh_inDatabase_queue:(void (^)(void))block;
//FMDatabaseQueue使用事务
- (void)hh_inTransaction_queue:(void (^)(void))block;

//FMDatabase使用事务
- (void)hh_useTransaction:(void (^)(void))block;
@end

NS_ASSUME_NONNULL_END
