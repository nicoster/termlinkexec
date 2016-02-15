//
//  LinkExec.h
//  termlinkexec
//
//  Created by Nick Xiao on 2/15/16.
//  Copyright © 2016 Nick Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkExec : NSObject
+ (void) load;
@end

@interface TTShell: NSObject
- (void) writeData: (NSData*) data;
@end

@interface TTTabController: NSObject
- (TTShell*) shell;
@end

@interface TTView: NSView
- (TTTabController*) controller;
- (void) clearTextSelection;
@end