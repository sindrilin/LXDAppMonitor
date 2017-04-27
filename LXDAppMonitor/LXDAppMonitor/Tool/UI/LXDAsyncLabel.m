//
//  LXDAsyncLabel.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDAsyncLabel.h"
#import "LXDDispatchAsync.h"
#import <CoreText/CoreText.h>


@implementation LXDAsyncLabel


- (void)setText: (NSString *)text {
    if ([NSThread isMainThread]) {
        LXDDispatchQueueAsyncBlockInBackground(^{
            [self displayAttributedText: [[NSAttributedString alloc] initWithString: text attributes: @{ NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor }]];
        });
    } else {
        [self displayAttributedText: [[NSAttributedString alloc] initWithString: text attributes: @{ NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor }]];
    }
}

- (void)setAttributedText: (NSAttributedString *)attributedText {
    if ([NSThread isMainThread]) {
        LXDDispatchQueueAsyncBlockInBackground(^{
            [self displayAttributedText: attributedText];
        });
    } else {
        [self displayAttributedText: attributedText];
    }
}

- (void)displayAttributedText: (NSAttributedString *)attributedText {
    if (attributedText == nil) {
        attributedText = [NSMutableAttributedString new];
    } else if ([attributedText isMemberOfClass: [NSAttributedString class]]) {
        attributedText = attributedText.mutableCopy;
    }
    
    NSMutableParagraphStyle * style = [NSMutableParagraphStyle new];
    style.alignment = self.textAlignment;
    [((NSMutableAttributedString *)attributedText) addAttributes: @{ NSParagraphStyleAttributeName: style } range: NSMakeRange(0, attributedText.length)];
    
    CGSize size = self.frame.size;
    size.height += 10;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context != NULL) {
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        CGSize textSize = [attributedText.string boundingRectWithSize: size options: NSStringDrawingUsesLineFragmentOrigin attributes: @{ NSFontAttributeName: self.font } context: nil].size;
        textSize.width = ceil(textSize.width);
        textSize.height = ceil(textSize.height);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake((size.width - textSize.width) / 2, 5, textSize.width, textSize.height));
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedText.length), path, NULL);
        CTFrameDraw(frame, context);
        
        UIImage * contents = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CFRelease(frameSetter);
        CFRelease(frame);
        CFRelease(path);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.layer.contents = (id)contents.CGImage;
        });
    }
}


@end
