//
//  ActionRequestHandler.m
//  WebUpperCase
//
//  Created by Thomas Eichmann on 15.08.14.
//  Copyright (c) 2014 Thomas Eichmann. All rights reserved.
//

#import "ActionRequestHandler.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionRequestHandler ()

@property (nonatomic, strong) NSExtensionContext *extensionContext;

@end

@implementation ActionRequestHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context
{
    // Do not call super in an Action extension with no user interface
    self.extensionContext = context;
    
    BOOL found = NO;
    
    // Find the item containing the results from the JavaScript preprocessing.
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *dictionary, NSError *error) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self itemLoadCompletedWithPreprocessingResults:dictionary[NSExtensionJavaScriptPreprocessingResultsKey]];
                    }];
                }];
                found = YES;
            }
            break;
        }
        if (found) {
            break;
        }
    }
    
    if (!found) {
        // We did not find anything
        [self doneWithResults:nil];
    }
}

- (void)itemLoadCompletedWithPreprocessingResults:(NSDictionary *)javaScriptPreprocessingResults
{
    // Here, do something, potentially asynchronously, with the preprocessing
    // results.

    NSMutableString *newDocumentTitle = [[NSMutableString alloc] initWithString:@"UPPERCASED"];
    NSString *documentTitle = javaScriptPreprocessingResults[@"documentTitle"];

    if (documentTitle && documentTitle.length > 0) {
        [newDocumentTitle appendFormat:@" :: %@", documentTitle];
    }


    [self doneWithResults:@{@"newDocumentTitle":newDocumentTitle}];
}

- (void)doneWithResults:(NSDictionary *)resultsForJavaScriptFinalize
{
    if (resultsForJavaScriptFinalize) {
        // Construct an NSExtensionItem of the appropriate type to return our
        // results dictionary in.
        
        // These will be used as the arguments to the JavaScript finalize()
        // method.
        
        NSDictionary *resultsDictionary = @{NSExtensionJavaScriptFinalizeArgumentKey:resultsForJavaScriptFinalize};
        
        NSItemProvider *resultsProvider = [[NSItemProvider alloc] initWithItem:resultsDictionary typeIdentifier:(NSString *)kUTTypePropertyList];
        
        NSExtensionItem *resultsItem = [[NSExtensionItem alloc] init];
        resultsItem.attachments = @[resultsProvider];
        
        // Signal that we're complete, returning our results.
        [self.extensionContext completeRequestReturningItems:@[resultsItem] completionHandler:nil];
    } else {
        // We still need to signal that we're done even if we have nothing to
        // pass back.
        [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
    }
    
    // Don't hold on to this after we finished with it.
    self.extensionContext = nil;
}

@end
