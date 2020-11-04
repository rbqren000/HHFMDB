# HHFMDB
FMDB封装

- 一个项目一般一个数据库.db即可
- 一个数据库中去创建多个表
注：
参考`JQFMDB`，`BGFMDB`进行的修改

#### 简介
使用技术：
1. runtime运行时。
2. KVC。
功能：
可以直接使用一个模型或者一个字典进行建表增删改数据。
模型的属性之中支持包含模型和数组。字典的值也支持模型和数组。

##### 数据库：
可以有多个数据库文件。
app有一个默认的数据库`defaultDatabase`，如果需要使用其他的数据库文件，则调用`databaseWithName`去获取。
直接调用这句会默认创建一个数据库
```
FMDBTool *t = [FMDBTool sharedTool];
```
下面这行代码 可以调用切换数据库文件
```
//创建数据库（不创建就是默认的）
[t databaseWithName:[NSString stringWithFormat:@"%@.db",@"tableName"]];
```
如果是多个数据库的，创建表，增删改查等操作都要切换数据库。 不然会是上一次使用的数据库。

##### 创建数据表：
1、把传入的模型类或者字典类转换成字典类型
2、遍历字典类型的key（key为保存到数据库中表的字段名，value为字段的类型）去创建表（其中去除不需要保存的字段）。

##### 增：
1、传入的是字典：
可以直接使用
2、传入的是模型：
使用runtime获取模型类的所有的属性 根据属性名获取模型的值 
属性和值对应字典的键和值

#### 模型中包含数组或者模型
1.数组存储到数据库的思路：存储前，数组归档(NSKeyedArchiver)为二进制数据，再存入数据库；从数据库取出时肯定也是取出的二进制数据，这时要将二进制数据解档（NSKeyedUnArchiver）为数组；
2.自定义模型存储到数据库的思路：存储前，自定义模型归档(NSKeyedArchiver)为二进制数据，再存入数据库；从数据库取出时肯定也是取出的二进制数据，这时要将二进制数据解档（NSKeyedUnArchiver）为自定义模型；


- 插入的时候：
要根据插入的数据类型（字典或模型），获取对应数据库中的类型。
如果字典中键对应值是数组或者模型类型的话，则进行归档，转为NSData
- 查找的时候：
如果字典中键对应值是数组或模型类型的话，则进行反归档，转为NSArray或model。

存储图片UIImage等使用BLOB类型存储 转换成二进制存储。

- 注：
自定义模型要进行归档或者解档操作，必须遵守协议`<NSCoding>`，并且实现`- (void)encodeWithCoder:(NSCoder *)aCoder；` 和 `- (id)initWithCoder:(NSCoder *)aDecoder;`  这2个方法。


#### 用法：
```
FMDBTool *t = [FMDBTool sharedTool];
//创建数据库（不创建就是默认的）
FMDatabase *db = [FMDBTool defaultDatabase];
//创建表
[t createTableWithTableName:@"tableName" dicOrModel:@{@"contentStr" : SQL_TEXT} excludeName:nil];
//查数据
NSArray *aa = [t selectTable:@"tableName" dicOrModel:@{@"contentStr" : SQL_TEXT} whereFormat:nil];
```

##### 关于open和close
注：
增删改查等操作之前要打开数据库，操作完毕之后关闭数据库。

频繁操作open和close消耗比较大（没有测试）
后台是多个用户，多人连接数据库，需要断开。手机是单个用户操作，单个线程操作数据库时，所以默认直接打开。增删改查 操作开始和结束都不做open和close。
创建数据库文件的时候就直接open。之后的建表，增，删，改，查都不需open。

##### 插入已存在的数据
存在的话就更新，不存在的话就插入。 可以使用`INSERT OR REPLACE`。
```
NSString *insertSql= [NSString stringWithFormat:
@"INSERT OR REPLACE INTO %@ ('articleID','editDate') VALUES ('%@','%@')",
tableName,item[@"articleID"],item[@"editDate"]];
```

##### 事务处理的一些问题
1. 多条语句的处理
    例如：增加文章，更新文章，删除文章，操作不同的表。
    多条语句可以写在一个事务里面， 操作完成之后，最后再一起提交。
    否则会出问题。操作不成功。
2. 多个事务处理
    这种情况可以使用多线程，操作完一个再操作下一个。
3. FMDatabaseQueue

#####   主键
1. 有主键
- 创建表的时候 判断模型的属性或者字典的键中是否包含有主键
    包含的话 就有主键 不包含的话 就没有主键
- 主键不能包含任意的模型和字典的键，那么就让属性和字典中的键等于主键。（不能包含世界，那么就让大千世界包含自己）
- 主键类型并不止是`INTEGER`，还可以是`TEXT`。
    1. 主键是模型的属性
    2. 主键是按顺序排序 自动生成
2. 没主键
######  主键
上面的方法在实际使用中不太方便，还得在模型或字典中添加主键字段。
所以主键改为输入，建表的时候添加主键，更为实用。


#####   变量说明
- dicOrModel
创建表 插入数据 查找数据这三个需要传入model类型或者字典 对应表中的字段和类型
- columnArr
表中的字段
- excludeName
不保存的model的属性
- storageTypeTodictionary
建表和插入数据 查找数据的时候需要把字典和model模型转成数据库存储的字段和类型
查找的时候 因为传入的字典是存储的类型 不需再转，只需转model模型。
- propertyType
存储的类型  字段的名和类型

##### 查找 SELECT
- 没有筛选条件的话直接传nil即可。
- 有筛选条件的话，需要自己拼写完整的条件，并且需要写`WHERE`，因为有时是查所有数据按照某个字段倒序排序查找，这种情况不需要写`WHERE`关键字，直接写` ORDER BY <#某个字段#><##> DESC`。
###### SELECT之后的结果处理
- 字典和模型统一都使用对象的`- (void)setValue:(nullable id)value forKey:(NSString *)key;`方法。
- 查找的结果对象的类型需要判断是字典类还是模型的类。根据类去创建结果对象。

##### 更新 UPDATE
`- (BOOL)updateTable:(NSString *)tableName dataSource:(id)dataSource whereFormat:(NSString *)format, ...`
更新数据 需要自己写`whereFormat`参数。并且带`WHERE`。
自动更新dataSource的数据字段。


##### 多个条件 
删除 查找 条件可能是多个的。
例如：倒序 查找某些条件的数据。

##### 创建表
注：
判断主键和model中不存的字段的时候，要判断是否是最后一个，如果是最后一个的话，不能有逗号`,`并且最后要加上右括号`)`，否则语法错误。

##### 多线程
为使得所有线程共用全局的数据库连接，可以将sqlite3线程模式更改为串行模式：在初始化SQLite前，调用sqlite3_config(SQLITE_CONFIG_SERIALIZED)启用。
```
- (BOOL)open {
if (_db) {
return YES;
}

///添加这一行
sqlite3_config(SQLITE_CONFIG_SERIALIZED);

int err = sqlite3_open([self sqlitePath], (sqlite3**)&_db );
if(err != SQLITE_OK) {
NSLog(@"error opening!: %d", err);
return NO;
}

if (_maxBusyRetryTimeInterval > 0.0) {
// set the handler
[self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
}


return YES;
}
```
使用FMDatabaseQueue，FMDatabaseQueue实现很简单，其实里面就是封装了一个GCD串行队列，队列中任务同步执行达到串行的作用。（确保在同一线程）
```
FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:_path];
dispatch_async(dispatch_get_global_queue(0, 0), ^{
[queue inDatabase:^(FMDatabase *db) {
for (int i=0; i<10; i++) {
BOOL s = [_db executeUpdate:@"INSERT INTO Student (name) VALUES (?)",@"小明"];
NSLog(@"start %d ===success %d",i,s);
}
}];
});

dispatch_async(dispatch_get_global_queue(0, 0), ^{
[queue inDatabase:^(FMDatabase *db) {
FMResultSet *set = [_db executeQuery:@"select id from Student"];
while ([set next]) {
int vl = [set intForColumn:@"id"];
NSLog(@"select %d",vl);
};
}];
});
```

##### 多条件
删除 多个条件
`- (BOOL)deleteTable:(NSString *)tableName whereFormat:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION;`把参数whereFormat，使用`va_list`拼接成sql语句。


## storageTypeDic
存储 表的字段名和表的字段类型
缓存在内存中，每一个表对应一个存储类型（字典类型）
在创建表的时候保存。键是表名，值是存储类型。
因为可能有多个数据库，所以外面多包一层。
多个数据库 每个数据库包含多个表 每个表对应表中存储的字段名和类型。
```
@{
    @"db1":@{
        @"tableName1":@{@"字段名":@"字段的存储类型",
                        @"字段名":@"字段的存储类型",
                        @"字段名":@"字段的存储类型"
                        },
        @"tableName2":@{@"字段名":@"字段的存储类型",
                        @"字段名":@"字段的存储类型",
                        @"字段名":@"字段的存储类型"
                        }
    },
    @"db2":@{
        @"tableName1":@{@"字段名":@"字段的存储类型",
                        @"字段名":@"字段的存储类型",
                        @"字段名":@"字段的存储类型"
                        },
        @"tableName2":@{@"字段名":@"字段的存储类型",
                        @"字段名":@"字段的存储类型",
                        @"字段名":@"字段的存储类型"
                        }
    }
};
```

##### FMDB语法
- 是否有某个表
```
FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",<#表名#>]];

[set next];

NSInteger count = [set intForColumnIndex:0];
```
- 创建表
```
NSString * sql = @"CREATE TABLE newsTB (id INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,newsDetail VARCHAR(100),articleID INTEGER NOT NULL unique ,title VARCHAR(100),commentTimes INTEGER,showTime DATE)";
```
- 删除
```
NSString * query = [NSString stringWithFormat:@"DELETE FROM newsTB WHERE articleID = '%@'",articleID];
```

某个日期之前的数据
```
NSString * query = @"SELECT * FROM newsTB";

query = [query stringByAppendingFormat:@" WHERE isTopNews = '%@' and showTime < '%@' ORDER BY showTime DESC LIMIT 10 ",@"1",showTime];
```
```
NSString * query = @"SELECT * FROM newsTB";

query = [query stringByAppendingFormat:@" WHERE isTopNews = '%@' AND createDate BETWEEN '%@' AND '%@'",@"1",times[0],times[1]];
```


- 更新 `update 表名 set 属性=值 where 条件`
```
NSString * query = @"UPDATE newsTB SET";
NSMutableString * temp = [NSMutableString stringWithCapacity:20];

[temp appendFormat:@" hasRead = '%@'",@(1)];

query = [query stringByAppendingFormat:@"%@ WHERE articleID = '%@'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],news.articleID];
```

##### 多个FMDatabase切换
一个app中可能有多个FMDatabase文件。
切换的时候判断是否和当前数据库是否同一个（根据路径判断），是同一个不用操作，不是同一个的把之前的`close`。切换需要的数据库，并`open`。


### 封装
代码封装应该是以最小的功能 可以重复利用。 
把FMDatabase对象提取到参数由外界传入：
既可以使用`FMDatabase`又可以使用`FMDatabaseQueue`来操作数据库。
项目有可能有几个数据库文件，所以FMDatabase对象不能写死。

## HHFMDBManager
增删改查通过block传入。












