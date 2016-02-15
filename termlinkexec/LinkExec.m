//
//  LinkExec.m
//  termlinkexec
//
//  Created by Nick Xiao on 2/15/16.
//  Copyright © 2016 Nick Xiao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinkExec.h"
#import <objc/runtime.h>
#import "JRSwizzle.h"

NSString* SCHEME=@"sh";

#define EXISTS(cls, sel)                                                 \
do {                                                                 \
if (!class_getInstanceMethod(cls, sel))                          \
{                                                                \
NSLog(@"[MouseTerm] ERROR: Got nil Method for [%@ %@]", cls, \
NSStringFromSelector(sel));                            \
return;                                                      \
}                                                                \
} while (0)

#define SWIZZLE(cls, sel1, sel2)                                        \
do {                                                                \
NSError *err = nil;                                             \
if (![cls jr_swizzleMethod: sel1 withMethod: sel2 error: &err]) \
{                                                               \
NSLog(@"[MouseTerm] ERROR: Failed to swizzle [%@ %@]: %@",  \
cls, NSStringFromSelector(sel1), err);                \
return;                                                     \
}                                                               \
} while (0)

@implementation NSString (stringByDecodingURLFormat)
- (NSString *)stringByDecodingURLFormat
{
	NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
	result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return result;
}
@end

@implementation NSView (MTView)
- (void) LinkExec_mouseUp: (NSEvent*) event
{
	NSURL* clickedURL = nil;
	object_getInstanceVariable(self, "_clickedURL", (void**)&clickedURL);
	NSLog(@"mouseup, url:%@", [clickedURL description]);
	
	if ([clickedURL.scheme isEqualToString: SCHEME]) {
		NSString* encodedURL = [clickedURL.description substringFromIndex: [[SCHEME stringByAppendingString:@"://" ] length]];
		NSString* cmd = [NSString stringWithFormat:@"%@\n", [encodedURL stringByDecodingURLFormat]];
		TTShell* shell = [[(TTView*) self controller] shell];
		[shell writeData: [cmd dataUsingEncoding: NSUTF8StringEncoding]];
		
		// to suppress the original behavior of Terminal.app, popup a dialog prompting no application can handle sh://
		object_setInstanceVariable(self, "_clickedURL", nil);
		[clickedURL release];
		[(TTView*) self clearTextSelection];
	}
	
	[self LinkExec_mouseUp: event];
}
@end


@implementation LinkExec

+ (void) load
{
	NSLog(@"[MouseTerm] load");
	Class view = NSClassFromString(@"TTView");
	if (!view)
	{
		NSLog(@"[MouseTerm] ERROR: Got nil Class for TTView");
		return;
	}
	
	SWIZZLE(view, @selector(mouseUp:), @selector(LinkExec_mouseUp:));
}

@end
