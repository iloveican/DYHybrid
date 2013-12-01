//
//  DYPhotoScrollView.m
//  DYHybrid
//
//  Created by danyun on 11/30/13.
//  Copyright (c) 2013 liudanyun@gmail.com. All rights reserved.
//

#import "DYPhotoScrollView.h"

static NSString *sObservedPath = @"image";

@implementation DYPhotoScrollView

- (instancetype)init
{
    self = [super init];
    [self initImageView];
    return  self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initImageView];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initImageView];
    return self;
}

- (void)dealloc
{
    [self.zoomedImageView removeObserver:self forKeyPath:sObservedPath];
}

- (void)initImageView
{
    self.delegate = self;
    self.zoomedImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    [self addSubview:self.zoomedImageView];
    [self.zoomedImageView addObserver:self forKeyPath:sObservedPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:sObservedPath]) {
        [self showImage];
    }
}

- (void)showImage
{
    __strong UIImage *zoomedImage = self.zoomedImageView.image;
    if (zoomedImage) {
        //for some uncertain reason, if you reuse the zoomedImageView, the scale of the second image will be incorrect.
        //todo: reuse the image view
        [self.zoomedImageView removeObserver:self forKeyPath:sObservedPath];
        [self.zoomedImageView removeFromSuperview];
        self.zoomedImageView = [[UIImageView alloc]initWithImage:zoomedImage];
        self.zoomedImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=zoomedImage.size};
        self.zoomedImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.zoomedImageView];
        [self.zoomedImageView addObserver:self forKeyPath:sObservedPath options:NSKeyValueObservingOptionNew context:nil];
        self.contentSize = zoomedImage.size;
        self.contentOffset = CGPointZero;
        CGRect scrollViewFrame = self.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / self.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        minScale = MIN(minScale, 1.0); //in case the min scale > 1.0;
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = 1.0;
        self.zoomScale = minScale;
        [self centerScrollViewContents];
    }
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomedImageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.zoomedImageView.frame;
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.zoomedImageView.frame = contentsFrame;
}

@end