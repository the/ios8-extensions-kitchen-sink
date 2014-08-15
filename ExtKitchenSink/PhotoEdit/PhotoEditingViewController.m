//
//  PhotoEditingViewController.m
//  PhotoEdit
//
//  Created by Thomas Eichmann on 15.08.14.
//  Copyright (c) 2014 Thomas Eichmann. All rights reserved.
//

#import "PhotoEditingViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <CoreImage/CoreImage.h>

static NSString * const kFilterName = @"CIPhotoEffectNoir";

@interface PhotoEditingViewController () <PHContentEditingController>
@property (strong) PHContentEditingInput *input;
@property (strong) CIContext *ciContext;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@end

@implementation PhotoEditingViewController

#pragma mark - PHContentEditingController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ciContext = [CIContext contextWithOptions:nil];
}

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData
{
    return NO;
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage
{
    self.input = contentEditingInput;
    self.previewImageView.image = self.input.displaySizeImage;

    CIFilter *ciFilter = [CIFilter filterWithName:kFilterName];
    [ciFilter setDefaults];

    CIImage *inputImage = [[CIImage alloc] initWithImage:self.input.displaySizeImage];
    [ciFilter setValue:inputImage forKey:kCIInputImageKey];
    UIImage *filteredImage = [[UIImage alloc] initWithCIImage:ciFilter.outputImage];

    self.previewImageView.image = filteredImage;

}

- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler
{
    // Render and provide output on a background queue.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Create editing output from the editing input.
        PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];

        CIFilter *ciFilter = [CIFilter filterWithName:kFilterName];
        [ciFilter setDefaults];

        NSData *fullSizeInputImageData = [NSData dataWithContentsOfURL:self.input.fullSizeImageURL];
        UIImage *fullSizeInputImage = [UIImage imageWithData:fullSizeInputImageData];
        CIImage *inputImage = [[CIImage alloc] initWithImage:fullSizeInputImage];
        inputImage = [inputImage imageByApplyingOrientation:self.input.fullSizeImageOrientation];
        [ciFilter setValue:inputImage forKey:kCIInputImageKey];

        CIImage *outputCIImage = ciFilter.outputImage;
        CGImageRef outputCGImage = [self.ciContext createCGImage:outputCIImage fromRect:[outputCIImage extent]];
        UIImage *outputImage = [UIImage imageWithCGImage:outputCGImage];
        CFRelease(outputCGImage);
        NSData *outputJPEGData = UIImageJPEGRepresentation(outputImage, 0.9);

        // adjustment info required, otherwise behavior is undefined
        NSString *formatIdentifier = @"com.github.the.ExtKitchenSink";
        NSString *formatVersion = @"1.0";
        NSData *dummyAdjustmentData = [[NSData alloc] init];
        output.adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:formatIdentifier
                                                                     formatVersion:formatVersion
                                                                              data:dummyAdjustmentData];

        [outputJPEGData writeToURL:output.renderedContentURL atomically:YES];
        completionHandler(output);
    });
}

- (BOOL)shouldShowCancelConfirmation
{
    return NO;
}

- (void)cancelContentEditing
{

}

@end
