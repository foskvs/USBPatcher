//
//  DslPatcher.h
//  USBPatcher
//
//  Created by foskvs on 07/11/21.
//

#ifndef DslPatcher_h
#define DslPatcher_h

#import <Foundation/Foundation.h>


void findCommentStatus(char, int*, int*);
void searchWord(const char*, int*, char, bool*, char);

void applyPatch(NSMutableString*, unsigned long*, const char*, int*, int*, int*, const unsigned long, bool, long);

bool isMethod(const char*, unsigned long);

void patchMethod(NSMutableString*, unsigned long*, const char*, int*, int*, int*, const unsigned long, bool, NSInteger);
void patchName(NSMutableString*, unsigned long*, const char*, int*, int*, int*, const unsigned long, bool, NSInteger);

bool is_separator(const char);
NSMutableString* cutPortName(NSString*);

#endif /* DslPatcher_h */
