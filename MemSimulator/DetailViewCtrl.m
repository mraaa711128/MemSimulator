//
//  DetailViewCtrl.m
//  MemSimulator
//
//  Created by Stanley on 12/3/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import "DetailViewCtrl.h"

#import "MemAccessCellCtrl.h"
#import "TlbListCellCtrl.h"
#import "PageListCellCtrl.h"
#import "MemAddressCellCtrl.h"

@interface DetailViewCtrl ()

@end

@implementation DetailViewCtrl {
    NSNumber* mMemorySize;
    NSNumber* mPageSize;
    NSNumber* mPageNo;
    NSNumber* mTlbSize;
    NSMutableArray* mAvailableFrame;
    NSArray* mFrame;
    NSString* mTlbAlgorithm;
    NSString* mPageAlgorithm;
    
    NSMutableArray* mAccessList;
    NSMutableArray* mTlbList;
    NSMutableArray* mPageList;
    NSMutableArray* mFrameList;
    
    NSMutableArray* mMemoryAccessHistory;
    
    NSMutableArray* mTlbQueue;
    NSMutableArray* mPageQueue;
    
    NSOperationQueue* runQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    runQueue = [[NSOperationQueue alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource & Delegate 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
        case 0:
            return mAccessList.count;
            break;
        case 1:
            return mTlbList.count;
            break;
        case 2:
            return mPageList.count;
            break;
        case 3:
            return mFrameList.count;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {
        MemAccessCellCtrl* cell = [tableView dequeueReusableCellWithIdentifier:@"cellMemAccess"];
        [cell setAccessInfo:[mAccessList objectAtIndex:indexPath.row]];
        return cell;
    } else if (tableView.tag == 1) {
        TlbListCellCtrl* cell = [tableView dequeueReusableCellWithIdentifier:@"cellTlbList"];
        [cell setTlbInfo:[mTlbList objectAtIndex:indexPath.row]];
        return cell;
    } else if (tableView.tag == 2) {
        PageListCellCtrl* cell = [tableView dequeueReusableCellWithIdentifier:@"cellPageList"];
        [cell setPageInfo:[mPageList objectAtIndex:indexPath.row]];
        return cell;
    } else if (tableView.tag == 3) {
        UITableViewCell* cell;
        NSInteger frmNo = indexPath.row;
        if ([mFrame containsObject:[NSString stringWithFormat:@"%ld",frmNo]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellMemAddress"];
            [(MemAddressCellCtrl*)cell setMemAddressInfo:[mFrameList objectAtIndex:indexPath.row]];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellMemAddrUsed"];
        }        
        return cell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (tableView.tag) {
        case 1:
            return 66.0;
            break;
        case 3:
            if ([mFrame containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]) {
                return 150.0;
            } else {
                return 44.0;
            }
            break;
        default:
            return 44.0;
            break;
    }
}

#pragma mark - Public Function 
- (void)resetSimulator {
    @try {
        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
        
        mMemorySize = [settings objectForKey:@"memorysize"];
        mPageSize = [settings objectForKey:@"pagesize"];
        mPageNo = [NSNumber numberWithInteger:(mMemorySize.integerValue / mPageSize.integerValue)];
        mTlbSize = [settings objectForKey:@"tlbsize"];
        mTlbAlgorithm = [settings objectForKey:@"tlbalgorithm"];
        mPageAlgorithm = [settings objectForKey:@"pagealgorithm"];
        NSString* avaFrame = [settings objectForKey:@"frameavailable"];
        mFrame = [NSArray arrayWithArray:[avaFrame componentsSeparatedByString:@","]];
        mAvailableFrame = [NSMutableArray arrayWithArray:[avaFrame componentsSeparatedByString:@","]];

        [self resetMemoryAccess];
        [self resetTlbEntryBySize:mTlbSize];
        [self resetPageTableByNumber:mPageNo];
        [self resetMemoryFrameByNumber:mPageNo];
        [self resetMemoryAccessHistory];
        
        [self resetTlbQueue];
        [self resetPageQueue];
    }
    @catch (NSException *exception) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[exception description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)setMemoryAccessWithDecimalAddress:(NSInteger)decAddress{
    @try {
        // Check is Over Range (0 ~ MemorySize -1)
        if (decAddress >= mMemorySize.integerValue) {
            @throw [NSException exceptionWithName:@"addressoverrange" reason:@"Memory Access Out of Address Range" userInfo:nil];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self runMemoryManageAlgorithmByAddress:[NSString stringWithFormat:@"%ld",decAddress]];
        });
    }
    @catch (NSException *exception) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[exception description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)runMemoryManageAlgorithmByAddress:(NSString*)address {
    NSInteger decAddress = address.integerValue;
    //TLB & Page Algorithm
    NSNumber* accPageNo = [NSNumber numberWithInteger:(decAddress / mPageSize.integerValue)];
    NSNumber* accOffset = [NSNumber numberWithInteger:(decAddress % mPageSize.integerValue)];
    NSNumber* accFrameNo = [NSNumber numberWithInteger:-1];
    NSDictionary* dictColor = @{@"red":[NSNumber numberWithFloat:(CGFloat)(arc4random() % 256)],
                                @"green":[NSNumber numberWithFloat:(CGFloat)(arc4random() % 256)],
                                @"blue":[NSNumber numberWithFloat:(CGFloat)(arc4random() % 256)]};
    
    BOOL isTlbHit = YES;
    BOOL isPageHit = YES;
    
    // Check Tlb Exist
    NSMutableDictionary* dictTlbListItem = [self checkTlbListWithPageNo:accPageNo];
    if (dictTlbListItem == nil) {
        isTlbHit = NO;
        // Check Page Table Exist
        NSMutableDictionary* dictPageListItem = [self checkPageListWithPageNo:accPageNo];
        if (dictPageListItem == nil) {  // Page Fault
            isPageHit = NO;
            // Find Available Free Frame
            NSMutableDictionary* dictPageQueueItem;
            accFrameNo = [self getAvailableFreeFrame];
            if (accFrameNo.integerValue < 0) {
                dictPageQueueItem = [self getNextReplaceFrameByPageAlgorithm:mPageAlgorithm];
                if (dictPageQueueItem == nil) {
                    @throw [NSException exceptionWithName:@"unknowpagealgorithm" reason:@"Page Algorithm is Undefined" userInfo:nil];
                }
                accFrameNo = [dictPageQueueItem objectForKey:@"frameno"];
            } else {
                dictPageQueueItem = [self createPageQueueItemWithSeq:[NSNumber numberWithInteger:mPageQueue.count] AndFrameNo:accFrameNo];
            }
            
            // Remove Frame Table
            // Update Frame List
            NSPredicate* predFrame = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",accFrameNo];
            NSArray* arrFrame = [mFrameList filteredArrayUsingPredicate:predFrame];
            if (arrFrame.count > 0) {
                NSDictionary* dictFrameListItem = [arrFrame objectAtIndex:0];
                NSMutableArray* arrOffset = [dictFrameListItem objectForKey:@"offsets"];
                if (arrOffset.count > 0) {
                    [arrOffset removeAllObjects];
                }
                NSMutableArray* arrColor = [dictFrameListItem objectForKey:@"colors"];
                if (arrColor.count > 0) {
                    [arrColor removeAllObjects];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tabMemAddress reloadData];
            });
            
            
            // Update Page Table
            NSPredicate* predPage = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",accFrameNo];
            NSArray* arrPage = [mPageList filteredArrayUsingPredicate:predPage];
            for (int i = 0; i < [arrPage count]; i++) {
                NSMutableDictionary* dictRmPageListItem = [arrPage objectAtIndex:i];
                [dictRmPageListItem setObject:[NSNumber numberWithInteger:-1] forKey:@"frameno"];
                [dictRmPageListItem setObject:[NSNumber numberWithBool:NO] forKey:@"validbit"];
                [dictRmPageListItem setObject:[self getWhiteColorDictionary] forKey:@"color"];
            }
            dictPageListItem = [self createPageListItemWithSeq:accPageNo AndFrameNo:accFrameNo];
            [dictPageListItem setObject:dictColor forKey:@"color"];
            [mPageList removeObjectAtIndex:accPageNo.integerValue];
            [mPageList insertObject:dictPageListItem atIndex:accPageNo.integerValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tabPageList reloadData];
            });
            
            // Update Page Queue
            [dictPageQueueItem setObject:[NSNumber numberWithBool:YES] forKey:@"validbit"];
            [dictPageQueueItem setObject:dictColor forKey:@"color"];
            [mPageQueue insertObject:dictPageQueueItem atIndex:0];
        }
        
        accFrameNo = [dictPageListItem objectForKey:@"frameno"];
        
        // Find Available Free Tlb
        NSMutableDictionary* dictTlbQueueItem;
        NSNumber* avaTlbNo = [self getAvailableFreeTlb];
        if (avaTlbNo.integerValue < 0) {
            NSPredicate* predTlbQueue = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",accFrameNo];
            NSArray* arrTlbQueue = [mTlbQueue filteredArrayUsingPredicate:predTlbQueue];
            if (arrTlbQueue.count > 0) {
                dictTlbQueueItem = [arrTlbQueue objectAtIndex:0];
                [mTlbQueue removeObject:dictTlbQueueItem];
            } else {
                dictTlbQueueItem = [self getNextReplaceTlbByTlbAlgorithm:mTlbAlgorithm];
            }
            if (dictTlbQueueItem == nil) {
                @throw [NSException exceptionWithName:@"unknowtlbalgorithm" reason:@"TLB Algorithm is Undefined" userInfo:nil];
            }
        } else {
            dictTlbQueueItem = [self createTlbQueueItemWIthSeq:[NSNumber numberWithInteger:mTlbQueue.count] AndPageNo:accPageNo AndFrameNo:accFrameNo];
        }
        
        // Update Tlb
        NSNumber* changeTlbIdx = [dictTlbQueueItem objectForKey:@"seq"];
        //NSNumber* changePageNo = [dictTlbQueueItem objectForKey:@"pageno"];
        NSNumber* changeFrameNo = [dictTlbQueueItem objectForKey:@"frameno"];
        //NSPredicate* predTlb = [NSPredicate predicateWithFormat:@"%K = %@",@"pageno",changePageNo];
        NSPredicate* predTlb = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",changeFrameNo];
        NSArray* arrTlb = [mTlbList filteredArrayUsingPredicate:predTlb];
        for (int i = 0; i < arrTlb.count; i++) {
            NSMutableDictionary* dictRmTlbListItem = [arrTlb objectAtIndex:i];
            [dictRmTlbListItem setObject:[NSNumber numberWithInteger:-1] forKey:@"pageno"];
            [dictRmTlbListItem setObject:[NSNumber numberWithInteger:-1] forKey:@"frameno"];
            [dictRmTlbListItem setObject:[NSNumber numberWithBool:NO] forKey:@"validbit"];
            [dictRmTlbListItem setObject:[self getWhiteColorDictionary] forKey:@"color"];
        }
        dictTlbListItem = [self createTlbListItemWithSeq:changeTlbIdx AndPageNo:accPageNo AndFrameNo:accFrameNo];
        [dictTlbListItem setObject:dictColor forKey:@"color"];
        [mTlbList removeObjectAtIndex:changeTlbIdx.integerValue];
        [mTlbList insertObject:dictTlbListItem atIndex:changeTlbIdx.integerValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tabTlbList reloadData];
        });
        
        // Update Tlb Queue
        [dictTlbQueueItem setObject:accPageNo forKey:@"pageno"];
        [dictTlbQueueItem setObject:accFrameNo forKey:@"frameno"];
        [dictTlbQueueItem setObject:[NSNumber numberWithBool:YES] forKey:@"validbit"];
        [dictTlbQueueItem setObject:dictColor forKey:@"color"];
        [mTlbQueue insertObject:dictTlbQueueItem atIndex:0];
    }
    
    accFrameNo = [dictTlbListItem objectForKey:@"frameno"];

    // Update Page Queue (LRU)
    if ([mPageAlgorithm isEqualToString:@"LRU"]) {
        NSPredicate* predPageQueue = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",accFrameNo];
        NSArray* arrPageQueue = [mPageQueue filteredArrayUsingPredicate:predPageQueue];
        if ([arrPageQueue count] > 0) {
            NSMutableDictionary* dictPageQueueItem = [arrPageQueue objectAtIndex:0];
            [dictPageQueueItem setObject:dictColor forKey:@"color"];
            [mPageQueue removeObject:dictPageQueueItem];
            [mPageQueue insertObject:dictPageQueueItem atIndex:0];
        } else {
            @throw [NSException exceptionWithName:@"framenotinqueue" reason:@"Frame No not in Page Queue" userInfo:nil];
        }
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tabPageList reloadData];
//    });

    // Update Tlb Queue (LRU}
    if ([mTlbAlgorithm isEqualToString:@"LRU"]) {
        NSPredicate* predTlbQueue = [NSPredicate predicateWithFormat:@"%K = %@",@"pageno",accPageNo];
        NSArray* arrTlbQueue = [mTlbQueue filteredArrayUsingPredicate:predTlbQueue];
        if ([arrTlbQueue count] > 0) {
            NSMutableDictionary* dictTlbQueueItem = [arrTlbQueue objectAtIndex:0];
            [dictTlbQueueItem setObject:dictColor forKey:@"color"];
            [mTlbQueue removeObject:dictTlbQueueItem];
            [mTlbQueue insertObject:dictTlbQueueItem atIndex:0];
        } else {
            @throw [NSException exceptionWithName:@"pagenotinqueue" reason:@"Page No not in Tlb Queue" userInfo:nil];
        }
    }

//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tabTlbList reloadData];
//    });
    
    // Update Frame List
    NSPredicate* predFrame = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",accFrameNo];
    NSArray* arrFrame = [mFrameList filteredArrayUsingPredicate:predFrame];
    if (arrFrame.count > 0) {
        NSDictionary* dictFrameListItem = [arrFrame objectAtIndex:0];
        NSMutableArray* arrOffset = [dictFrameListItem objectForKey:@"offsets"];
        NSMutableArray* arrColor = [dictFrameListItem objectForKey:@"colors"];
        if ([arrOffset containsObject:accOffset] == NO) {
            [arrOffset addObject:accOffset];
            [arrColor addObject:dictColor];
        } else {
            NSInteger indexAccOffset = [arrOffset indexOfObjectIdenticalTo:accOffset];
            [arrColor setObject:dictColor atIndexedSubscript:indexAccOffset];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabMemAddress reloadData];
    });
    
    // Update Page Table
    NSPredicate* predPage = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",accFrameNo];
    NSArray* arrPage = [mPageList filteredArrayUsingPredicate:predPage];
    if (arrPage.count > 0) {
        NSMutableDictionary* dictPageListItem = [arrPage objectAtIndex:0];
        [dictPageListItem setObject:dictColor forKey:@"color"];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabPageList reloadData];
    });

    // Update Tlb List
    [dictTlbListItem setObject:dictColor forKey:@"color"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabTlbList reloadData];
    });

    // Insert into Access List
    NSMutableDictionary* dictAccListItem = [self createAccessListItemWithSeq:[NSNumber numberWithInteger:mAccessList.count] AndPageNo:accPageNo AndOffset:accOffset];
    [dictAccListItem setObject:dictColor forKey:@"color"];
    [mAccessList insertObject:dictAccListItem atIndex:mAccessList.count];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabMemAccessList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:mAccessList.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tabMemAccessList reloadData];
    });
    
    // Insert into History List
    NSNumber* hisSeq = [NSNumber numberWithInteger:mAccessList.count];
    NSNumber* hisPageNo = accPageNo;
    NSNumber* hisFrameNo = accFrameNo;   //[dictTlbListItem objectForKey:@"frameno"];
    NSNumber* hisOffset = accOffset;
    NSNumber* hisTlbIndex = [dictTlbListItem objectForKey:@"seq"];
    NSDictionary* dictHisListItem = [self createAccessHistoryListItemWithSeq:hisSeq AndPageNo:hisPageNo AndFrameNo:hisFrameNo AndOffset:hisOffset AndTlbIndex:hisTlbIndex AndTlbHit:isTlbHit AndPageHit:isPageHit AndColor:dictColor];
    [mMemoryAccessHistory insertObject:dictHisListItem atIndex:mMemoryAccessHistory.count];

}

#pragma mark - Private Function
- (void)resetMemoryAccess {
    if (mAccessList == nil) {
        mAccessList = [[NSMutableArray alloc] init];
    }
    [mAccessList removeAllObjects];
    [self.tabMemAccessList reloadData];
}

- (void)resetMemoryAccessHistory {
    if (mMemoryAccessHistory == nil) {
        mMemoryAccessHistory = [[NSMutableArray alloc] init];
    }
    [mMemoryAccessHistory removeAllObjects];
}

- (void)resetTlbEntryBySize:(NSNumber*)size {
    if (mTlbList == nil) {
        mTlbList = [[NSMutableArray alloc] init];
    }
    [mTlbList removeAllObjects];
    for (int i = 0; i < size.intValue; i++) {
        NSMutableDictionary* dictTlbListItem = [NSMutableDictionary dictionaryWithDictionary:@{@"seq":[NSNumber numberWithInt:i],@"pageno":[NSNumber numberWithInteger:-1],@"frameno":[NSNumber numberWithInteger:-1],@"validbit":[NSNumber numberWithBool:NO],@"color":[self getWhiteColorDictionary]}];
        [mTlbList addObject:dictTlbListItem];
    }
    [self.tabTlbList reloadData];
}

- (void)resetPageTableByNumber:(NSNumber*)pageno {
    if (mPageList == nil) {
        mPageList = [[NSMutableArray alloc] init];
    }
    [mPageList removeAllObjects];
    for (int i = 0; i < pageno.intValue; i++) {
        NSMutableDictionary* dictPageListItem = [NSMutableDictionary dictionaryWithDictionary:@{@"seq":[NSNumber numberWithInt:i],@"frameno":[NSNumber numberWithInteger:-1],@"validbit":[NSNumber numberWithBool:NO],@"color":[self getWhiteColorDictionary]}];
        [mPageList addObject:dictPageListItem];
    }
    [self.tabPageList reloadData];
}

- (void)resetMemoryFrameByNumber:(NSNumber*)pageno {
    if (mFrameList == nil) {
        mFrameList = [[NSMutableArray alloc] init];
    }
    [mFrameList removeAllObjects];
    for (int i = 0; i < pageno.intValue; i++) {
        NSMutableDictionary* dictFrameListItem = [NSMutableDictionary dictionaryWithDictionary:@{@"frameno":[NSNumber numberWithInt:i],@"offsets":[[NSMutableArray alloc] init],@"colors":[[NSMutableArray alloc] init]}];
        [mFrameList addObject:dictFrameListItem];
    }
    [self.tabMemAddress reloadData];
}

- (void)resetTlbQueue {
    if (mTlbQueue == nil) {
        mTlbQueue = [[NSMutableArray alloc] init];
    }
    [mTlbQueue removeAllObjects];
}

- (void)resetPageQueue {
    if (mPageQueue == nil) {
        mPageQueue = [[NSMutableArray alloc] init];
    }
    [mPageQueue removeAllObjects];
}

- (NSMutableDictionary*)checkTlbListWithPageNo:(NSNumber*)pageno {
    NSPredicate* predTlb = [NSPredicate predicateWithFormat:@"%K = %@",@"pageno",pageno];
    NSArray* arrTlb = [mTlbList filteredArrayUsingPredicate:predTlb];
    if ([arrTlb count] > 0) {
        return [arrTlb objectAtIndex:0];
    } else {
        return nil;
    }
}

- (NSMutableDictionary*)checkPageListWithPageNo:(NSNumber*)pageno {
    NSPredicate* predPage = [NSPredicate predicateWithFormat:@"%K = %@",@"seq",pageno];
    NSArray* arrPage = [mPageList filteredArrayUsingPredicate:predPage];
    if ([arrPage count] > 0) {
        NSNumber* frameNo = [[arrPage objectAtIndex:0] objectForKey:@"frameno"];
        if (frameNo.integerValue >= 0) {
            return [arrPage objectAtIndex:0];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSMutableDictionary*)createAccessListItemWithSeq:(NSNumber*)seq AndPageNo:(NSNumber*)pageno AndOffset:(NSNumber*)offset {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"seq":seq,@"pageno":pageno,@"offset":offset,@"color":[self getWhiteColorDictionary]}];
}

- (NSMutableDictionary*)createPageQueueItemWithSeq:(NSNumber*)seq AndFrameNo:(NSNumber*)frameno {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"seq":seq,@"frameno":frameno,@"validbit":[NSNumber numberWithBool:YES],@"color":[self getWhiteColorDictionary]}];
}

- (NSMutableDictionary*)createPageListItemWithSeq:(NSNumber*)seq AndFrameNo:(NSNumber*)frameno {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"seq":seq,@"frameno":frameno,@"validbit":[NSNumber numberWithBool:YES],@"color":[self getWhiteColorDictionary]}];
}

- (NSMutableDictionary*)createTlbQueueItemWIthSeq:(NSNumber*)seq AndPageNo:(NSNumber*)pageno AndFrameNo:(NSNumber*)frameno {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"seq":seq,@"pageno":pageno,@"frameno":frameno,@"validbit":[NSNumber numberWithBool:YES],@"color":[self getWhiteColorDictionary]}];
}

- (NSMutableDictionary*)createTlbListItemWithSeq:(NSNumber*)seq AndPageNo:(NSNumber*)pageno AndFrameNo:(NSNumber*)frameno {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"seq":seq,@"pageno":pageno,@"frameno":frameno,@"validbit":[NSNumber numberWithBool:YES],@"color":[self getWhiteColorDictionary]}];
}

- (NSMutableDictionary*)createAccessHistoryListItemWithSeq:(NSNumber*)seq AndPageNo:(NSNumber*)pageno AndFrameNo:(NSNumber*)frameno AndOffset:(NSNumber*)offset AndTlbIndex:(NSNumber*)tlbindex AndTlbHit:(BOOL)istlbhit AndPageHit:(BOOL)ispagehit AndColor:(NSDictionary*)color {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"seq":seq,@"pageno":pageno,@"frameno":frameno,@"offset":offset,@"tlbindex":tlbindex,@"tlbhit":[NSNumber numberWithBool:istlbhit],@"pagehit":[NSNumber numberWithBool:ispagehit],@"color":color}];
}

- (NSNumber*)getAvailableFreeFrame {
    if ([mAvailableFrame count] > 0) {
        NSInteger avaFrame = ((NSString*)[mAvailableFrame objectAtIndex:0]).integerValue;
        [mAvailableFrame removeObjectAtIndex:0];
        return [NSNumber numberWithInteger:avaFrame];
    } else {
        return [NSNumber numberWithInteger:-1];
    }
}

- (NSNumber*)getAvailableFreeTlb {
    if ([mTlbQueue count] < mTlbSize.integerValue) {
        return [NSNumber numberWithInteger:1];
    } else {
        return [NSNumber numberWithInteger:-1];
    }
}

- (NSMutableDictionary*)getNextReplaceFrameByPageAlgorithm:(NSString*)pagealgorithm {
    NSMutableDictionary* resultItem;
    if ([pagealgorithm isEqualToString:@"FIFO"]) {
        resultItem = [mPageQueue lastObject];
        [mPageQueue removeLastObject];
    } else if ([pagealgorithm isEqualToString:@"LRU"]) {
        resultItem = [mPageQueue lastObject];
        [mPageQueue removeLastObject];
    } else if ([pagealgorithm isEqualToString:@"CLOCK"]) {
        NSArray* sortQueue = [mPageQueue sortedArrayUsingComparator:^(id obj1, id obj2) {
            NSNumber* seq1 = [obj1 objectForKey:@"seq"];
            NSNumber* seq2 = [obj2 objectForKey:@"seq"];
            if (seq1.integerValue < seq2.integerValue) {
                return (NSComparisonResult)NSOrderedAscending;
            } else {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }];
        int i = 0;
        do {
            int index = i % [mPageQueue count];
            
            NSMutableDictionary* dictQueueItem = [sortQueue objectAtIndex:index];
            if ([dictQueueItem objectForKey:@"validbit"] == [NSNumber numberWithBool:NO]) {
                resultItem = dictQueueItem;
                [mPageQueue removeObject:resultItem];
                break;
            } else {
                [dictQueueItem setObject:[NSNumber numberWithBool:NO] forKey:@"validbit"];
            }
            
//            NSNumber* frameNo = [mPageQueue objectAtIndex:index];
//            NSPredicate* predPage = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",frameNo];
//            NSArray* arrPage = [mPageList filteredArrayUsingPredicate:predPage];
//            if ([arrPage count] <= 0) {
//                resultFrameNo = [NSNumber numberWithInteger:-1];
//                break;
//            } else {
//                NSMutableDictionary* dictPageListItem = [arrPage objectAtIndex:0];
//                if ([dictPageListItem objectForKey:@"validbit"] == NO) {
//                    resultFrameNo = [dictPageListItem objectForKey:@"frameno"];
//                    break;
//                } else {
//                    [dictPageListItem setObject:@YES forKey:@"validbit"];
//                }
//            }
            i++;
        } while (YES);
    } else {
        resultItem = nil;
    }
    return resultItem;
}

- (NSMutableDictionary*)getNextReplaceTlbByTlbAlgorithm:(NSString*)tlbalgorithm{
    NSMutableDictionary* resultItem;
    if ([tlbalgorithm isEqualToString:@"FIFO"]) {
        resultItem = [mTlbQueue lastObject];
        [mTlbQueue removeLastObject];
    } else if ([tlbalgorithm isEqualToString:@"LRU"]) {
        resultItem = [mTlbQueue lastObject];
        [mTlbQueue removeLastObject];
    } else if ([tlbalgorithm isEqualToString:@"CLOCK"]) {
        NSArray* sortQueue = [mTlbQueue sortedArrayUsingComparator:^(id obj1, id obj2) {
            NSNumber* seq1 = [obj1 objectForKey:@"seq"];
            NSNumber* seq2 = [obj2 objectForKey:@"seq"];
            if (seq1.integerValue < seq2.integerValue) {
                return (NSComparisonResult)NSOrderedAscending;
            } else {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }];
        int i = 0;
        do {
            int index = i % [mTlbQueue count];
            
            NSMutableDictionary* dictQueueItem = [sortQueue objectAtIndex:index];
            if ([dictQueueItem objectForKey:@"validbit"] == [NSNumber numberWithBool:NO]) {
                resultItem = dictQueueItem;
                [mTlbQueue removeObject:resultItem];
                break;
            } else {
                [dictQueueItem setObject:[NSNumber numberWithBool:NO] forKey:@"validbit"];
            }
            i++;
        } while (YES);
    } else {
        resultItem = nil;
    }
    return resultItem;
}

- (void)addMemoryAccessHistoryWithPageNo:(NSNumber*)pageno AndFrameNo:(NSNumber*)frameno AndOffset:(NSNumber*)offset AndTlbHit:(BOOL)tlbhit AndPageHit:(BOOL)pagehit AndTlbEntry:(NSNumber*)tlbindex {
    
}

- (NSDictionary*)getWhiteColorDictionary {
    return @{@"red":[NSNumber numberWithFloat:255.0],@"green":[NSNumber numberWithFloat:255.0],@"blue":[NSNumber numberWithFloat:255.0]};
}
#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
