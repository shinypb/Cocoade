//
//  NSApplication+shouldStartAtLogin.m
//
//  Copyright 2012 ShinyPlasticBag. All rights reserved.
//

#import "NSApplication+startAtLogin.h"

@implementation NSApplication (NSApplication_shouldStartAtLogin)

#pragma mark - Public methods
- (BOOL)shouldStartAtLogin {
  // Courtesy of https://github.com/carpeaqua/Shared-File-List-Example/blob/master/Controller.m
  // This will retrieve the path for the application
  // For example, /Applications/test.app
  NSString * appPath = [[NSBundle mainBundle] bundlePath];
  
  LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
  BOOL value = NO;
  if ([self loginItemExistsWithLoginItemReference:loginItems ForPath:appPath]) {
    value = YES;
  }
  
  CFRelease(loginItems);
  
  return value;
}

- (void)setShouldStartAtLogin:(BOOL)value {
  NSString * appPath = [[NSBundle mainBundle] bundlePath];
  
  // Create a reference to the shared file list.
  LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
  if (!loginItems) {
    NSLog(@"Failed to create a reference to the shared file list");
    return;
  }
  if (value) {
    [self enableLoginItemWithLoginItemsReference:loginItems ForPath:appPath];
  } else {
    [self disableLoginItemWithLoginItemsReference:loginItems ForPath:appPath];
  }

  CFRelease(loginItems);
}

#pragma mark - Private methods
- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath {
  // We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
  CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
  LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
  if (item) {
    CFRelease(item);
  }
}

- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath {
  UInt32 seedValue;
  CFURLRef thePath;
  // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
  // and pop it in an array so we can iterate through it to find our item.
  CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
  for (id item in (NSArray *)loginItemsArray) {
    LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
    if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
      if ([[(NSURL *)thePath path] hasPrefix:appPath]) {
        LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
      }
      // Docs for LSSharedFileListItemResolve say we're responsible
      // for releasing the CFURLRef that is returned
      CFRelease(thePath);
    }
  }
  CFRelease(loginItemsArray);
}

- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(NSString *)appPath {
  BOOL found = NO;
  UInt32 seedValue;
  CFURLRef thePath;
  
  // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
  // and pop it in an array so we can iterate through it to find our item.
  CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
  for (id item in (NSArray *)loginItemsArray) {
    LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
    if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
      if ([[(NSURL *)thePath path] hasPrefix:appPath]) {
        found = YES;
        break;
      }
    }
    // Docs for LSSharedFileListItemResolve say we're responsible
    // for releasing the CFURLRef that is returned
    CFRelease(thePath);
  }
  CFRelease(loginItemsArray);
  
  return found;
}

@end
