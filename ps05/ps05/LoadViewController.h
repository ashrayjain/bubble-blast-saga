//
//  LoadViewController.h
//  ps03
//
//  Created by Ashray Jain on 2/7/14.
//
//

#import <UIKit/UIKit.h>

@interface LoadViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) id data;

@end
