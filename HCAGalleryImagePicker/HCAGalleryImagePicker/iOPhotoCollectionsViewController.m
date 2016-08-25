//
//  iOPhotoCollectionsViewController.m
//  iO
//
//  Created by Vadym Pilkevych on 10/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import "iOPhotoCollectionsViewController.h"
#import "iOPhotoCollectionsDataSource.h"
#import "iOPhotoAssetsViewController.h"
#import "iOPhotoCollectionCell.h"


#if !__has_feature(objc_arc)
#error "ARC is required"
#endif


@interface iOPhotoCollectionsViewController ()

@property (nonatomic, strong) IBOutlet iOPhotoCollectionsDataSource *dataSource;
@property (nonatomic, strong) IBOutlet UIView *emptyPhotoLibraryView;
@property (nonatomic, strong) IBOutlet UILabel *emptyPhotoLibraryLabel;

@end

@implementation iOPhotoCollectionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.emptyPhotoLibraryLabel.text = NSLocalizedString(@"lblEmptyGroupMessage", nil);
    self.emptyPhotoLibraryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    __typeof(self) __weak weakSelf = self;
    
    self.dataSource.photoLibraryChangeHandler = ^(PHChange *changeInfo)
    {
        [weakSelf.tableView reloadData];
        [weakSelf showOrHideEmptyPhotoLibraryMessage];
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showOrHideEmptyPhotoLibraryMessage];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return (self.navigationController.topViewController == self);
}

#pragma mark - Public

- (PHAssetCollection *)allPhotosCollection
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    PHAssetCollection *collection = [self.dataSource assetCollectionAtIndexPath:indexPath];
    return collection;
}

#pragma mark - Private

- (void)showOrHideEmptyPhotoLibraryMessage
{
    BOOL isPhotoLibraryEmpty = (self.dataSource.photoAssetCollections.count == 0);
    self.tableView.backgroundView = isPhotoLibraryEmpty ? self.emptyPhotoLibraryView : nil;
}

#pragma mark - Actions

- (IBAction)cancelButtonDidPress:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(iOPhotoCollectionsViewControllerDidCancel:)])
    {
        [self.delegate iOPhotoCollectionsViewControllerDidCancel:self];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(iOPhotoCollectionsViewController:didSelectAssetCollection:)])
    {
        PHAssetCollection *collection = [self.dataSource assetCollectionAtIndexPath:indexPath];
        
        [self.delegate iOPhotoCollectionsViewController:self
                               didSelectAssetCollection:collection];
    }
}

@end
