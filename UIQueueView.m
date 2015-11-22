//
//  QueueView.m
//  protoQueueView
//
//  Created by Favre Thomas on 17/11/2015.
//  Copyright © 2015 Favre Thomas. All rights reserved.
//

#import "UIQueueView.h"

@interface UIQueueView()

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) NSInteger numberOfFake;

@property (nonatomic, assign) CGPoint   basePoint;
@property (nonatomic, assign) CGRect    rectangle;

@property (nonatomic, assign) CGFloat originX;
@property (nonatomic, assign) CGFloat originY;

@property (nonatomic, strong) UIView* container;

@property (nonatomic, assign) UIQueueViewMovingPosition movingPositionForPopItem;

@end

@implementation UIQueueView

//_______________________________________________________________________________________________________________
#pragma mark - init methods
-(id) init{
    if (self = [super init]){
        [self initialize];
    }
    
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        [self initialize];
    }
    
    return self;
}

-(id) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self initialize];
    }
    
    return self;
}

-(void) initialize{
    
    self.currentIndex = 0;
    //self.numberOfFake = 2;
    //self.numberOfItem = 3;
}

#pragma warning

- (nullable UIView *)dequeueReusableItemWithIdentifier:(nonnull NSString *)identifier
                                              forIndex:(NSInteger)index{
    
    // not used yet
    return nil;
}

- (nullable UIView *)dequeueReusableItemWithIdentifier:(nonnull NSString *)identifier{

    if (self.itemIdentifier != nil){
        NSBundle *bundle = [NSBundle mainBundle];
        return [[bundle loadNibNamed:self.itemIdentifier owner:self options:nil] firstObject];
    }
    
    return nil;
}

//_______________________________________________________________________________________________________________
#pragma mark - data manipulation methods

-(UIView*) firstObject{
    return self.item;
}

-(void) pop{
    self.currentIndex++;
    [self.item          removeFromSuperview];
    [self.secondItem    removeFromSuperview];
    [self.container     removeFromSuperview];
}

-(void) popWithPosition:(UIQueueViewMovingPosition)position{
    
    if (position & UIQueueViewMovingPositionRight){
        [self executeSwipeAnimationWithX:[[UIScreen mainScreen]bounds].size.width rotation:M_PI_4 andValue:0.8 position:UIQueueViewMovingPositionRight];
    }
    else if (position & UIQueueViewMovingPositionLeft){
        [self executeSwipeAnimationWithX:0 rotation:-M_PI_4 andValue:-0.8 position:UIQueueViewMovingPositionLeft];
    }
}

-(void) updateStackSize{
    
    if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(numberOfItemInQueueView:)])
        self.numberOfItem = [self.dataSource numberOfItemInQueueView:self];
    
         if (self.currentIndex + 1  >= self.numberOfItem)   { self.numberOfFake = 0; }
    else if (self.currentIndex + 2  == self.numberOfItem)   { self.numberOfFake = 1; }
    else                                                    { self.numberOfFake = 2; }
}

-(void) reloadData{
    
    if (self.currentIndex < self.numberOfItem){
        
        [self.item          removeFromSuperview];
        [self.secondItem    removeFromSuperview];
        [self.container     removeFromSuperview];
        
        if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(movingPositionsForPopItemInQueueView:)])
           self.movingPositionForPopItem   = [self.dataSource movingPositionsForPopItemInQueueView:self];
        
        if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(queueView:cellForItemAtIndex:)])
            self.item = [self.dataSource queueView:self cellForItemAtIndex:self.currentIndex];

        if (self.currentIndex + 1 < self.numberOfItem){
            
            if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(queueView:cellForItemAtIndex:)])
                self.secondItem     = [self.dataSource queueView:self cellForItemAtIndex:self.currentIndex + 1];

            [self addSubview:self.secondItem];
            [self.secondItem setFrame:self.rectangle];
        }
        
        self.container = [[UIView alloc] initWithFrame:self.rectangle];
        [self addSubview:self.container];

        [self.container addSubview:self.item];
        [self.item setFrame:CGRectMake(0, 0, self.rectangle.size.width, self.rectangle.size.height)];
        self.basePoint = self.container.center;
    
        self.originX = self.container.frame.origin.x;
        self.originY = self.container.frame.origin.y;
    
        UIPanGestureRecognizer* pgr = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [self.container addGestureRecognizer:pgr];
    }
    
    //[self setNeedsDisplay];
}

- (nullable UIView*)cellForItemAtIndex:(NSInteger)index{
    
    if      (index == self.currentIndex)        return self.item;
    else if (index == self.currentIndex + 1)    return self.secondItem;
    else                                        return nil;
}

#pragma mark - Animation

- (void)executeSwipeAnimationWithX:(CGFloat)xValue rotation:(CGFloat)angle andValue:(CGFloat)hoverValue position:(UIQueueViewMovingPosition)position{
    [UIView animateWithDuration:0.3 animations:^(void){
        [self.container setCenter:CGPointMake(xValue, self.container.center.y)];
        [self.item setTransform:CGAffineTransformMakeRotation(angle)];
        [self.delegate queueView:self didMovingItemAtIndex:self.currentIndex toPosition:position withAngle:hoverValue];
        [self.delegate queueView:self didFinishMovingItemAtIndex:self.currentIndex toPosition:position withAngle:hoverValue];
        //[self.item  updateHoverViewsWithValue:hoverValue];
    } completion:^(BOOL finished){
        //[dragView fadeOutView];
        [self.item setAlpha:0.0];
        [self pop];
        [self setNeedsDisplay];
    }];
}

//_______________________________________________________________________________________________________________
#pragma mark - draw methods

-(void) drawStackInRect:(CGRect)rect{

    float widthValue    = (rect.size.width * 10  / 100) / 2;
    float heightValue   = (rect.size.height * 10 / 100) / 2;
    
    self.rectangle      = CGRectMake(rect.origin.x + widthValue,
                                     rect.origin.y + heightValue,
                                     rect.size.width - (widthValue * 2),
                                     rect.size.height - (heightValue * 2));
    
    float heightTENPercent = self.rectangle.size.height * 10 / 100;
    
    CGRect firstRectangle = CGRectMake(self.rectangle.origin.x + 5,
                                       self.rectangle.origin.y + 5 + self.rectangle.size.height - heightTENPercent,
                                       self.rectangle.size.width - 10, heightTENPercent);
    
    CGRect secondRectangle = CGRectMake(self.rectangle.origin.x + 10,
                                        self.rectangle.origin.y + 10 + self.rectangle.size.height - heightTENPercent,
                                        self.rectangle.size.width - 20, heightTENPercent);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context,   0.5, 0.5, 0.5, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    
    if (self.numberOfFake >= 2){
        CGContextFillRect(context,      secondRectangle);
        CGContextStrokeRect(context,    secondRectangle);
    }
    
    if (self.numberOfFake >= 1){
        CGContextFillRect(context,      firstRectangle);
        CGContextStrokeRect(context,    firstRectangle);
    }
    
#if TARGET_INTERFACE_BUILDER
    if (self.itemIdentifier != nil){
        NSBundle *bundle    = [NSBundle bundleForClass:[self class]];
        self.testView       = [[bundle loadNibNamed:self.itemIdentifier owner:self options:nil] firstObject];
    }
#endif
    
    //set item
    if (self.currentIndex < self.numberOfItem){
        
        if (self.testView == nil && self.item == nil){
            CGContextFillRect(context,      self.rectangle);
            CGContextStrokeRect(context,    self.rectangle);
        }
        else {
            [self.testView setFrame:self.rectangle];
            [self addSubview:self.testView];
        }
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    [self updateStackSize];
    [self drawStackInRect:rect];
    [self reloadData];
}

//_______________________________________________________________________________________________________________
#pragma mark - UIPanGestureRecognizer

-(void)handlePan:(UIPanGestureRecognizer*)pgr {
    [self updateViewWithGesture:pgr];
}

//Handle view movement with UIGesture states
- (void)updateViewWithGesture:(UIPanGestureRecognizer*)pgr {
    if      (pgr.state == UIGestureRecognizerStateChanged) [self viewIsMoving:pgr];
    else if (pgr.state == UIGestureRecognizerStateEnded)   [self viewEndMoving:pgr];
}

//View is moving
- (void)viewIsMoving:(UIPanGestureRecognizer*)pgr {

    //CGPoint center      = self.item.center;
    CGPoint translation = [pgr translationInView:pgr.view];
    pgr.view.center     = CGPointMake(pgr.view.center.x + translation.x, pgr.view.center.y + translation.y);
    float value         = (pgr.view.center.x - self.basePoint.x) * M_PI * 0.001 * 320 / [[UIScreen mainScreen]bounds].size.width;

    [pgr        setTranslation:CGPointZero inView:pgr.view];
    [pgr.view   setTransform:CGAffineTransformMakeRotation(value)];
    
    UIQueueViewMovingPosition destination = UIQueueViewMovingPositionNone;
    if (self.originX > pgr.view.frame.origin.x){
        destination = destination | UIQueueViewMovingPositionLeft;
    }
    else if (self.originX < pgr.view.frame.origin.x){
        destination = destination | UIQueueViewMovingPositionRight;
    }
    
    if (self.originY > pgr.view.frame.origin.y){
        destination = destination | UIQueueViewMovingPositionTop;
    }
    else if (self.originY < pgr.view.frame.origin.y){
        destination = destination | UIQueueViewMovingPositionBottom;
    }
    
    [self.delegate queueView:self
        didMovingItemAtIndex:self.currentIndex
                  toPosition:destination
                   withAngle:value];
}

- (void)viewEndMoving:(UIPanGestureRecognizer*)pgr {
    float valueToDelete = 40    * [[UIScreen mainScreen]bounds].size.width / 320;
    float valueToKeep   = 280   * [[UIScreen mainScreen]bounds].size.width / 320;
    
    UIQueueViewMovingPosition destination = UIQueueViewMovingPositionNone;
    if      (self.originX > self.container.frame.origin.x)   { destination = destination | UIQueueViewMovingPositionLeft;    }
    else if (self.originX < self.container.frame.origin.x)   { destination = destination | UIQueueViewMovingPositionRight;   }
    
    if      (self.originY > self.container.frame.origin.y)   { destination = destination | UIQueueViewMovingPositionTop;     }
    else if (self.originY < self.container.frame.origin.y)   { destination = destination | UIQueueViewMovingPositionBottom;  }
    
    if (self.container.center.x > valueToDelete && self.container.center.x < valueToKeep) {
        [self.delegate queueView:self didFinishMovingItemAtIndex:self.currentIndex toPosition:UIQueueViewMovingPositionMiddle withAngle:0];
        [UIView animateWithDuration:0.3 animations:^(void){
            [UIView animateWithDuration:0.3
                             animations:^{
                                 [self.container setTransform:CGAffineTransformMakeRotation(0)];
                                 [self.container setCenter:self.basePoint];
                             } completion:^(BOOL finished) {
                             }];
        }];
    }
    else {
        if(self.container.center.x <= valueToDelete)
        {
            if (self.movingPositionForPopItem & UIQueueViewMovingPositionLeft){
                [self.delegate queueView:self didFinishMovingItemAtIndex:self.currentIndex toPosition:destination withAngle:0];
                    [UIView animateWithDuration:0.25 animations:^(void) {
                        [self.item setAlpha:0.0];
                        
                    } completion:^(BOOL finisehd) {
                        [self pop];
                        [self setNeedsDisplay];
                    }];
                
                
            }
        }
        else if(self.container.center.x >= valueToKeep)
        {
            if (self.movingPositionForPopItem & UIQueueViewMovingPositionRight){
                [self.delegate queueView:self didFinishMovingItemAtIndex:self.currentIndex toPosition:destination withAngle:0];
                [UIView animateWithDuration:0.25 animations:^(void) {
                    [self.item setAlpha:0.0];
                } completion:^(BOOL finisehd) {
                    //[self.dragDelegate didEndDragging];
                    [self pop];
                    [self setNeedsDisplay];
                }];
            }
        }
    }
    
}

@end
