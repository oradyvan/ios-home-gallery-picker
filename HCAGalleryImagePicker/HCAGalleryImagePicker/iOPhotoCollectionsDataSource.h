//
//  iOPhotoCollectionsDataSource.h
//  iO
//
//  Created by Vadym Pilkevych on 10/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


typedef void (^iOPhotoCollectionsDataSourceLibraryChangeBlock)(PHChange *changeInfo);


@interface iOPhotoCollectionsDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) iOPhotoCollectionsDataSourceLibraryChangeBlock photoLibraryChangeHandler;
@property (nonatomic, readonly) NSArray<PHAssetCollection *> *photoAssetCollections;

- (PHAssetCollection *)assetCollectionAtIndexPath:(NSIndexPath *)indexPath;

@end
