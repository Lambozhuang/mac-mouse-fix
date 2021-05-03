//
// --------------------------------------------------------------------------
// SparkleUpdateDelegate.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2021
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "SparkleUpdaterController.h"
#import "AppDelegate.h"
#import "SharedUtility.h"
#import "Objects.h"

// See https://sparkle-project.org/documentation/customization/

@implementation SparkleUpdaterController

+ (void)enablePrereleaseChannel:(BOOL)pre {
    if (pre) {
        SUUpdater.sharedUpdater.feedURL = [NSURL URLWithString:fstring(@"%@/%@", kMFUpdateFeedRepoAddressRaw, kSUFeedURLSubBeta)];
    } else {
        SUUpdater.sharedUpdater.feedURL = [NSURL URLWithString:fstring(@"%@/%@", kMFUpdateFeedRepoAddressRaw, kSUFeedURLSub)];
    }
}

- (BOOL)updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater *)updater {
    return NO;
}

- (void)updaterDidRelaunchApplication:(SUUpdater *)updater {
    
    NSLog(@"Has been launched by Sparkle Updater");
    
    // Log the fact that updater launched the application in appState()
    
    appState().updaterDidRelaunchApplication = YES;
    // ^ We use this from `AppDelegate - applicationDidFinishLaunching`.
    
    // Find and kill helper
    
    // The updated helper application will subsequently be launched by launchd due to the keepAlive attribute in Mac Mouse Fix Helper's launchd.plist
    // It might be more robust and simple to find and kill any strange helpers *whenever* the app starts, but this should work, too.
    BOOL helperNeutralized = NO;
    for (NSRunningApplication *app in [NSRunningApplication runningApplicationsWithBundleIdentifier:kMFBundleIDHelper]) {
        if ([app.bundleURL isEqualTo: Objects.helperOriginalBundle.bundleURL]) {
            [app terminate];
            helperNeutralized = YES;
            break;
        }
    }
    
    if (helperNeutralized) {
        NSLog(@"Helper has been neutralized");
    } else {
        NSLog(@"No helper found to neutralize");
    }
    
}



@end