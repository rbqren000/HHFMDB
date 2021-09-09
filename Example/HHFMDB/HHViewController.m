//
//  HHViewController.m
//  HHFMDB
//
//  Created by 805988356@qq.com on 07/13/2020.
//  Copyright (c) 2020 805988356@qq.com. All rights reserved.
//

#import "HHViewController.h"
#import <HHFMDBHeader.h>
#import "CommunityModel.h"
#import "PublishMOdel.h"
#import "Student.h"
@interface HHViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *objects;
@property (nonatomic, strong)NSArray *dataSource;

@end

@implementation HHViewController

- (NSMutableArray *)objects {
    if (!_objects) {
        self.objects = [NSMutableArray arrayWithCapacity:0];
        [self getJsonData];
    }
    return _objects;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.dataSource = @[@[@"创建表0",@"使用事务插入数据",@"删除数据",@"更新数据",@"不使用事务插入数据",@"加快速度"],
                        @[@"创建表1",@"插入数据",@"取出数据"],
                        @[@"创建表2模型中包含模型和数组",@"插入数据",@"取出数据"],
                        @[@"创建表3",@"插入数据",@"取出数据",@"删除数据"]];

    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
}

- (void)getJsonData {
    NSData *fileData = [[NSData alloc]init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dataSource" ofType:@"json"];
    fileData = [NSData dataWithContentsOfFile:path];
    
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *data = responseObject[@"data"][@"data"];
    for (NSDictionary *object in data) {
        CommunityModel *model = [[CommunityModel alloc] init];
        [model setValuesForKeysWithDictionary:object];
        [self.objects addObject:model];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HHFMDBTool *t = [HHFMDBTool sharedTool];
    FMDatabase *db = [HHFMDBTool defaultDatabase];
    if (indexPath.section == 0) {
        NSString *tableName = @"nicaia0";
        switch (indexPath.row) {
            case 0: {
                [t createTableWithTableName:tableName dicOrModel:[CommunityModel class] excludeName:nil db:db];
                break;
            }
            case 1: {
                NSDate *d1 = [NSDate date];
                [t insertWithTableName:tableName dataSource:self.objects db:db];
                NSDate *d2 = [NSDate date];
                NSLog(@"使用事务插入时间：%.8f",[d2 timeIntervalSince1970] - [d1 timeIntervalSince1970]);
                break;
            }
            case 2: {
                [t deleteDatabase:db Table:tableName whereFormat:@"role = 'student'"];
                break;
            }
            case 3: {
                [t updateDatabase:db Table:tableName dataSource:@{@"displayName" : @"aaa"} whereFormat:@"nickname = '李小华'", nil];
                break;
            }
            case 4: {
                NSDate *d1 = [NSDate date];
                [t insertWithTableName:tableName dataSource:self.objects.firstObject db:db];
                NSDate *d2 = [NSDate date];
                NSLog(@"不使用事务插入时间：%.8f",[d2 timeIntervalSince1970] - [d1 timeIntervalSince1970]);
                break;
            }
            case 5: {
                [self list:@"AAA",@"BBB",@"CCC",nil];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        NSString *tableName = @"nicaia1";
        switch (indexPath.row) {
            case 0: {
                [t createTableWithTableName:tableName dicOrModel:[PublishMOdel class] excludeName:nil db:db];
                break;
            }
            case 1: {
                PublishMOdel *model = [[PublishMOdel alloc]init];
                model.imgs = [NSArray arrayWithObjects:UIImageJPEGRepresentation([UIImage imageNamed:@"w1.jpg"], 0.1),UIImageJPEGRepresentation([UIImage imageNamed:@"w2.png"], 0.1),UIImageJPEGRepresentation([UIImage imageNamed:@"w3.jpg"], 0.1), nil];
                
                [t insertWithTableName:tableName dataSource:model db:db];
                break;
            }
            case 2: {
                NSArray *aa = [t selectDatabase:db table:tableName dicOrModel:[PublishMOdel class] whereFormat:nil];
                NSLog(@"%@",aa);
                UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(100, 300, 200, 300)];
                [self.view addSubview:imgV];
                imgV.backgroundColor = [UIColor cyanColor];
                PublishMOdel *model = aa.firstObject;
                NSData *data = ((PublishMOdel *)aa.firstObject).imgs.firstObject;
                imgV.image = [UIImage imageWithData:data];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        NSString *tableName = @"nicaia2";
        switch (indexPath.row) {
            case 0: {
                [t createTableWithTableName:tableName dicOrModel:[Student class] excludeName:nil db:db];
                break;
            }
            case 1: {
                Student *student = [[Student alloc]init];
                student.name = @"小黄";
                student.age = @"18";
                student.infos = @[@"1",@"hello",@"gg"];
                
                User *user = [[User alloc]init];
                user.name = @"userName";
                student.user = user;
                //保存数据到数据库（模型中的成员变量有数组与模型）
                //如果模型中的成员变量是数组或者自定义模型，就将数组或者自定义模型归档(NSKeyedArchive)为二进制数据，再存入数据库；从数据库取出数据时，将二进制数据解档（NSKeyedUnArchive）为数组或者自定义模型；
                
                [t insertWithTableName:tableName dataSource:student db:db];
                break;
            }
            case 2: {
                NSArray *aa = [t selectDatabase:db table:tableName dicOrModel:[Student class] whereFormat:nil];
                NSLog(@"%@",aa);
                for (int i = 0; i<aa.count; i++) {
                    Student *s =aa[i];
                    //查看数组数据能否成功读取
                    NSLog(@"array:%@",s.infos);
                    //查看模型数据能否成功读取
                    NSLog(@"User:%@",s.user.name);
                }
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 3) {
        NSString *tableName = @"nicaia3";
        NSDictionary *dicC = @{@"hh":SQL_TEXT};
        switch (indexPath.row) {
            case 0: {
                [t createTableWithTableName:tableName dicOrModel:dicC excludeName:nil db:db];
                break;
            }
            case 1: {
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                for (int i = 0; i < 30; i ++) {
                    NSString *str = [NSString stringWithFormat:@"%d",arc4random() % 20 + 9];
                    [arr addObject:@{@"hh":str}];
                }
                
                [t insertWithTableName:tableName dataSource:arr  db:db];
                break;
            }
            case 2: {
                NSString *sqlString = [NSString stringWithFormat:@"hh > %@",@"2"];
                NSArray *result = [t selectDatabase:db table:tableName dicOrModel:dicC whereFormat:sqlString];

                for (int i = 0; i<result.count; i++) {
                    //查看数组数据能否成功读取
                    NSLog(@"array:%@",result[i][@"hh"]);
                    
                }
                break;
            }
            case 3: {
                NSString *sqlString = [NSString stringWithFormat:@"hh < %@",@"9"];
                
                [t deleteDatabase:db Table:tableName whereFormat:sqlString];

                break;
            }

            default:
                break;
        }
    }
}




- (void)list:(NSString *)string, ... NS_REQUIRES_NIL_TERMINATION {
    va_list argsList;
    va_start(argsList, string);
    if (string) {
        //输出第一个字符串
        NSLog(@"string---%@",string);
        NSString *otherString;
        while (1) {
            //依次取得所有参数
            otherString = va_arg(argsList, NSString*);
            if (otherString == nil) {
                break;
            }
            else {
                otherString = [[NSString alloc] initWithFormat:otherString locale:nil arguments:argsList];
                NSLog(@"otherString---%@",otherString);
            }
        }
    }
    va_end(argsList);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
