//
//  ShareViewController.m
//  ShareToNil
//
//  Created by Thomas Eichmann on 18.08.14.
//  Copyright (c) 2014 Thomas Eichmann. All rights reserved.
//

#import "ShareViewController.h"

static const NSUInteger kMaxCharacters = 160;

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid
{
    self.charactersRemaining = @(kMaxCharacters - self.contentText.length);

    return YES;
}

- (void)didSelectPost
{
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}

- (NSArray *)configurationItems
{
    return @[];
}

@end
