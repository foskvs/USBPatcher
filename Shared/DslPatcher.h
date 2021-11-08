//
//  DslPatcher.h
//  USBPatcher
//
//  Created by Gabriele on 07/11/21.
//

#ifndef DslPatcher_h
#define DslPatcher_h

#import <Foundation/Foundation.h>

void patchPort(NSMutableString*, NSString*, bool, NSInteger, bool, bool*);

void findCommentStatus(char, int*);
void searchWord(const char*, int*, char, bool*);

void applyPatch(NSMutableString*, unsigned long*, char*, int*, int*, const unsigned long, bool, NSInteger);

#endif /* DslPatcher_h */
