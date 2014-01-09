//
//  OCFeedSettingsController.m
//  iOCNews
//

/************************************************************************
 
 Copyright 2013 Peter Hedlund peter.hedlund@me.com
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 *************************************************************************/

#import "OCFeedSettingsController.h"
#import "OCNewsHelper.h"
#import "OCFolderTableViewController.h"

@interface OCFeedSettingsController () {
    NSArray *_cells;
    NSNumber *_newFolderId;
}

@end

@implementation OCFeedSettingsController

@synthesize delegate;
@synthesize titleTextField;
@synthesize fullArticleSwitch;
@synthesize readerSwitch;
@synthesize feed = _feed;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Extra

- (void)setFeed:(Feed *)feed {
    if (_feed != feed) {
        _feed = feed;
        
        self.titleTextField.text = feed.extra.displayTitle;
        self.urlTextView.text = feed.url;
        self.titleTextView.text = feed.title;
        self.fullArticleSwitch.on = feed.extra.preferWebValue;
        self.readerSwitch.on = feed.extra.useReaderValue;
        self.readerSwitch.enabled = self.fullArticleSwitch.on;
        self.keepStepper.value = 300; //TODO: feed.extra.keepCount
        self.keepLabel.text = [NSString stringWithFormat:@"%.f", self.keepStepper.value];
        _newFolderId = feed.folderId;
    }
}

- (IBAction)doSave:(id)sender {
    //self.feed.extra.displayTitle = self.titleTextField.text;
    self.feed.extra.preferWebValue = self.fullArticleSwitch.on;
    self.feed.extra.useReaderValue = self.readerSwitch.on;
    //TODO: self.feed.extra.keepCount = self.keepStepper.value;
    if (![self.feed.folderId isEqual:_newFolderId]) {
        self.feed.folderId = _newFolderId;
        [[OCNewsHelper sharedHelper] moveFeedOfflineWithId:self.feed.myId toFolderWithId:self.feed.folderId];
    }
    [[OCNewsHelper sharedHelper] saveContext];
    if (self.delegate) {
        [self.delegate feedSettingsUpdate:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)fullArticleStateChanged:(id)sender {
    self.readerSwitch.enabled = self.fullArticleSwitch.on;
}

- (IBAction)keepCountChanged:(id)sender {
    if ([sender isEqual:self.keepStepper]) {
        self.keepLabel.text = [NSString stringWithFormat:@"%.f", self.keepStepper.value];
    }
}

- (IBAction)doCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"folderSegue"]) {
         OCFolderTableViewController *folderController = (OCFolderTableViewController*)segue.destinationViewController;
         folderController.feed = self.feed;
         folderController.folders = [[OCNewsHelper sharedHelper] folders];
         folderController.delegate = self;
     }
 }

- (void)folderSelected:(NSNumber *)folder {
    _newFolderId = folder;
}
 
@end
