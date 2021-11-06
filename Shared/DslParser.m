//
//  DslParser.m
//  USBPatcher
//
//  Created by foskvs on 04/11/21.
//



#import "DslParser.h"

void cParseText(NSString* source, NSMutableString* lengthNS, NSMutableString* lengthHexNS, NSMutableString* oemIdNS, NSMutableString* oemIdHexNS, NSMutableArray* portsList) {
    
    int commentBlockStatus = 0;
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
        if (commentBlockStatus == 4) {
            if (text[i] == '/') {
                commentBlockStatus = 0;
            }
            else {
                commentBlockStatus = 3;
            }
        }
        else {
            switch (text[i]) {
                case '/':
                    if (commentBlockStatus == 0) {
                        commentBlockStatus = 1;
                    }
                    else if (commentBlockStatus == 1) {
                        commentBlockStatus = 2;
                    }
                    break;
                case '\n':
                    if (commentBlockStatus == 2 || commentBlockStatus == 1) {
                        commentBlockStatus = 0;
                    }
                    break;
                case '*':
                    if (commentBlockStatus == 1) {
                        commentBlockStatus = 3;
                    }
                    else if (commentBlockStatus == 3) {
                        commentBlockStatus = 4;
                    }
                    break;
                default:
                    if (commentBlockStatus == 0) {
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
                            findLength(text[i], &counter, length, &foundLength, &lengthPos);
                        }
                        else if (foundOemId == false) {
                            findOemId(text[i], &counter, oemId, &foundOemId, &lengthPos);
                        }
                    }
                    break;
            }
        }
    }
    
    //printf("%i\n",foundLength);
    /*
    if (foundLength == true) {
        printf("Found Length: %s\n", length);
    }*/
    
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

void findLength (char c, int* counter, char* length, bool* found, int* pos) {
    const int size = 7;
    const char referenceString[size] = "Length";
    
    int count = *counter;
    bool f = *found;
    int p = *pos;
    
    if (c == ' ') {
        return;
    }
    //printf("%i\n",count);
    if (count == size-1) {
        if (c == '(') {
            count++;
        }
    }
    else if (count == size) {
        if (c == ')') {
            length[p] = '\0';
            f = true;
            count = 0;
            p = 0;
        }
        else {
            length[p] = c;
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

void findOemId (char c, int* counter, char* tableId, bool* found, int* pos) {
    const int size = 11;
    const char referenceString[size] = "OEMTableID";
    
    int count = *counter;
    bool f = *found;
    int p = *pos;
    
    if (c == ' ') {
        return;
    }
    //printf("%i\n",count);
    if (count == size-1) {
        if (c == '"') {
            count++;
        }
    }
    else if (count == size) {
        if (c == '"') {
            tableId[p] = '\0';
            f = true;
            count = 0;
            p = 0;
        }
        else {
            tableId[p] = c;
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

void patchPort(NSMutableString* text, NSString* portName, bool isEnabled, NSInteger connectorType) {
    
    //NSError *error = NULL;
    //NSString* testString = [[NSString alloc] initWithString:text];
    //NSString* pattern = @"Method *\\(_UPC, *0, *NotSerialized\\).*\\n( *)\\{ *\\n";
    
    
    //NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    //NSMutableString* mString = [[NSMutableString alloc] initWithString: text];
    
    const unsigned long textSize = text.length;
    char* cText = (char*)malloc((textSize) * sizeof(char));
    strcpy(cText, [text UTF8String]);
    
    const unsigned long nameSize = portName.length;
    char* cPortName = (char*)malloc((nameSize) * sizeof(char));
    strcpy(cPortName, [portName UTF8String]);
    int counter = 0;
    
    int commentBlockStatus = 0;
    bool foundPort = false;
    bool foundUPC = false;
    
    NSMutableString* previousUPC = [[NSMutableString alloc] init];
    
    for (unsigned long i = 0; i < textSize && foundPort == false; i++) {
        
        findCommentStatus(cText[i], &commentBlockStatus);
        
        if (commentBlockStatus == 0) {
            if (cText[i] == ' ' || cText[i] == '\n') {
            }
            else if (counter == nameSize) {
                if (cText[i] == ')') {
                    //printf("Found %s\n", cPortName);
                    //NSLog(@"%@", portName);
                    foundPort = true;
                    
                    counter = 0;
                    int bracketCount = 0;
                    for (; i < textSize && foundUPC == false && bracketCount >= 0; i++) {
                        findCommentStatus(cText[i], &commentBlockStatus);
                        if (commentBlockStatus == 0) {
                            switch (cText[i]) {
                                case '{':
                                    bracketCount++;
                                    break;
                                case '}':
                                    bracketCount--;
                                    break;
                                default:
                                    searchWord("(_UPC,", &counter, cText[i], &foundUPC);
                                    if (foundUPC == true) {
                                        // Here !!!!!
                                        //printf("Found _UPC for port %s\n", cPortName);
                                        
                                        bracketCount = 0;
                                        for (; i < textSize && bracketCount == 0; i++) {
                                            findCommentStatus(cText[i], &commentBlockStatus);
                                            if (commentBlockStatus == 0) {
                                                if (cText[i] == '{') {
                                                    bracketCount++;
                                                    
                                                    unsigned long beginOfMatch = i + 1;
                                                    unsigned long endOfMatch = i + 1;
                                                    int spaces = 0;
                                                    bool definedSpaces = false;
                                                    
                                                    for (i += 1; i < textSize && bracketCount > 0; i++) {
                                                        if (definedSpaces == false) {
                                                            if (cText[i] == '\n') {
                                                                spaces = 0;
                                                            }
                                                            if (cText[i] == ' ') {
                                                                spaces++;
                                                            }
                                                        }
                                                        findCommentStatus(cText[i], &commentBlockStatus);
                                                        char* ch = (char*)malloc((2) * sizeof(char));
                                                        ch[0] = cText[i];
                                                        ch[1] = '\0';
                                                        if (commentBlockStatus == 0) {
                                                            switch (cText[i]) {
                                                                case '{':
                                                                    bracketCount++;
                                                                    if (definedSpaces == false) {
                                                                        definedSpaces = true;
                                                                    }
                                                                    break;
                                                                case '}':
                                                                    bracketCount--;
                                                                    break;
                                                                default:
                                                                    break;
                                                            }
                                                        }
                                                        if (bracketCount > 0) {
                                                            [previousUPC appendString:[[NSString alloc] initWithCString:ch encoding:NSUTF8StringEncoding]];
                                                            endOfMatch = i;
                                                        }
                                                        free(ch);
                                                        //printf("%i\n", bracketCount);
                                                    }
                                                    bracketCount = -1;
                                                    //NSLog(@"%@", previousUPC);
                                                    //NSLog(@"Patching %@", portName);
                                                    //printf("From %lu to %lu\n", beginOfMatch, endOfMatch);
                                                    
                                                    NSMutableString* spacings = [[NSMutableString alloc] initWithString:@"\n"];
                                                    NSMutableString* lessSpacings = [[NSMutableString alloc] initWithString:@"\n"];
                                                    char* ch = (char*)malloc((2) * sizeof(char));
                                                    ch[0] = ' ';
                                                    ch[1] = '\0';
                                                    for (int j = 0; j < spaces; j++) {
                                                        [spacings appendString:[[NSString alloc] initWithCString:ch encoding:NSUTF8StringEncoding]];
                                                    }
                                                    for (int j = 0; j < spaces - 4 && j >= 0; j++) {
                                                        [lessSpacings appendString:[[NSString alloc] initWithCString:ch encoding:NSUTF8StringEncoding]];
                                                    }
                                                    free(ch);
                                                    
                                                    NSMutableString* replacementString = [[NSMutableString alloc] initWithString:@"\nReturn(Package(0x04)\n{\nSPACEISON,\nSPACETYPE,\nSPACEZero,\nSPACEZero\n})LESS_SPACE"];
                                                    
                                                    NSString* pattern1 = @"\\n";
                                                    NSString* pattern2 = @"LESS_SPACE";
                                                    NSString* pattern3 = @"SPACE";
                                                    NSString* pattern4 = @"ISON";
                                                    NSString* pattern5 = @"TYPE";
                                                    
                                                    NSError *error = NULL;
                                                    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern1 options:0 error:&error];
                                                    [regex replaceMatchesInString: replacementString options:0 range: NSMakeRange(0, replacementString.length) withTemplate: spacings];
                                                    
                                                    regex = [NSRegularExpression regularExpressionWithPattern: pattern2 options:0 error:&error];
                                                    [regex replaceMatchesInString: replacementString options:0 range: NSMakeRange(0, replacementString.length) withTemplate: lessSpacings];
                                                    
                                                    regex = [NSRegularExpression regularExpressionWithPattern: pattern3 options:0 error:&error];
                                                    [regex replaceMatchesInString: replacementString options:0 range: NSMakeRange(0, replacementString.length) withTemplate: @"    "];
                                                    
                                                    NSMutableString* enabledString = [[NSMutableString alloc] init];
                                                    if (isEnabled == true) {
                                                        [enabledString setString:@"One"];
                                                    }
                                                    else {
                                                        [enabledString setString:@"Zero"];
                                                    }
                                                    
                                                    regex = [NSRegularExpression regularExpressionWithPattern: pattern4 options:0 error:&error];
                                                    [regex replaceMatchesInString: replacementString options:0 range: NSMakeRange(0, replacementString.length) withTemplate: enabledString];
                                                    
                                                    NSMutableString* connectorTypeString = [[NSMutableString alloc] init];
                                                    if (connectorType == 0) {
                                                        [connectorTypeString setString:@"Zero"];
                                                    }
                                                    else if (connectorType == 1) {
                                                        [connectorTypeString setString:@"One"];
                                                    }
                                                    else {
                                                        [connectorTypeString setString:[NSString stringWithFormat:@"0x%02lX", (long)connectorType]];
                                                    }
                                                    
                                                    regex = [NSRegularExpression regularExpressionWithPattern: pattern5 options:0 error:&error];
                                                    [regex replaceMatchesInString: replacementString options:0 range: NSMakeRange(0, replacementString.length) withTemplate: connectorTypeString];
                                                    
                                                    [text replaceCharactersInRange:NSMakeRange(beginOfMatch, endOfMatch-beginOfMatch+1) withString:replacementString];
                                                    //NSLog(@"%@", mString);
                                                }
                                            }
                                        }
                                    }
                                    break;
                            }
                        }
                    }
                }
                else {
                    counter = 0;
                }
            }
            else if (cText[i] == cPortName[counter]) {
                counter++;
            }
            else {
                counter = 0;
            }
        }
        
        /*
        if (commentBlockStatus == 4) {
            if (cText[i] == '/') {
                commentBlockStatus = 0;
            }
            else {
                commentBlockStatus = 3;
            }
        }
        else {
            switch (cText[i]) {
                case '/':
                    if (commentBlockStatus == 0) {
                        commentBlockStatus = 1;
                    }
                    else if (commentBlockStatus == 1) {
                        commentBlockStatus = 2;
                    }
                    break;
                case '\n':
                    if (commentBlockStatus == 2 || commentBlockStatus == 1) {
                        commentBlockStatus = 0;
                    }
                    break;
                case '*':
                    if (commentBlockStatus == 1) {
                        commentBlockStatus = 3;
                    }
                    else if (commentBlockStatus == 3) {
                        commentBlockStatus = 4;
                    }
                    break;
                default:
                    if (commentBlockStatus == 0) {
                        if (cText[i] == ' ' || cText[i] == '\n') {
                        }
                        else if (counter == nameSize) {
                            if (cText[i] == ')') {
                                printf("Found %s\n", cPortName);
                                //NSLog(@"%@", portName);
                                foundPort = true;
                                int bracketCount = 0;
                                for (; i < textSize && foundUPC == false; i++) {
                                    if (cText[i] == '{') {
                                        bracketCount += 1;
                                    }
                                }
                            }
                        }
                        else if (cText[i] == cPortName[counter]) {
                            counter++;
                        }
                    }
                    break;
            }
        }*/
    }
    
    free(cText);
    free(cPortName);
    
    //[regex replaceMatchesInString: mString options:0 range: NSMakeRange(0, mString.length) withTemplate: @"Method (_UPC, 1, NotSerialized) // patched\n$1{\n"];
    //testString = String(mString);
    //NSLog(@"%@", mString);
}

void findCommentStatus (char c, int* stat) {
    int commentBlockStatus = *stat;
    
    if (commentBlockStatus == 4) {
        if (c == '/') {
            commentBlockStatus = 0;
        }
        else {
            commentBlockStatus = 3;
        }
    }
    else {
        switch (c) {
            case '/':
                if (commentBlockStatus == 0) {
                    commentBlockStatus = 1;
                }
                else if (commentBlockStatus == 1) {
                    commentBlockStatus = 2;
                }
                break;
            case '\n':
                if (commentBlockStatus == 2 || commentBlockStatus == 1) {
                    commentBlockStatus = 0;
                }
                break;
            case '*':
                if (commentBlockStatus == 1) {
                    commentBlockStatus = 3;
                }
                else if (commentBlockStatus == 3) {
                    commentBlockStatus = 4;
                }
                break;
            default:
                break;
        }
    }
    
    *stat = commentBlockStatus;
}

void searchWord(const char* word, int* count, char letter, bool* f) {
    unsigned long length = strlen(word);
    
    int c = *count;
    bool found = *f;
    
    if (letter == ' ') {
        return;
    }
    
    if (c == length) {
        found = true;
        c = 0;
    }
    else {
        if (letter == word[c]) {
            c++;
        }
        else {
            c = 0;
        }
    }
    
    *count = c;
    *f = found;
}
