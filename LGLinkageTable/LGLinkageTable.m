//
//  LGLinkageTable.m
//  LGAppTool
//
//  Created by 东途 on 2016/11/28.
//  Copyright © 2016年 displayten. All rights reserved.
//

#import "LGLinkageTable.h"

@interface LGLinkageTable() <UITableViewDelegate, UITableViewDataSource,
    UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (copy, nonatomic) NSString *leftIdentifier;
@property (copy, nonatomic) NSString *rightIdentifier;
@property (strong, nonatomic) NSString *section;
@end
@implementation LGLinkageTable {
    NSInteger _oldSection;
    BOOL _bottomFlag;
    CGSize _itemSize;
    CGFloat _oldY;
}

- (void)layoutSubviews {
    
    if (!self.ratio) {
        self.ratio = 0.4f;
    }
    [self create_UI];
}
+ (instancetype)lg_linkageWithLeftData:(NSArray<id> *)left rightData:(NSArray<NSMutableArray *> *)right {
    return [[self alloc] initWithLeftData:left rightData:right];
}
- (instancetype)initWithLeftData:(NSArray<id> *)left rightData:(NSArray<NSMutableArray *> *)right {
    if (self = [super init]) {
        
        if (!self.leftDataArray) {
            self.leftDataArray = [NSMutableArray arrayWithArray:left];
        }
        if (!self.rightDataArray) {
            self.rightDataArray = [NSMutableArray arrayWithArray:right];
        }
        if (!self.section) {
            self.section = @"0";
        }
        [self addObserver:self forKeyPath:@"section" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
- (void)create_UI {
    [self create_left];
    [self create_right];
}
- (void)create_right {
    CGFloat wid = self.frame.size.width*(1-self.ratio);
    if (!self.rightFlowLayout) {
        self.rightFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.rightFlowLayout.minimumInteritemSpacing = 0;
        if (self.alowsSpaceLine) {
            self.rightFlowLayout.minimumLineSpacing = 1.f;
            _itemSize = CGSizeMake(wid*0.5-1, wid*0.5-1);
        }
        else {
            self.rightFlowLayout.minimumLineSpacing = 0;
            _itemSize = CGSizeMake(wid*0.5-0.5, wid*0.5-0.5);
        }
        self.rightFlowLayout.itemSize = _itemSize;
    }
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.tableView.frame), 0, wid, self.frame.size.height) collectionViewLayout:self.rightFlowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    if (self.alowsSpaceLine) {
        if (!self.lineColor) {
            self.lineColor = [UIColor lightGrayColor];
        }
        collectionView.backgroundColor = self.lineColor;
    }
    else {
        self.lineColor = [UIColor whiteColor];
        collectionView.backgroundColor = self.lineColor;
    }
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}
- (void)create_left {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width*self.ratio, self.frame.size.height) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self addSubview:tableView];
    self.tableView = tableView;
}

- (UITableView *)leftView {
    return self.tableView;
}
- (UICollectionView *)rightView {
    return self.collectionView;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"section"]) {
        
    }
}
#pragma mark Scroll View Delegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    [self leftViewScroll:scrollView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self leftViewScroll:scrollView];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _oldY = scrollView.contentOffset.y;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self leftViewScroll:scrollView];
    
    CGFloat y = scrollView.contentOffset.y;
    if ((_oldY>y) && _bottomFlag) {
        _bottomFlag = false;
    }
}
- (void)leftViewScroll:(UIScrollView *)scrollView {
    
    if (scrollView != self.collectionView) {
        return;
    }
    NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:scrollView.contentOffset];
    NSInteger row = index.section;
    NSIndexPath *scIndex;
    if (_oldSection != row) {
        CGFloat bottomy = self.collectionView.contentOffset.y+self.collectionView.frame.size.height;
        CGFloat hei = self.collectionView.contentSize.height+1;
        if (bottomy > hei) {
            _bottomFlag = true;
            scIndex = [NSIndexPath indexPathForRow:self.leftDataArray.count-1 inSection:0];
            [self.tableView selectRowAtIndexPath:scIndex animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
        else {
            scIndex = [NSIndexPath indexPathForRow:row inSection:0];
            if (!_bottomFlag) {
                [self.tableView selectRowAtIndexPath:scIndex animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }
    }
}
#pragma mark Collection View Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.rightDataArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *tmp = self.rightDataArray[section];
    return tmp.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.setRightCell) {
        return self.setRightCell(indexPath);
    }
    else {
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:self.rightIdentifier];
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.rightIdentifier forIndexPath:indexPath];
        NSString *txt;
        if (self.rightDataArray.count>0) {
            NSArray *arr = self.rightDataArray[indexPath.section];
            if (_oldSection != indexPath.section) {
                _oldSection = indexPath.section;
                self.section = [NSString stringWithFormat:@"%ld", _oldSection];
            }
            else {
                
            }
            if (arr.count>0) {
                id obj = arr[indexPath.row];
                if ([NSStringFromClass([obj class]) containsString:@"String"]) {
                    txt = obj;
                }
            }
        }
        if (!txt) {
            txt = @"text";
        }
        UILabel *label = [UILabel new];
        label.text = txt;
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        cell.backgroundView = label;
        return cell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self respondsToSelector:@selector(lg_linkageTableDidSelectItemAtIndexPath:)]) {
        [self.delegate lg_linkageTableDidSelectItemAtIndexPath:indexPath];
    }
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
#pragma mark Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.leftDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.setLeftCell) {
        return self.setLeftCell(indexPath);
    }
    else {
        
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.leftIdentifier];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.leftIdentifier];
        NSString *txt;
        if (self.leftDataArray.count>0) {
            id obj = self.leftDataArray[indexPath.row];
            if ([NSStringFromClass([obj class]) containsString:@"String"]) {
                txt = obj;
            }
        }
        if (!txt) {
            txt = @"text";
        }
        cell.textLabel.text = txt;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self rightViewScrollToSection:indexPath.row];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.leftRowHeight) {
        return self.leftRowHeight;
    }
    else return 100;
}

- (NSString *)leftIdentifier {
    if (!_leftIdentifier) {
        _leftIdentifier = @"lftid";
    }
    return _leftIdentifier;
}
- (NSString *)rightIdentifier {
    if (!_rightIdentifier) {
        _rightIdentifier = @"ritid";
    }
    return _rightIdentifier;
}
- (void)rightViewScrollToSection:(NSInteger)section {
    
    NSIndexPath *index = [NSIndexPath indexPathForItem:0 inSection:section];
    [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}
@end
