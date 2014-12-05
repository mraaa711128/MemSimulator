//
//  DetailViewCtrl.m
//  MemSimulator
//
//  Created by Stanley on 12/3/14.
//  Copyright (c) 2014 Stanley. All rights reserved.
//

#import "DetailViewCtrl.h"

@interface DetailViewCtrl ()

@end

@implementation DetailViewCtrl {
    NSNumber* mMemorySize;
    NSNumber* mPageSize;
    NSNumber* mPageNo;
    NSNumber* mTlbSize;
    NSMutableArray* mAvailableFrame;
    NSString* mTlbAlgorithm;
    NSString* mPageAlgorithm;
    
    NSMutableArray* mAccessList;
    NSMutableArray* mTlbList;
    NSMutableArray* mPageList;
    NSMutableArray* mFrameList;
    
    NSMutableArray* mMemoryAccessHistory;
    
    NSMutableArray* mTlbQueue;
    NSMutableArray* mPageQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        //TLB & Page Algorithm
        NSNumber* accPageNo = [NSNumber numberWithInteger:(decAddress / mPageSize.integerValue)];
        NSNumber* accOffset = [NSNumber numberWithInteger:(decAddress % mPageSize.integerValue)];


        BOOL isTlbHit = YES;
        BOOL isPageHit = YES;
        
        // Check Tlb Exist
        NSDictionary* dictTlbListItem = [self checkTlbListWithPageNo:accPageNo];
        if (dictTlbListItem == nil) {
            isTlbHit = NO;
            // Check Page Table Exist
            NSDictionary* dictPageListItem = [self checkPageListWithPageNo:accPageNo];
            if (dictPageListItem == nil) {  // Page Fault
                isPageHit = NO;
                // Find Available Free Frame
                NSDictionary* dictPageQueueItem;
                NSNumber* avaFrameNo = [self getAvailableFreeFrame];
                if (avaFrameNo.integerValue < 0) {
                    dictPageQueueItem = [self getNextReplaceFrameByPageAlgorithm:mPageAlgorithm];
                    if (dictPageQueueItem == nil) {
                        @throw [NSException exceptionWithName:@"unknowpagealgorithm" reason:@"Page Algorithm is Undefined" userInfo:nil];
                    }
                } else {
                    dictPageQueueItem = [self createPageQueueItemWithSeq:[NSNumber numberWithInteger:mPageQueue.count] AndFrameNo:avaFrameNo];
                }
                
                // Update Page Table
                NSNumber* changeFrameNo = [dictPageQueueItem objectForKey:@"frameno"];
                NSPredicate* predPage = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",changeFrameNo];
                NSArray* arrPage = [mPageList filteredArrayUsingPredicate:predPage];
                for (int i = 0; i < [arrPage count]; i++) {
                    NSDictionary* dictRmPageListItem = [arrPage objectAtIndex:i];
                    [dictRmPageListItem setValue:[NSNumber numberWithInteger:-1] forKey:@"frameno"];
                    [dictRmPageListItem setValue:@NO forKey:@"validbit"];
                }
                dictPageListItem = [self createPageListItemWithSeq:accPageNo AndFrameNo:changeFrameNo];
                [mPageList removeObjectAtIndex:accPageNo.integerValue];
                [mPageList insertObject:dictPageListItem atIndex:accPageNo.integerValue];
                
                // Update Page Queue
                [mPageQueue insertObject:dictPageQueueItem atIndex:0];
            }
            // Update Page Queue (LRU)
            if ([mPageAlgorithm isEqualToString:@"LRU"]) {
                NSNumber* accFrameNo = [dictPageListItem objectForKey:@"frameno"];
                NSPredicate* predPageQueue = [NSPredicate predicateWithFormat:@"%K = %@",@"frameno",accFrameNo];
                NSArray* arrPageQueue = [mPageQueue filteredArrayUsingPredicate:predPageQueue];
                if ([arrPageQueue count] > 0) {
                    NSDictionary* dictPageQueueItem = [arrPageQueue objectAtIndex:0];
                    [mPageQueue removeObject:dictPageQueueItem];
                    [mPageQueue insertObject:dictPageQueueItem atIndex:0];
                } else {
                    @throw [NSException exceptionWithName:@"framenotinqueue" reason:@"Frame No not in Page Queue" userInfo:nil];
                }
            }
            
            // Find Available Free Tlb
            NSDictionary* dictTlbQueueItem;
            NSNumber* avaTlbNo = [self getAvailableFreeTlb];
            if (avaTlbNo.integerValue < 0) {
                dictTlbQueueItem = [self getNextReplaceTlbByTlbAlgorithm:mTlbAlgorithm];
                if (dictTlbQueueItem == nil) {
                    @throw [NSException exceptionWithName:@"unknowtlbalgorithm" reason:@"TLB Algorithm is Undefined" userInfo:nil];
                }
            } else {
                dictTlbQueueItem = [self createTlbQueueItemWIthSeq:[NSNumber numberWithInteger:mTlbQueue.count] AndPageNo:[dictPageListItem objectForKey:@"pageno"] AndFrameNo:[dictPageListItem objectForKey:@"frameno"]];
            }
            
            // Update Tlb
            NSNumber* changeTlbIdx = [dictTlbQueueItem objectForKey:@"seq"];
            NSNumber* changePageNo = [dictTlbQueueItem objectForKey:@"pageno"];
            NSNumber* changeFrameNo = [dictTlbQueueItem objectForKey:@"frameno"];
            NSPredicate* predTlb = [NSPredicate predicateWithFormat:@"%K = %@",@"pageno",changePageNo];
            NSArray* arrTlb = [mTlbList filteredArrayUsingPredicate:predTlb];
            for (int i = 0; i < arrTlb.count; i++) {
                NSDictionary* dictRmTlbListItem = [arrTlb objectAtIndex:i];
                [dictRmTlbListItem setValue:[NSNumber numberWithInteger:-1] forKey:@"pageno"];
                [dictRmTlbListItem setValue:[NSNumber numberWithInteger:-1] forKey:@"frameno"];
                [dictRmTlbListItem setValue:@NO forKey:@"validbit"];
            }
            dictTlbListItem = [self createTlbListItemWithSeq:changeTlbIdx AndPageNo:changePageNo AndFrameNo:changeFrameNo];
            [mTlbList removeObjectAtIndex:changeTlbIdx.integerValue];
            [mTlbList insertObject:dictTlbListItem atIndex:changeTlbIdx.integerValue];
            
            // Update Tlb Queue
            [mTlbQueue insertObject:dictTlbQueueItem atIndex:0];
        }
        // Update Tlb Queue (LRU}
        if ([mTlbAlgorithm isEqualToString:@"LRU"]) {
            NSNumber* accPageNo = [dictTlbListItem objectForKey:@"pageno"];
            NSPredicate* predTlbQueue = [NSPredicate predicateWithFormat:@"%K = %@",@"pageno",accPageNo];
            NSArray* arrTlbQueue = [mTlbQueue filteredArrayUsingPredicate:predTlbQueue];
            if ([arrTlbQueue count] > 0) {
                NSDictionary* dictTlbQueueItem = [arrTlbQueue objectAtIndex:0];
                [mTlbQueue removeObject:dictTlbQueueItem];
                [mTlbQueue insertObject:dictTlbQueueItem atIndex:0];
            } else {
                @throw [NSException exceptionWithName:@"pagenotinqueue" reason:@"Page No not in Tlb Queue" userInfo:nil];
            }
        }
        
        // Insert into Access List
        NSDictionary* dictAccListItem = [self createAccessListItemWithSeq:[NSNumber numberWithInteger:mAccessList.count] AndPageNo:accPageNo AndOffset:accOffset];
        [mAccessList insertObject:dictAccListItem atIndex:mAccessList.count];
        
        // Insert into History List
        NSNumber* hisSeq = [NSNumber numberWithInteger:mAccessList.count];
        NSNumber* hisPageNo = accPageNo;
        NSNumber* hisFrameNo = [dictTlbListItem objectForKey:@"frameno"];
        NSNumber* hisOffset = accOffset;
        NSNumber* hisTlbIndex = [dictTlbListItem objectForKey:@"seq"];
        NSDictionary* dictHisListItem = [self createAccessHistoryListItemWithSeq:hisSeq AndPageNo:hisPageNo AndFrameNo:hisFrameNo AndOffset:hisOffset AndTlbIndex:hisTlbIndex AndTlbHit:isTlbHit AndPageHit:isPageHit];
        [mMemoryAccessHistory insertObject:dictHisListItem atIndex:mMemoryAccessHistory.count];
    }
    @catch (NSException *exception) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[exception description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - Private Function
- (void)resetMemoryAccess {
    if (mAccessList == nil) {
        mAccessList = [[NSMutableArray alloc] init];
    }
    [mAccessList removeAllObjects];
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
        NSDictionary* dictTlbListItem = @{@"seq":[NSNumber numberWithInt:i],@"pageno":[NSNumber numberWithInteger:-1],@"frameno":[NSNumber numberWithInteger:-1],@"validbit":@NO};
        [mTlbList addObject:dictTlbListItem];
    }
}

- (void)resetPageTableByNumber:(NSNumber*)pageno {
    if (mPageList == nil) {
        mPageList = [[NSMutableArray alloc] init];
    }
    [mPageList removeAllObjects];
    for (int i = 0; i < pageno.intValue; i++) {
        NSDictionary* dictPageListItem = @{@"seq":[NSNumber numberWithInt:i],@"frameno":[NSNumber numberWithInteger:-1],@"validbit":@NO};
        [mPageList addObject:dictPageListItem];
    }
}

- (void)resetMemoryFrameByNumber:(NSNumber*)pageno {
    if (mFrameList == nil) {
        mFrameList = [[NSMutableArray alloc] init];
    }
    [mFrameList removeAllObjects];
    for (int i = 0; i < pageno.intValue; i++) {
        NSDictionary* dictFrameListItem = @{@"frameno":[NSNumber numberWithInteger:-1],@"offsets":[[NSMutableArray alloc] init]};
        [mFrameList addObject:dictFrameListItem];
    }
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

- (NSDictionary*)checkTlbListWithPageNo:(NSNumber*)pageno {
    NSPredicate* predTlb = [NSPredicate predicateWithFormat:@"%K = %@",@"pageno",pageno];
    NSArray* arrTlb = [mTlbList filteredArrayUsingPredicate:predTlb];
    if ([arrTlb count] > 0) {
        return [arrTlb objectAtIndex:0];
    } else {
        return nil;
    }
}

- (NSDictionary*)checkPageListWithPageNo:(NSNumber*)pageno {
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

- (NSDictionary*)createAccessListItemWithSeq:(NSNumber*)seq AndPageNo:(NSNumber*)pageno AndOffset:(NSNumber*)offset {
    return @{@"seq":seq,@"pageno":pageno,@"offset":offset};
}

- (NSDictionary*)createPageQueueItemWithSeq:(NSNumber*)seq AndFrameNo:(NSNumber*)frameno {
    return @{@"seq":seq,@"frameno":frameno,@"validbit":@YES};
}

- (NSDictionary*)createPageListItemWithSeq:(NSNumber*)seq AndFrameNo:(NSNumber*)frameno {
    return @{@"seq":seq,@"frameno":frameno,@"validbit":@YES};
}

- (NSDictionary*)createTlbQueueItemWIthSeq:(NSNumber*)seq AndPageNo:(NSNumber*)pageno AndFrameNo:(NSNumber*)frameno {
    return @{@"seq":seq,@"pageno":pageno,@"frameno":frameno,@"validbit":@YES};
}

- (NSDictionary*)createTlbListItemWithSeq:(NSNumber*)seq AndPageNo:(NSNumber*)pageno AndFrameNo:(NSNumber*)frameno {
    return @{@"seq":seq,@"pageno":pageno,@"frameno":frameno,@"validbit":@YES};
}

- (NSDictionary*)createAccessHistoryListItemWithSeq:(NSNumber*)seq AndPageNo:(NSNumber*)pageno AndFrameNo:(NSNumber*)frameno AndOffset:(NSNumber*)offset AndTlbIndex:(NSNumber*)tlbindex AndTlbHit:(BOOL)istlbhit AndPageHit:(BOOL)ispagehit {
    return @{@"seq":seq,@"pageno":pageno,@"frameno":frameno,@"offset":offset,@"tlbindex":tlbindex,@"tlbhit":[NSNumber numberWithBool:istlbhit],@"pagehit":[NSNumber numberWithBool:ispagehit]};
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

- (NSDictionary*)getNextReplaceFrameByPageAlgorithm:(NSString*)pagealgorithm {
    NSDictionary* resultItem;
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
        do {
            int i = 0;
            int index = i % [mPageQueue count];
            
            NSDictionary* dictQueueItem = [sortQueue objectAtIndex:index];
            if ([dictQueueItem objectForKey:@"validbit"] == NO) {
                resultItem = dictQueueItem;
                [mPageQueue removeObject:resultItem];
                break;
            } else {
                [dictQueueItem setValue:@NO forKey:@"validbit"];
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

- (NSDictionary*)getNextReplaceTlbByTlbAlgorithm:(NSString*)tlbalgorithm{
    NSDictionary* resultItem;
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
        do {
            int i = 0;
            int index = i % [mTlbQueue count];
            
            NSDictionary* dictQueueItem = [sortQueue objectAtIndex:index];
            if ([dictQueueItem objectForKey:@"validbit"] == NO) {
                resultItem = dictQueueItem;
                [mTlbQueue removeObject:resultItem];
                break;
            } else {
                [dictQueueItem setValue:@NO forKey:@"validbit"];
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

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
