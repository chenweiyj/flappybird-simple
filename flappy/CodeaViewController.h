//
//  CodeaViewController.h
//  flappy
//
//  Created by Dzanvu on 2014年5月30日 星期五
//  Copyright (c) Dzanvu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CodeaAddon;

typedef enum CodeaViewMode
{
    CodeaViewModeStandard,
    CodeaViewModeFullscreen,
    CodeaViewModeFullscreenNoButtons,
} CodeaViewMode;

@interface CodeaViewController : UIViewController

@property (nonatomic, assign) CodeaViewMode viewMode;
@property (nonatomic, assign) BOOL paused;

- (void) setViewMode:(CodeaViewMode)viewMode animated:(BOOL)animated;

- (void) loadProjectAtPath:(NSString*)path;

- (void) registerAddon:(id<CodeaAddon>)addon;

@end
