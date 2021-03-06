//
//  DslPatcher.m
//  USBPatcher
//
//  Created by foskvs on 07/11/21.
//

#import "DslPatcher.h"


void findCommentStatus (char c, int* commStat, int* strStat) {
    int commentBlockStatus = *commStat;
    int stringStatus = *strStat;
    
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
                if (stringStatus == 0) {
                    if (commentBlockStatus == 0) {
                        commentBlockStatus = 1;
                    }
                    else if (commentBlockStatus == 1) {
                        commentBlockStatus = 2;
                    }
                }
                break;
            case '\n':
                if (stringStatus == 0) {
                    if (commentBlockStatus == 2 || commentBlockStatus == 1) {
                        commentBlockStatus = 0;
                    }
                }
                break;
            case '*':
                if (stringStatus == 0) {
                    if (commentBlockStatus == 1) {
                        commentBlockStatus = 3;
                    }
                    else if (commentBlockStatus == 3) {
                        commentBlockStatus = 4;
                    }
                }
                break;
            case '"':
                if (commentBlockStatus == 0) {
                    stringStatus = (stringStatus + 1)%2;
                }
                break;
            default:
                break;
        }
    }
    
    *commStat = commentBlockStatus;
    *strStat = stringStatus;
}

void searchWord(const char* word, int* count, char letter, bool* f, char previousLetter) {
    unsigned long length = strlen(word);
    
    int c = *count;
    bool found = *f;
    
    if (letter == ' ') {
        return;
    }
    
    if (c == length) {
        if (is_separator(letter)) {
            found = true;
        }
        c = 0;
    }
    else {
        if (c == 0) {
            if (!is_separator(previousLetter)) {
                return;
            }
        }
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

void applyPatch (NSMutableString* text, unsigned long* it, const char* cText, int* cBS, int* sS, int* br, const unsigned long textSize, bool isEnabled, long connectorType) {
    //int bracketCount = *br;
    unsigned long i = *it;
    int commentBlockStatus = *cBS;
    int stringStatus = *sS;
    
    bool hasMethod = isMethod(cText, i);
    
    for (; i < textSize && *br == 0; i++) {
        findCommentStatus(cText[i], &commentBlockStatus, &stringStatus);
        if (commentBlockStatus == 0 && stringStatus == 0) {
            if (hasMethod == true) {
                patchMethod(text, &i, cText, &commentBlockStatus, &stringStatus, br, textSize, isEnabled, connectorType);
            }
            else {
                patchName(text, &i, cText, &commentBlockStatus, &stringStatus, br, textSize, isEnabled, connectorType);
            }
        }
    }
    
    //*br = bracketCount;
    *it = i;
    *cBS = commentBlockStatus;
    *sS = stringStatus;
}

bool isMethod (const char* cText, unsigned long i) {
    
    const char comparison[] = "(_UPC,";
    int upcSize = (int)strlen(comparison) - 1;
    
    for (i--; i >=0 ; i--) {
        if (cText[i] != ' ') {
            if (upcSize >= 0) {
                if (cText[i] != comparison[upcSize]) {
                    //printf("Error: %c %c\n", cText[i], comparison[upcSize]);
                    break;
                }
                upcSize--;
            }
            else {
                if (cText[i] == 'd') {
                    //printf("Method\n");
                    return true;
                }
                else if (cText[i] == 'e') {
                    //printf("Name\n");
                    return false;
                }
            }
            //printf("%c\n", cText[i]);
            //break;
        }
    }
    return true;
}

void patchMethod(NSMutableString* text, unsigned long* it, const char* cText, int* cBS, int*sS, int* br, const unsigned long textSize, bool isEnabled, NSInteger connectorType) {
    unsigned long i = *it;
    int bracketCount = *br;
    int commentBlockStatus = *cBS;
    int stringStatus = *sS;
    
    NSMutableString* previousUPC = [[NSMutableString alloc] init];
    
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
            findCommentStatus(cText[i], &commentBlockStatus, &stringStatus);
            //char* ch = (char*)malloc((2) * sizeof(char));
            char ch[2];
            ch[0] = cText[i];
            ch[1] = '\0';
            if (commentBlockStatus == 0 && stringStatus == 0) {
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
    
    *it = i;
    *br = bracketCount;
    *cBS = commentBlockStatus;
    *sS = stringStatus;
}

void patchName(NSMutableString* text, unsigned long* it, const char* cText, int* cBS, int* sS, int* br, const unsigned long textSize, bool isEnabled, NSInteger connectorType) {
    unsigned long i = *it;
    int bracketCount = *br;
    int commentBlockStatus = *cBS;
    int stringStatus = *sS;
    
    NSMutableString* previousUPC = [[NSMutableString alloc] init];
    //NSMutableString* mString = [[NSMutableString alloc] initWithString: text];
    
    unsigned long beginOfMatch = i;
    unsigned long endOfMatch = i;
    
    if (cText[i] == 'P') {
        bracketCount++;
        
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
            findCommentStatus(cText[i], &commentBlockStatus, &stringStatus);
            //char* ch = (char*)malloc((2) * sizeof(char));
            char ch[2];
            ch[0] = cText[i];
            ch[1] = '\0';
            if (commentBlockStatus == 0 && stringStatus == 0) {
                switch (cText[i]) {
                    case '(':
                        bracketCount++;
                        break;
                    case ')':
                        bracketCount--;
                        break;
                    case '{':
                        if (definedSpaces == false) {
                            definedSpaces = true;
                        }
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
        
        NSMutableString* replacementString = [[NSMutableString alloc] initWithString:@"Package(0x04)\n{\nSPACEISON,\nSPACETYPE,\nSPACEZero,\nSPACEZero\n}"];
        
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
    
    *it = i;
    *br = bracketCount;
    *cBS = commentBlockStatus;
    *sS = stringStatus;
}

bool is_separator (const char letter) {
    bool result = false;
    switch (letter) {
        case '{':
            result = true;
        case '}':
            result = true;
        case '(':
            result = true;
        case ')':
            result = true;
        case '[':
            result = true;
        case ']':
            result = true;
        case ',':
            result = true;
        case '\n':
            result = true;
        case '\t':
            result = true;
        case ' ':
            result = true;
        case '>':
            result = true;
        case '<':
            result = true;
        case '=':
            result = true;
        case '!':
            result = true;
        default:
            break;
    }
    return result;
}

NSMutableString* cutPortName (NSString* name) {
    
    
    NSMutableString* mString = [[NSMutableString alloc] initWithString: name];
    NSString* pattern = @".*\\.";
    NSError *error = NULL;
    NSMutableString* connectorTypeString = [[NSMutableString alloc] initWithString:@""];
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    [regex replaceMatchesInString: mString options:0 range: NSMakeRange(0, mString.length) withTemplate: connectorTypeString];
    
    return mString;
}
