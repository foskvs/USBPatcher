//
//  DslPatcher.m
//  USBPatcher
//
//  Created by Gabriele on 07/11/21.
//

#import "DslPatcher.h"

void patchPort(NSMutableString* text, NSString* portName, bool isEnabled, NSInteger connectorType, bool patching, bool* foundPort) {
    
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
    //bool foundPort = false;
    bool foundUPC = false;
    
    //NSMutableString* previousUPC = [[NSMutableString alloc] init];
    
    for (unsigned long i = 0; i < textSize && foundUPC == false; i++) {
        
        findCommentStatus(cText[i], &commentBlockStatus);
        
        if (commentBlockStatus == 0) {
            if (cText[i] == ' ' || cText[i] == '\n') {
            }
            else if (counter == nameSize) {
                if (cText[i] == ')') {
                    //printf("Found %s\n", cPortName);
                    //NSLog(@"%@", portName);
                    //foundPort = true;
                    
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
                                        *foundPort = true;
                                        //printf("Found _UPC for port %s\n", cPortName);
                                        if (patching ==  false) {
                                            return;
                                        }
                                        bracketCount = 0;
                                        applyPatch(text, &i, cText, &commentBlockStatus, &bracketCount, textSize, isEnabled, connectorType);
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
    }
    
    free(cText);
    free(cPortName);
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

void applyPatch (NSMutableString* text, unsigned long* it, char* cText, int* cBS, int* br, const unsigned long textSize, bool isEnabled, NSInteger connectorType) {
    int bracketCount = *br;
    unsigned long i = *it;
    int commentBlockStatus = *cBS;
    
    NSMutableString* previousUPC = [[NSMutableString alloc] init];
    
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
                    //char* ch = (char*)malloc((2) * sizeof(char));
                    char ch[2];
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
                    //free(ch);
                    //printf("%i\n", bracketCount);
                }
                bracketCount = -1;
                //NSLog(@"%@", previousUPC);
                //NSLog(@"Patching %@", portName);
                //printf("From %lu to %lu\n", beginOfMatch, endOfMatch);
                
                NSMutableString* spacings = [[NSMutableString alloc] initWithString:@"\n"];
                NSMutableString* lessSpacings = [[NSMutableString alloc] initWithString:@"\n"];
                //char* ch = (char*)malloc((2) * sizeof(char));
                char ch[2];
                ch[0] = ' ';
                ch[1] = '\0';
                for (int j = 0; j < spaces; j++) {
                    [spacings appendString:[[NSString alloc] initWithCString:ch encoding:NSUTF8StringEncoding]];
                }
                for (int j = 0; j < spaces - 4 && j >= 0; j++) {
                    [lessSpacings appendString:[[NSString alloc] initWithCString:ch encoding:NSUTF8StringEncoding]];
                }
                //free(ch);
                
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
    
    *br = bracketCount;
    *it = i;
    *cBS = commentBlockStatus;
}
