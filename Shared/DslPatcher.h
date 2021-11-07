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

#endif /* DslPatcher_h */
