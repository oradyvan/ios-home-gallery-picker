//
//  iOPhotoCollectionCell.h
//  iO
//
//  Created by Vadym Pilkevych on 10/12/15.
//  Copyright © 2015 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface iOPhotoCollectionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;

@end
