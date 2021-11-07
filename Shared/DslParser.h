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

void cParseText(NSString*, NSMutableString*, NSMutableString*, NSMutableString*, NSMutableString*, NSMutableArray*);

void findOemIdOrLength(char, int*, char*, bool*, int*, const char*, const char, const char);

void findHubDefinition(char, int*, char*, bool*, int*);
bool findPorts(char, int*, char*, bool*, int*, char*);


#endif /* DslParser_h */
