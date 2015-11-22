//
//  QueueView.h
//  protoQueueView
//
//  Created by Favre Thomas on 17/11/2015.
//  Copyright © 2015 Favre Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_NUMBER_OF_FAKE_ITEM 2

@class UIQueueView;

typedef NS_ENUM(NSInteger, UIQueueViewMovingPosition) {
    UIQueueViewMovingPositionNone   = 1 << 0,
    UIQueueViewMovingPositionTop    = 1 << 1,
    UIQueueViewMovingPositionMiddle = 1 << 2,
    UIQueueViewMovingPositionBottom = 1 << 3,
    UIQueueViewMovingPositionLeft   = 1 << 4,
    UIQueueViewMovingPositionRight  = 1 << 5
};                // moving position of an item

//_______________________________________________________________________________________________________________
// this represents the display and behaviour of the cells.

@protocol UIQueueViewDelegate<NSObject>


-(void)queueView:(nonnull UIQueueView *)queueView didMovingItemAtIndex:(NSInteger)index toPosition:(UIQueueViewMovingPosition)position withAngle:(CGFloat)angle;

-(void)queueView:(nonnull UIQueueView *)queueView didFinishMovingItemAtIndex:(NSInteger)index toPosition:(UIQueueViewMovingPosition)position withAngle:(CGFloat)angle;

@end

//_______________________________________________________________________________________________________________
// this protocol represents the data model object. as such, it supplies no information about appearance (including the cells)
 
@protocol UIQueueViewDataSource<NSObject>

-(nullable UIView*)queueView:(nonnull UIQueueView *)queueView cellForItemAtIndex:(NSInteger)index;

-(NSInteger)numberOfItemInQueueView:(nonnull UIQueueView *)queueView;
-(UIQueueViewMovingPosition) movingPositionsForPopItemInQueueView:(nonnull UIQueueView *)queueView;

@end

//_______________________________________________________________________________________________________________

IB_DESIGNABLE
@interface UIQueueView : UIView

@property (nonatomic, strong, nullable) UIView* item;
@property (nonatomic, strong, nullable) UIView* secondItem;

@property (nonatomic, assign)           IBInspectable NSInteger numberOfItem;
@property (nonatomic, strong, nullable) IBInspectable NSString* itemIdentifier;

@property (weak, nonatomic, nullable) IBOutlet UIView *testView;

@property (nonatomic, weak, nullable) id <UIQueueViewDataSource>    dataSource;
@property (nonatomic, weak, nullable) id <UIQueueViewDelegate>      delegate;

-(void) reloadData;

- (nullable UIView*)cellForItemAtIndex:(NSInteger)index;

- (nullable UIView *)dequeueReusableItemWithIdentifier:(nonnull NSString *)identifier;

-(void) popWithPosition:(UIQueueViewMovingPosition)position;

-(nullable UIView*) firstObject;

@end

