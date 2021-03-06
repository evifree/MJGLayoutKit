//
//  MJGLKLinearLayout.m
//  MJGLayoutKit
//
//  Created by Matt Galloway on 03/01/2012.
//  Copyright (c) 2012 Matt Galloway. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file requires ARC to be enabled. Either enable ARC for the entire project or use -fobjc-arc flag.
#endif

#import "MJGLKLinearLayout.h"

#import "MJGLKLayout+Private.h"

@interface MJGLKLinearLayout ()
@property (nonatomic, assign, readwrite) MJGLKLinearLayoutOrientation orientation;

@property (nonatomic, strong) UIView *wrapperView;
@end

@implementation MJGLKLinearLayout

@synthesize orientation = _orientation;
@synthesize wrapperView = _wrapperView;

#pragma mark -

- (id)initWithOrientation:(MJGLKLinearLayoutOrientation)inOrientation views:(NSArray *)views {
    if ((self = [super initWithViews:views])) {
        self.orientation = inOrientation;
        self.wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
        self.wrapperView.backgroundColor = [UIColor clearColor];
        self.wrapperView.opaque = NO;
    }
    return self;
}


#pragma mark - Custom accessors

- (UIColor*)backgroundColor {
    return self.wrapperView.backgroundColor;
}

- (void)setBackgroundColor:(UIColor*)backgroundColor {
    self.wrapperView.backgroundColor = backgroundColor;
}


#pragma mark -

- (UIView*)view {
    return self.wrapperView;
}

- (void)measureViewWithWidth:(MJGLKDimension)width andHeight:(MJGLKDimension)height {
    if (_orientation == MJGLKLinearLayoutOrientationVertical) {
        CGFloat totalHeight = 0.0f;
        CGFloat maxWidth = 0.0f;
        CGFloat totalWeight = 0.0f;
        
        for (MJGLKView *view in self.views) {
            if (view.layoutSpec.weight > 0.0f) {
                totalWeight += view.layoutSpec.weight;
            }
            
            MJGLKDimension childWidth = [self _childDimensionFromParentDimension:width 
                                                                     withPadding:(self.layoutSpec.padding.left + self.layoutSpec.padding.right + view.layoutSpec.margin.left + view.layoutSpec.margin.right) 
                                                                   withChildSize:view.layoutSpec.width];
            MJGLKDimension childHeight = [self _childDimensionFromParentDimension:height 
                                                                      withPadding:(self.layoutSpec.padding.top + self.layoutSpec.padding.bottom + view.layoutSpec.margin.top + view.layoutSpec.margin.bottom) 
                                                                    withChildSize:view.layoutSpec.height];
            
            [view updateViewWidth:childWidth andHeight:childHeight];
            totalHeight += (view.layoutSpec.margin.top + view.measuredSize.height + view.layoutSpec.margin.bottom);
            
            maxWidth = MAX(maxWidth, view.measuredSize.width + view.layoutSpec.margin.left + view.layoutSpec.margin.right);
        }
        
        totalHeight += (self.layoutSpec.padding.top + self.layoutSpec.padding.bottom);
        
        CGFloat actualHeight = totalHeight;
        actualHeight = ReconcileSizeWithDimension(actualHeight, height);
        
        CGFloat delta = actualHeight - totalHeight;
        if (delta != 0.0f && totalWeight > 0.0f) {
            totalHeight = 0.0f;
            
            // There's some views that can take some extra height
            for (MJGLKView *view in self.views) {
                if (view.layoutSpec.weight > 0) {
                    CGFloat thisShare = floorf(((view.layoutSpec.weight * delta) / totalWeight));
                    
                    MJGLKDimension childWidth = [self _childDimensionFromParentDimension:width 
                                                                             withPadding:(self.layoutSpec.padding.left + self.layoutSpec.padding.right + view.layoutSpec.margin.left + view.layoutSpec.margin.right) 
                                                                           withChildSize:view.layoutSpec.width];
                    MJGLKDimension childHeight = MJGLKDimensionMake((NSInteger)(view.measuredSize.height + thisShare), MJGLKSizeConstraintExact);
                    [view updateViewWidth:childWidth andHeight:childHeight];
                }
                
                totalHeight += (view.layoutSpec.margin.top + view.measuredSize.height + view.layoutSpec.margin.bottom);
                
                maxWidth = MAX(maxWidth, view.measuredSize.width + view.layoutSpec.margin.left + view.layoutSpec.margin.right);
            }
            
            totalHeight += (self.layoutSpec.padding.top + self.layoutSpec.padding.bottom);
        }
        
        if (width.constraint != MJGLKSizeConstraintExact) {
            for (MJGLKView *view in self.views) {
                if (view.layoutSpec.width == MJGLKSizeFillParent) {
                    MJGLKDimension childWidth = MJGLKDimensionMake(maxWidth - view.layoutSpec.margin.left - view.layoutSpec.margin.right, MJGLKSizeConstraintExact);
                    MJGLKDimension childHeight = MJGLKDimensionMake((NSInteger)(view.measuredSize.height), MJGLKSizeConstraintExact);
                    [view updateViewWidth:childWidth andHeight:childHeight];
                }
            }
        }
        
        maxWidth += (self.layoutSpec.padding.left + self.layoutSpec.padding.right);
        
        self.measuredSize = CGSizeMake(maxWidth, totalHeight);
    } else {
        CGFloat totalWidth = 0.0f;
        CGFloat maxHeight = 0.0f;
        CGFloat totalWeight = 0.0f;
        
        for (MJGLKView *view in self.views) {
            if (view.layoutSpec.weight > 0.0f) {
                totalWeight += view.layoutSpec.weight;
            }
            
            MJGLKDimension childWidth = [self _childDimensionFromParentDimension:width 
                                                                     withPadding:(self.layoutSpec.padding.left + self.layoutSpec.padding.right + view.layoutSpec.margin.left + view.layoutSpec.margin.right) 
                                                                   withChildSize:view.layoutSpec.width];
            MJGLKDimension childHeight = [self _childDimensionFromParentDimension:height 
                                                                      withPadding:(self.layoutSpec.padding.top + self.layoutSpec.padding.bottom + view.layoutSpec.margin.top + view.layoutSpec.margin.bottom) 
                                                                    withChildSize:view.layoutSpec.height];
            
            [view updateViewWidth:childWidth andHeight:childHeight];
            totalWidth += (view.layoutSpec.margin.left + view.measuredSize.width + view.layoutSpec.margin.right);
            
            maxHeight = MAX(maxHeight, view.measuredSize.height + view.layoutSpec.margin.top + view.layoutSpec.margin.bottom);
        }
        
        totalWidth += (self.layoutSpec.padding.left + self.layoutSpec.padding.right);
        
        CGFloat actualWidth = totalWidth;
        actualWidth = ReconcileSizeWithDimension(actualWidth, width);
        
        CGFloat delta = actualWidth - totalWidth;
        if (delta != 0.0f && totalWeight > 0.0f) {
            totalWidth = 0.0f;
            
            // There's some views that can take some extra height
            for (MJGLKView *view in self.views) {
                if (view.layoutSpec.weight > 0) {
                    CGFloat thisShare = floorf(((view.layoutSpec.weight * delta) / totalWeight));
                    
                    MJGLKDimension childHeight = [self _childDimensionFromParentDimension:height 
                                                                              withPadding:(self.layoutSpec.padding.top + self.layoutSpec.padding.bottom + view.layoutSpec.margin.top + view.layoutSpec.margin.bottom) 
                                                                            withChildSize:view.layoutSpec.height];
                    MJGLKDimension childWidth = MJGLKDimensionMake((NSInteger)(view.measuredSize.width + thisShare), MJGLKSizeConstraintExact);
                    [view updateViewWidth:childWidth andHeight:childHeight];
                }
                
                totalWidth += (view.layoutSpec.margin.left + view.measuredSize.width + view.layoutSpec.margin.right);
                
                maxHeight = MAX(maxHeight, view.measuredSize.height + view.layoutSpec.margin.top + view.layoutSpec.margin.bottom);
            }
            
            totalWidth += (self.layoutSpec.padding.left + self.layoutSpec.padding.right);
        }
        
        if (height.constraint != MJGLKSizeConstraintExact) {
            for (MJGLKView *view in self.views) {
                if (view.layoutSpec.height == MJGLKSizeFillParent) {
                    MJGLKDimension childWidth = MJGLKDimensionMake((NSInteger)(view.measuredSize.width), MJGLKSizeConstraintExact);
                    MJGLKDimension childHeight = MJGLKDimensionMake(maxHeight - view.layoutSpec.margin.top - view.layoutSpec.margin.bottom, MJGLKSizeConstraintExact);
                    [view updateViewWidth:childWidth andHeight:childHeight];
                }
            }
        }
        
        maxHeight += (self.layoutSpec.padding.top + self.layoutSpec.padding.bottom);
        
        self.measuredSize = CGSizeMake(totalWidth, maxHeight);
    }
}

- (void)performLayoutView {
    if (_orientation == MJGLKLinearLayoutOrientationVertical) {
        CGFloat currentY = self.layoutSpec.padding.top;
        
        for (MJGLKView *view in self.views) {
            MJGLKGravity childGravity = [self _resolveGravityFromParentGravity:self.layoutSpec.gravity andChildLayoutGravity:view.layoutSpec.layoutGravity];
            
            currentY += view.layoutSpec.margin.top;
            
            CGRect childFrame = CGRectZero;
            childFrame.size = CGSizeMake(view.measuredSize.width, view.measuredSize.height);
            childFrame.origin.y = currentY;
            
            MJGLKGravity childHorizontalGravity = childGravity & MJGLKGravityHorizontalMask;
            switch (childHorizontalGravity) {
                case MJGLKGravityLeft:
                case MJGLKGravityUnspecified:
                default: {
                    childFrame.origin.x = self.layoutSpec.padding.left + view.layoutSpec.margin.left;
                }
                    break;
                case MJGLKGravityRight: {
                    childFrame.origin.x = self.measuredSize.width - self.layoutSpec.padding.right - view.measuredSize.width - view.layoutSpec.margin.right;
                }
                    break;
                case MJGLKGravityCenterHorizontal: {
                    childFrame.origin.x = (self.measuredSize.width - view.measuredSize.width) / 2.0f;
                }
                    break;
            }
            
            [self.view addSubview:view.view];
            view.view.frame = childFrame;
            [view layoutView];
            currentY += (view.measuredSize.height + view.layoutSpec.margin.bottom);
        }
    } else {
        CGFloat currentX = self.layoutSpec.padding.left;
        
        for (MJGLKView *view in self.views) {
            MJGLKGravity childGravity = [self _resolveGravityFromParentGravity:self.layoutSpec.gravity andChildLayoutGravity:view.layoutSpec.layoutGravity];
            
            currentX += view.layoutSpec.margin.left;
            
            CGRect childFrame = CGRectZero;
            childFrame.size = CGSizeMake(view.measuredSize.width, view.measuredSize.height);
            childFrame.origin.x = currentX;
            
            MJGLKGravity childVerticalGravity = childGravity & MJGLKGravityVerticalMask;
            switch (childVerticalGravity) {
                case MJGLKGravityTop:
                case MJGLKGravityUnspecified:
                default: {
                    childFrame.origin.y = self.layoutSpec.padding.top + view.layoutSpec.margin.top;
                }
                    break;
                case MJGLKGravityBottom: {
                    childFrame.origin.y = self.measuredSize.height - self.layoutSpec.padding.bottom - view.measuredSize.height - view.layoutSpec.margin.bottom;
                }
                    break;
                case MJGLKGravityCenterVertical: {
                    childFrame.origin.y = (self.measuredSize.height - view.measuredSize.height) / 2.0f;
                }
                    break;
            }
            
            [self.view addSubview:view.view];
            view.view.frame = childFrame;
            [view layoutView];
            currentX += (view.measuredSize.width + view.layoutSpec.margin.right);
        }
    }
}

@end
