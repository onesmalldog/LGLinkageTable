//
//  LGLinkageTable.h
//  LGAppTool
//
//  Created by 东途 on 2016/11/28.
//  Copyright © 2016年 displayten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGLinkageTableDelegate <NSObject>
- (void)lg_linkageTableDidSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@end
@interface LGLinkageTable : UIView

+ (instancetype)lg_linkageWithLeftData:(NSArray <id>*)left rightData:(NSArray <NSMutableArray *>*)right;

/** 左右视图的比例 */
@property (assign, nonatomic) CGFloat ratio;
@property (weak, nonatomic) id <LGLinkageTableDelegate>delegate;

#pragma mark Left
@property (copy, nonatomic) NSMutableArray <id>*leftDataArray;
@property (weak, nonatomic, readonly) UITableView *leftView;
@property (copy, nonatomic) UITableViewCell *(^setLeftCell)(NSIndexPath *indexPath);
@property (assign, nonatomic) CGFloat leftRowHeight;

#pragma mark Right
@property (copy, nonatomic) NSMutableArray <NSMutableArray *>*rightDataArray;
@property (weak, nonatomic, readonly) UICollectionView *rightView;
@property (strong, nonatomic) UICollectionViewFlowLayout *rightFlowLayout;
@property (assign, nonatomic) BOOL alowsSpaceLine;
@property (strong, nonatomic) UIColor *lineColor;
@property (copy, nonatomic) UICollectionViewCell *(^setRightCell)(NSIndexPath *indexPath);
@end
