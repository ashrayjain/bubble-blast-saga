//
//  LoadViewController.m
//  ps03
//
//  Created by Ashray Jain on 2/7/14.
//
//

#import "LoadViewController.h"

@interface LoadViewController ()

- (void)removeFileAtIndex:(NSUInteger)index;

@end

@implementation LoadViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:documentsDir];

    self.fileList = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:nil] mutableCopy];

    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 70)];
    header.font = [header.font fontWithSize:40];
    header.textAlignment = NSTextAlignmentCenter;
    header.text = @"Select a file to load";
    header.backgroundColor = [UIColor lightGrayColor];
    self.tableView.tableHeaderView = header;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [self.fileList objectAtIndex:[indexPath row]];
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
    return [self.fileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.fileList objectAtIndex:[indexPath row]];
    cell.textLabel.font = [cell.textLabel.font fontWithSize:30];
    //cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.imageView.image = [UIImage imageNamed:@"bubble-blue.png"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeFileAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)removeFileAtIndex:(NSUInteger)index
{
    NSString *fileNametoRemove = [self.fileList objectAtIndex:index];
    [[NSFileManager defaultManager] removeItemAtPath:fileNametoRemove error:nil];
    [self.fileList removeObjectAtIndex:index];
}

@end
