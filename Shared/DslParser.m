//
//  DslParser.m
//  USBPatcher
//
//  Created by foskvs on 04/11/21.
//


#import "DslParser.h"

void cParseText(NSMutableString* source, NSMutableString* lengthNS, NSMutableString* lengthHexNS, NSMutableString* oemIdNS, NSMutableString* oemIdHexNS, NSMutableArray* portsList, NSMutableArray* fullNamesList, bool patch, NSMutableArray* portNameToPatch, NSMutableArray* fullPortNameToPatch, NSMutableArray* isEnabled, NSMutableArray* connectorType) {
    
    int commentBlockStatus = 0;
    int stringStatus = 0;
    bool foundLength = false;
    bool foundOemId = false;
    int counter = 0;
    
    unsigned long textSize = [source length];
    
    char* text = (char*)malloc((textSize) * sizeof(char));
    strcpy(text, [source UTF8String]);
    
    char length[10];
    char oemId[10];
    int lengthPos = 0;
    
    
    bool foundHub = false;
    
    bool foundPorts = false;
    
    int upcCounter = 0;
    bool upcFound = false;
    int scopeCounter = 0;
    bool scopeFound = false;
    int deviceCounter = 0;
    bool deviceFound = false;
    int methodCounter = 0;
    bool methodFound = false;
    int packageCounter = 0;
    bool packageFound = false;
    int ifCounter = 0;
    bool ifFound = false;
    int elseCounter = 0;
    bool elseFound = false;
    int elseifCounter = 0;
    bool elseifFound = false;
    int whileCounter = 0;
    bool whileFound = false;
    int bufferCounter = 0;
    bool bufferFound = false;
    int fieldCounter = 0;
    bool fieldFound = false;
    int irqCounter = 0;
    bool irqFound = false;
    NSMutableArray* scopeArray = [[NSMutableArray alloc] init];
    
    bool patched = false;
    
    for (unsigned long i = 0; i < textSize && (foundLength && foundOemId && foundHub && foundPorts) == false && patched == false; i++) {
        
        findCommentStatus(text[i], &commentBlockStatus, &stringStatus);
        if (commentBlockStatus == 0 && stringStatus == 0) {
            findUPC(text, textSize, &i, &commentBlockStatus, &stringStatus, &upcCounter, &upcFound, &scopeCounter, &scopeFound, &deviceCounter, &deviceFound, &methodCounter, &methodFound, &packageCounter, &packageFound, &ifCounter, &ifFound, &elseCounter, &elseFound, &elseifCounter, &elseifFound, &whileCounter, &whileFound, &bufferCounter, &bufferFound, &fieldCounter, &fieldFound, &irqCounter, &irqFound, scopeArray, portsList, fullNamesList, patch, portNameToPatch, fullPortNameToPatch, isEnabled, connectorType, source, &patched);
            if (text[i] == '}') {
                //NSLog(@"Before: %@", scopeArray);
                [scopeArray removeLastObject];
                //NSLog(@"After: %@", scopeArray);
            }
        }
        else if (commentBlockStatus == 3) {
            if (patch == false) {
                if (foundLength == false) {
                    findOemIdOrLength(text[i], &counter, length, &foundLength, &lengthPos, "Length", strlen("Length"), '(', ')');
                }
                else if (foundOemId == false) {
                    findOemIdOrLength(text[i], &counter, oemId, &foundOemId, &lengthPos, "OEMTableID", strlen("OEMTableID"), '"', '"');
                }
            }
        }
    }
    
    if (foundLength == false) {
        length[0] = '\0';
    }
    else {
        [lengthNS setString:[[NSString alloc] initWithCString:length encoding:NSUTF8StringEncoding]];
        [lengthHexNS setString:[NSMutableString stringWithFormat:@"%X", atoi(length)]];
    }
    
    if (foundOemId == false) {
        oemId[0] = '\0';
    }
    else {
        [oemIdNS setString:[[NSString alloc] initWithCString:oemId encoding:NSUTF8StringEncoding]];
        
        NSMutableString *hexString = [NSMutableString string];
        
        for(NSUInteger i = 0; i < strlen(oemId); i++ )
        {
            [hexString appendFormat:@"%02x", oemId[i]];
        }
        
        [oemIdHexNS setString:[[NSString alloc] initWithString:hexString]];
        
    }
    
    free(text);
}

void findOemIdOrLength (char c, int* counter, char* oemIdOrlength, bool* found, int* pos, const char* referenceString, const unsigned int size, const char beginOfMatch, const char endOfMatch) {
    //const unsigned long size = strlen(referenceString);
    
    int count = *counter;
    bool f = *found;
    int p = *pos;
    
    if (c == ' ') {
        return;
    }
    //printf("%i\n",count);
    if (count == size-1) {
        if (c == beginOfMatch) {
            count++;
        }
    }
    else if (count == size) {
        if (c == endOfMatch) {
            oemIdOrlength[p] = '\0';
            f = true;
            count = 0;
            p = 0;
        }
        else {
            oemIdOrlength[p] = c;
            p++;
        }
    }
    else if (c == referenceString[count]) {
        count++;
    }
    else {
        count = 0;
    }
    *counter = count;
    *found = f;
    *pos = p;
}

void findUPC (const char* text, const unsigned long textSize, unsigned long* it, int* cBS, int* sS, int* count, bool* found, int* scopeCounter, bool* foundScope, int* deviceCounter, bool* foundDevice, int* methodCounter, bool* foundMethod, int* packageCounter, bool* foundPackage, int* ifCounter, bool* foundIf, int* elseCounter, bool* foundElse, int* elseifCounter, bool* foundElseif, int* whileCounter, bool* foundWhile, int* bufferCounter, bool* foundBuffer, int* fieldCounter, bool* foundField, int* irqCounter, bool* foundIrq, NSMutableArray* scopeArray, NSMutableArray* portsList, NSMutableArray* fullNamesList, bool patch, NSMutableArray* portNameToPatch, NSMutableArray* fullPortNameToPatch, NSMutableArray* isEnabled, NSMutableArray* connectorType, NSMutableString* source, bool* patched) {
    unsigned long i = *it;
    int commentBlockStatus = *cBS;
    int stringStatus = *sS;
    int counter = *count;
    
    searchWord("_UPC", &counter, text[i], found, text[i-1]);
    searchWord("Scope", scopeCounter, text[i], foundScope, text[i-1]);
    searchWord("Device", deviceCounter, text[i], foundDevice, text[i-1]);
    searchWord("Method", methodCounter, text[i], foundMethod, text[i-1]);
    searchWord("Package", packageCounter, text[i], foundPackage, text[i-1]);
    searchWord("If", ifCounter, text[i], foundIf, text[i-1]);
    searchWord("Else", elseCounter, text[i], foundElse, text[i-1]);
    searchWord("ElseIf", elseifCounter, text[i], foundElseif, text[i-1]);
    searchWord("While", whileCounter, text[i], foundWhile, text[i-1]);
    searchWord("Buffer", bufferCounter, text[i], foundBuffer, text[i-1]);
    searchWord("Field", fieldCounter, text[i], foundField, text[i-1]);
    searchWord("IRQ", irqCounter, text[i], foundIrq, text[i-1]);
    
    if (*found == true) {
        counter = 0;
        *found = false;
        
        NSMutableString* portName = [[NSMutableString alloc] init];
        NSMutableString* fullName = [[NSMutableString alloc] init];
        int k = 0;
        for (int j = 0; j < [scopeArray count]; j++) {
            if ([[[[[scopeArray objectAtIndex:j] objectAtIndex:0] objectAtIndex:0] objectAtIndex:1] isEqualToString:@"Scope"]) {
                //NSLog(@"%@", [[[[scopeArray objectAtIndex:j] objectAtIndex:0] objectAtIndex:0] objectAtIndex:0]);
                [portName setString:cutPortName([[[[scopeArray objectAtIndex:j] objectAtIndex:0] objectAtIndex:0] objectAtIndex:0])];
                if (k > 0) {
                    [fullName appendString:@"."];
                }
                [fullName appendString:[[[[scopeArray objectAtIndex:j] objectAtIndex:0] objectAtIndex:0] objectAtIndex:0]];
                //NSLog(@"%@", portName);
                k++;
            }
            //NSLog(@"%@", [scopeArray objectAtIndex:j]);
        }
        
        if (patch == false) {
            [portsList addObject:portName];
            [fullNamesList addObject:fullName];
        }
        else {
            //printf("F\n");
            //NSLog(@"%@ %@", portName, portNameToPatch);
            for (int h = 0; h < [portNameToPatch count]; h++) {
                if ([portName isEqualToString:[portNameToPatch objectAtIndex:h]]) {
                    if ([fullName isEqualToString:[fullPortNameToPatch objectAtIndex:h]]) {
                        int bracketCount = 0;
                        applyPatch(source, &i, text, &commentBlockStatus, &stringStatus, &bracketCount, textSize, [isEnabled objectAtIndex:h], [[connectorType objectAtIndex:h] integerValue]); // ?????
                        [portNameToPatch removeObjectAtIndex:h];
                        [fullPortNameToPatch removeObjectAtIndex:h];
                        [isEnabled removeObjectAtIndex:h];
                        [connectorType removeObjectAtIndex:h];
                        if ([portNameToPatch count] == 0) {
                            *patched = true;
                        }
                    }
                }
            }
        }
        //NSLog(@"%@", portName);
        //NSLog(@"%@", fullName);
        //NSLog(@"%@", scopeArray);
    }
    
    if (*foundScope == true || *foundDevice == true || *foundMethod == true || *foundPackage == true || *foundIf == true || *foundElse == true || *foundElseif == true || *foundWhile == true || *foundBuffer == true || *foundField == true || *foundIrq == true) {
        
        
        if (*foundScope == true) {
            NSString* scopeName = [[NSString alloc] initWithString:grabScopeName(text, textSize, it)];
            //[scopeArray addObject:[[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:@[grabScopeName(text, textSize, it), @"Scope"], nil], nil]];
            [scopeArray addObject:[[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:@[scopeName, @"Scope"], nil], nil]];
            //NSLog(@"Found scope: %@", scopeName);
            //NSLog(@"%@", scopeArray);
        }
        else if (*foundDevice == true) {
            [scopeArray addObject:[[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:@[grabScopeName(text, textSize, it), @"Scope"], nil], nil]];
        }
        else {
            [scopeArray addObject:[[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:@[grabScopeName(text, textSize, it), @"Else"], nil], nil]];
        }
        
        *foundScope = false;
        *foundDevice = false;
        *foundMethod = false;
        *foundPackage = false;
        *foundIf = false;
        *foundElse = false;
        *foundWhile = false;
        *foundElseif = false;
        *foundBuffer = false;
        *foundField = false;
        *foundIrq = false;
        
        *scopeCounter = 0;
        *deviceCounter = 0;
        *methodCounter = 0;
        *packageCounter = 0;
        *ifCounter = 0;
        *elseCounter = 0;
        *elseifCounter = 0;
        *whileCounter = 0;
        *bufferCounter = 0;
        *fieldCounter = 0;
        *irqCounter = 0;
        
        //printf("%lu\n", i);
        
    }
    
    *it = i;
    *cBS = commentBlockStatus;
    *sS = stringStatus;
    *count = counter;
}

NSString* grabScopeName (const char* text, unsigned long textSize, unsigned long* it) {
    unsigned long i = *it;
    NSMutableString* str = [[NSMutableString alloc] init];
    for (; i < textSize && text[i] != ')'; i++) {
        if (!is_separator(text[i])) {
            //printf("%c", text[i]);
            char ch[2];
            ch[0] = text[i];
            ch[1] = '\0';
            [str appendString:[[NSString alloc] initWithCString:ch encoding:NSUTF8StringEncoding]];
        }
    }
    //printf("\n");
    
    //NSLog(@"%@", str);
    
    *it = i;
    return str;
}
