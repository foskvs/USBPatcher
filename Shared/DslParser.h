//
//  DslParser.h
//  USBPatcher
//
//  Created by foskvs on 04/11/21.
//

#ifndef DslParser_h
#define DslParser_h

#import <Foundation/Foundation.h>

void cParseText(NSString*, NSMutableString*, NSMutableString*, NSMutableString*, NSMutableString*, NSMutableArray*);

void findLength(char, int*, char*, bool*, int*);
void findOemId(char, int*, char*, bool*, int*);

void findHubDefinition(char, int*, char*, bool*, int*);
bool findPorts(char, int*, char*, bool*, int*, char*);

void patchPort(NSMutableString*, NSString*, bool, NSInteger);

void findCommentStatus(char, int*);
void searchWord(const char*, int*, char, bool*);

#endif /* DslParser_h */
