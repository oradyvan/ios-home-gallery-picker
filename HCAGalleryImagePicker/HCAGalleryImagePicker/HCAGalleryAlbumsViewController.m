//
//  MMVAlbumsTableViewController.m
//  MMVImagePickerController
//
//  Created by Maksym Malyhin on 11/5/14.
//  Copyright (c) 2014 Maxim Malyhin. All rights reserved.
//

#import "HCAGalleryAlbumsViewController.h"
#import "HCAGalleryImagePicker.h"

#import "HCAPhotosCollectionViewController.h"
#import "HCAGalleryImagePickerViewController.h"

#import "HCAAssetsLibrary.h"
#import "HCAAssetCollection.h"

#import <Photos/Photos.h>

static NSString * const reuseIdentifier = @"Cell";

@interface HCAGalleryAlbumsViewController ()

@property (nonatomic) NSArray *collections;
@property (nonatomic) CGSize albumThumbSize;

- (IBAction)cancelButtonDidTap:(UIBarButtonItem *)sender;

@end

@implementation HCAGalleryAlbumsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat cellHeight = self.tableView.rowHeight;
    CGFloat thumbSide = [UIScreen mainScreen].scale * cellHeight;
    self.albumThumbSize = CGSizeMake(thumbSide, thumbSide);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updatePhotoGroups];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.collections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCAAssetCollection *collection = self.collections[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSInteger tag = indexPath.row;
    cell.tag = tag;
    cell.textLabel.text = collection.collection.localizedTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)collection.assetCount];
    
    PHImageRequestOptions *imageOptions = [PHImageRequestOptions new];
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    imageOptions.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:collection.lastAsset
                                               targetSize:self.albumThumbSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:imageOptions resultHandler:^(UIImage *result, NSDictionary *info)
     {
         if (cell.tag == tag)
         {
             cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
             cell.imageView.layer.masksToBounds = YES;
             cell.imageView.image = result;
             [cell setNeedsLayout];
         }
     }];
    
    return cell;
}

#pragma mark - Photos

- (void)updatePhotoGroups
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized)
    {
        [self fetchAssetsCollections];
    }
    else
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    [self fetchAssetsCollections];
                    break;
                    //TODO: Ask user to provide access
                case PHAuthorizationStatusRestricted:
                    break;
                case PHAuthorizationStatusDenied:
                    break;
                default:
                    break;
            }
        }];
    }
    
}

- (void)fetchAssetsCollections
{
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:(PHAssetCollectionTypeSmartAlbum) subtype:PHAssetCollectionSubtypeAny options:nil];
    PHFetchResult *regularAlbums = [PHAssetCollection fetchAssetCollectionsWithType:(PHAssetCollectionTypeAlbum) subtype:PHAssetCollectionSubtypeAny options:nil];
    
    __block NSMutableArray *collectionsToDisplay = [NSMutableArray arrayWithCapacity:[smartAlbums count]];
    
    void (^enumerationBlock)(id obj, NSUInteger idx, BOOL *stop) = ^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop)
    {
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden)
        {
            return;
        }
        
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:collection options:[HCAAssetCollection defaultAssetsFetchOptions]];
        if ([assets countOfAssetsWithMediaType:PHAssetMediaTypeImage] > 0)
        {
            HCAAssetCollection *assetCollection = [[HCAAssetCollection alloc] initWithCollection:collection assets:assets];
            [collectionsToDisplay addObject:assetCollection];
        }
    };
    
    [smartAlbums enumerateObjectsUsingBlock:enumerationBlock];
    [regularAlbums enumerateObjectsUsingBlock:enumerationBlock];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastAsset.creationDate" ascending:NO];
    [collectionsToDisplay sortUsingDescriptors:@[sortDescriptor]];
    self.collections = [collectionsToDisplay copy];
    
    [self.tableView reloadData];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GroupPhotosSegue"])
    {
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        
        HCAAssetCollection *collection = self.collections[selectedIndex];
        
        HCAPhotosCollectionViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.collection = collection.collection;
    }
}

- (IBAction)cancelButtonDidTap:(UIBarButtonItem *)sender
{
    HCAImagePickerSelectionResultBlock selectionResultBlock = [(HCAGalleryImagePickerViewController *)self.navigationController completeSelectionHandler];
    selectionResultBlock(nil, self.navigationController);
}

@end
