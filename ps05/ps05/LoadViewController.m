//
//  LoadViewController.m
//  ps03
//
//  Created by Ashray Jain on 2/7/14.
//
//

#import "LoadViewController.h"
#import "Constants.h"

@interface LoadViewController ()

- (void)removeFileAtIndex:(NSUInteger)index;

@end

@implementation LoadViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:documentsDirectoryPath()];
    self.fileList = [fileListForLoading() mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [self.fileList objectAtIndex:indexPath.row/2];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    NSArray *values = [NSArray arrayWithObjects:[unarchiver decodeObjectForKey:@"grid"], fileName, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"grid", @"gridName", nil];
    self.data = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [unarchiver finishDecoding];
    [self performSegueWithIdentifier:@"unwind" sender:self];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fileList count]*2;
}

- (UIImage *)imageForFileName:(NSString *)file
{
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:file];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    UIImage *image = [UIImage imageWithData:[unarchiver decodeObjectForKey:@"image"]];
    [unarchiver finishDecoding];
    return image;
}

- (BOOL)isPreloadedForFile:(NSString *)file
{
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:file];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    BOOL preloaded = NO;
    if ([unarchiver containsValueForKey:@"preloaded"]) {
        preloaded = YES;
    }
    [unarchiver finishDecoding];
    return preloaded;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.row %2 != 0) {
        
        
        NSString *fileName = [self.fileList objectAtIndex:indexPath.row/2];
        cell.textLabel.text = fileName;
        cell.textLabel.font = [cell.textLabel.font fontWithSize:40];
        //cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.imageView.image = [self imageForFileName:fileName];
    }
    else {
        cell.userInteractionEnabled = NO;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [self.fileList objectAtIndex:indexPath.row/2];
    if ([self isPreloadedForFile:fileName]) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2 != 0) {
        return 100;
    }
    else {
        return 10;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2 != 0 && editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeFileAtIndex:indexPath.row/2];
        [tableView deleteRowsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)removeFileAtIndex:(NSUInteger)index
{
    NSString *fileNametoRemove = [self.fileList objectAtIndex:index];
    [[NSFileManager defaultManager] removeItemAtPath:fileNametoRemove error:nil];
    [self.fileList removeObjectAtIndex:index];
}

@end
