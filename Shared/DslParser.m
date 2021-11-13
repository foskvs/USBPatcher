//
//  DslParser.m
//  USBPatcher
//
//  Created by foskvs on 04/11/21.
//


#import "DslParser.h"

void cParseText(NSString* source, NSMutableString* lengthNS, NSMutableString* lengthHexNS, NSMutableString* oemIdNS, NSMutableString* oemIdHexNS, NSMutableArray* portsList) {
    
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
    char hubName[30];
    int hubPos = 0;
    
    bool foundPorts = false;
    char portsName[10];
    int portsPos = 0;
    
    NSMutableArray* portsDefined = [[NSMutableArray alloc] init];
    
    for (unsigned long i = 0; i < textSize && (foundLength && foundOemId && foundHub && foundPorts) == false; i++) {
        
        findCommentStatus(text[i], &commentBlockStatus, &stringStatus);
        if (commentBlockStatus == 0 && stringStatus == 0) {
            if (foundHub == false) {
                findHubDefinition(text[i], &counter, hubName, &foundHub, &hubPos);
            }
            else {
                if (foundPorts == false) {
                    if (findPorts(text[i], &counter, portsName, &foundPorts, &portsPos, hubName)) {
                        [portsDefined addObject:[[NSString alloc] initWithCString:portsName encoding:NSUTF8StringEncoding]];
                        //printf("%s\n", portsName);
                    }
                }
            }
            //print(l)
        }
        else if (commentBlockStatus == 3) {
            if (foundLength == false) {
                findOemIdOrLength(text[i], &counter, length, &foundLength, &lengthPos, "Length", strlen("Length"), '(', ')');
            }
            else if (foundOemId == false) {
                findOemIdOrLength(text[i], &counter, oemId, &foundOemId, &lengthPos, "OEMTableID", strlen("OEMTableID"), '"', '"');
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
            [hexString appendFormat:@"%02x", oemId[i]]; /*EDITED PER COMMENT BELOW*/
        }
        
        [oemIdHexNS setString:[[NSString alloc] initWithString:hexString]];
        
    }
    
    
    if (foundHub == false) {
        hubName[0] = '\0';
    }
    else {
        //NSLog(@"%@", portsDefined);
        //portsList = [[NSMutableArray alloc] init];
        [portsList addObjectsFromArray:portsDefined];
        //printf("HUB Name: %s\n", hubName);
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

void findHubDefinition (char c, int* counter, char* hubName, bool* found, int* pos) {
    const int size = 9;
    const char referenceString[size] = "External";
    
    const char hub[5] = "RHUB";
    
    int count = *counter;
    bool f = *found;
    int p = *pos;
    
    if (c == ' ') {
        return;
    }
    if (count == size-1) {
        if (c == '(') {
            count++;
        }
    }
    else if (count == size) {
        if (c == hub[0]) {
            count++;
        }
        else if (c == ',') {
            count = 0;
            p = 0;
        }
        else {
            hubName[p] = c;
            p++;
        }
    }
    else if (count == size+1) {
        if (c == hub[1]) {
            count++;
        }
        else {
            count = 0;
            p = 0;
        }
    }
    else if (count == size+2) {
        if (c == hub[2]) {
            count++;
        }
        else {
            count = 0;
            p = 0;
        }
    }
    else if (count == size+3) {
        if (c == hub[3]) {
            count++;
        }
        else {
            count = 0;
            p = 0;
        }
    }
    else if (count == size+4) {
        if (c == ',') {
            hubName[p] = '\0';
            f = true;
            
            const unsigned long hLen = strlen(hub);
            for (int i = 0; i < hLen; i++) {
                hubName[p + i] = hub[i];
            }
            hubName[p + hLen] = '\0';
            
            count = 0;
            p = 0;
        }
    }
    else if (c == referenceString[count]) {
        //printf("%c", c);
        count++;
    }
    else {
        count = 0;
    }
    
    *counter = count;
    *found = f;
    *pos = p;
}

bool findPorts (char c, int* counter, char* portName, bool* found, int* pos, char* hubName) {
    bool result = false;
    
    int size = 9;
    const char ref1[] = "External(";
    char referenceString[size + strlen(hubName)];
    
    for (int i = 0; i < size; i++) {
        referenceString[i] = ref1[i];
    }
    for (int i = 0; i < strlen(hubName); i++) {
        referenceString[size + i] = hubName[i];
    }
    referenceString[size + strlen(hubName)] = '\0';
    
    size += strlen(hubName);
    
    int count = *counter;
    bool f = *found;
    int p = *pos;
    
    if (c == ' ') {
        return result;
    }
    if (count == 0 && c != 'E') {
        f = true;
        return result;
    }
    if (count == size-1) {
        if (c == '.') {
            count++;
        }
    }
    else if (count == size) {
        if (c == ',') {
            portName[p] = '\0';
            result = true;
            count = 0;
            p = 0;
        }
        else {
            portName[p] = c;
            p++;
        }
    }
    else if (c == referenceString[count]) {
        //printf("%c", c);
        count++;
    }
    else {
        count = 0;
    }
    
    *counter = count;
    *found = f;
    *pos = p;
    
    return result;
}


