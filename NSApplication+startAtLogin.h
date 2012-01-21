//
//  NSApplication+shouldStartAtLogin.h
//
//  This category on NSApplication makes it easy to have your application
//  start at login.
//
//  Simply call: [[NSApplication sharedApplication] shouldStartAtLogin:YES]
//
//  Of course, don't be a doofus — make sure the user actually asks you
//  to start at login before you set the preference for them.
//
//  Category by Mark Christian. Based on sample code by Justin Williams (see
//  https://github.com/carpeaqua/Shared-File-List-Example/blob/master/Controller.m)
//

#import <Foundation/Foundation.h>

@interface NSApplication (NSApplication_shouldStartAtLogin)
#pragma mark - Public methods
- (BOOL)shouldStartAtLogin;
- (void)setShouldStartAtLogin:(BOOL)value;

# pragma mark - Private methods
- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath;
- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath;
- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(NSString *)appPath;
@end
