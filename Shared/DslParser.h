//
//  DslParser.h
//  USBPatcher
//
//  Created by foskvs on 04/11/21.
//

#ifndef DslParser_h
#define DslParser_h

#import <Foundation/Foundation.h>
#import "DslPatcher.h"

void cParseText(NSMutableString*, NSMutableString*, NSMutableString*, NSMutableString*, NSMutableString*, NSMutableArray*, NSMutableArray*, bool, NSMutableArray*, NSMutableArray*, NSMutableArray*, NSMutableArray*);

void findOemIdOrLength(char, int*, char*, bool*, int*, const char*, const unsigned int, const char, const char);

void findUPC(const char*, const unsigned long, unsigned long*, int*, int*, int*, bool*, int*, bool*, int*, bool*, int*, bool*, int*, bool*, int*, bool*, int*, bool*, int*, bool*, int*, bool*, int*, bool*, int*, bool*, int*, bool*, NSMutableArray*, NSMutableArray*, NSMutableArray*, bool, NSMutableArray*, NSMutableArray*, NSMutableArray*, NSMutableArray*, NSMutableString*, bool*);

NSString* grabScopeName(const char*, const unsigned long, unsigned long*);

#endif /* DslParser_h */
