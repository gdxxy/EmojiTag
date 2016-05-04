//
//  NSString+QISEmoji.m
//  YYK
//
//  Created by xiexianyu on 4/14/16.
//  Copyright © 2016 xiexianyu. All rights reserved.
//

#import "NSString+QISEmoji.h"

@implementation NSString (QISEmoji)

- (NSString*)escapeUnicodeEmoji
{
    if (self.length > 0 && [self isContainEmoji]) {
        return [self tagEmoji];
    }
    else {
        return self;
    }
}

- (NSString*)tagEmoji
{
    __block NSMutableString *tagText = [[NSMutableString alloc] init];
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              // escape emoji
                              //NSString *escapedEmoji = [NSString stringWithCString:[substring cStringUsingEncoding:NSNonLossyASCIIStringEncoding] encoding:NSUTF8StringEncoding];
                              //NSLog(@"escape utf8 %@\n", escapedEmoji); // \ud83d\ude00
                              
                              NSInteger subLength = substring.length;
                              BOOL isEmoji = NO;
                              NSString *beginTag = @"[emoji]";
                              NSString *endTag = @"[/emoji]";
                              
                              const unichar hs = [substring characterAtIndex:0];
                              
                              if (0xd800 <= hs && hs <= 0xdbff) { //leading, high
                                  if (subLength >= 2) {
                                      // const
                                      const UTF32Char SURROGATE_OFFSET = 0x10000 - (0xD800 << 10) - 0xDC00;
                                      
                                      const unichar ls = [substring characterAtIndex:1];
                                      // code point
                                      //const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                      UTF32Char uc = (hs << 10) + ls + SURROGATE_OFFSET;
                                      if (0x1d000 <= uc && uc <= 0x1f77f) {
                                          isEmoji = YES;
                                      }
                                      else if(0x1F910 <= uc && uc <= 0x1F918) {
                                          //Supplemental Symbols And Pictographs — Emoticon faces
                                          isEmoji = YES;
                                      }
                                      else if(0x1F919 <= uc && uc <= 0x1F9FF) {
                                          //Emoji 9.0 Candidates
                                          isEmoji = YES;
                                      }
                                      
                                      if (isEmoji) {
                                          NSMutableString *subTagText = [[NSMutableString alloc] init];
                                          
                                          [subTagText appendString:beginTag]; //begin tag
                                          for (NSInteger index = 0; index < subLength; ++index) {
                                              unichar unicode = [substring characterAtIndex:index];
                                              
                                              if (0xd800 <= unicode && unicode <= 0xdbff) {
                                                  if (index+1 < subLength) { // next code point
                                                      unichar nextUnicode = [substring characterAtIndex:index+1];
                                                      
                                                      UTF32Char codePoint = (unicode << 10) + nextUnicode + SURROGATE_OFFSET; //code point
                                                      [subTagText appendFormat:@"%x#", codePoint]; //split #
                                                      ++index; //skip next
                                                  }
                                                  else {
                                                      [subTagText appendFormat:@"%04x#", unicode];
                                                  }
                                              }
                                              else {
                                                  [subTagText appendFormat:@"%04x#", unicode];
                                              }
                                          } //for
                                          // trim last split '#'
                                          NSString *partTagText = [subTagText substringToIndex:[subTagText length]-1];
                                          partTagText = [partTagText stringByAppendingString:endTag]; //end tag
                                          
                                          [tagText appendString:partTagText]; //add tags and split
                                      }
                                      else { //not emoji
                                          [tagText appendString:substring];
                                      }
                                  } //if
                                  else { // non emoji
                                      [tagText appendString:substring];
                                  }
                              }
                              else {
                                  if (0x2100 <= hs && hs <= 0x27ff) {
                                      // 2100 to 27ff
                                      isEmoji = YES;
                                  }
                                  else if (0x203C == hs || 0x2049 == hs) {
                                      // General Punctuation — Double punctuation for vertical text
                                      //  ‼️  or ⁉️
                                      isEmoji = YES;
                                  }
                                  else if(0x00A9 == hs || 0x00AE == hs) {
                                      // Latin 1 Supplement — Latin-1 punctuation and symbols
                                      //  ©️ or ®️
                                      isEmoji = YES;
                                  }
                                  else if(0x2934 == hs || 0x2935 == hs) {
                                      //Supplemental Arrows B — Miscellaneous curved arrows
                                      // ⤴️ or  ⤵️
                                      isEmoji = YES;
                                  }
                                  else if(0x2B05 <= hs && hs <= 0x2B07) {
                                      // Miscellaneous Symbols And Arrows — White and black arrows
                                      isEmoji = YES;
                                  }
                                  else if (0x2B1B == hs || 0x2B1C == hs) {
                                      // Miscellaneous Symbols And Arrows — Squares
                                      isEmoji = YES;
                                  }
                                  else if (0x2B50 == hs) {
                                      // Miscellaneous Symbols And Arrows — Stars
                                      isEmoji = YES;
                                  }
                                  else if (0x2B55 == hs) {
                                      // Miscellaneous Symbols And Arrows — Traffic sign from ARIB STD B24
                                      isEmoji = YES;
                                  }
                                  else if (0x3030 == hs) {
                                      // CJK Symbols And Punctuation — CJK symbols
                                      isEmoji = YES;
                                  }
                                  else if (0x303D == hs) {
                                      // CJK Symbols And Punctuation — Other CJK punctuation
                                      isEmoji = YES;
                                  }
                                  else if (0x3297 == hs || 0x3299 == hs) {
                                      // Enclosed CJK Letters And Months — Circled ideographs
                                      isEmoji = YES;
                                  }
                                  else if (0x0023 == hs || 0x002A == hs) {
                                      // Basic Latin — ASCII punctuation and symbols
                                      isEmoji = YES;
                                  }
                                  else if(substring.length == 3) {
                                      //digit 0-9
                                      const unichar next = [substring characterAtIndex:1];
                                      if (next == 0xfe0f && hs >= 0x0030 && hs<= 0x0039) {
                                          isEmoji = YES;
                                      }
                                  }
                                  
                                  if (!isEmoji) { //non emoji
                                      [tagText appendString:substring];
                                  }
                                  else {
                                      NSMutableString *subTagText = [[NSMutableString alloc] init];
                                      
                                      [subTagText appendString:beginTag]; //begin tag
                                      for (NSInteger index = 0; index < subLength; ++index) {
                                          unichar unicode = [substring characterAtIndex:index];
                                          
                                          if (index != subLength-1) { //not last part
                                              [subTagText appendFormat:@"%04x#", unicode]; //split #
                                          }
                                          else {
                                              [subTagText appendFormat:@"%04x", unicode];
                                          }
                                      } //for
                                      [subTagText appendString:endTag]; //end tag
                                      
                                      [tagText appendString:subTagText]; //add tags and split
                                  }
                              }// else other case of high hex
                              
                          }];
    return tagText;
}

/**
 http://unicode.org/emoji/charts/full-emoji-list.html#1f600
 list about 1624 emoji.
 http://unicode.org/emoji/charts/emoji-candidates.html
 unicode v9.0 Candidates.
 */
- (BOOL)isContainEmoji
{
    __block BOOL returnValue = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              const unichar hs = [substring characterAtIndex:0];
                              
                              if (0xd800 <= hs && hs <= 0xdbff) { //leading, high
                                  if (substring.length > 1) {
                                      const UTF32Char SURROGATE_OFFSET = 0x10000 - (0xD800 << 10) - 0xDC00;
                                      
                                      const unichar ls = [substring characterAtIndex:1];
                                      // code point
                                      //const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                      UTF32Char uc = (hs << 10) + ls + SURROGATE_OFFSET;
                                      if (0x1d000 <= uc && uc <= 0x1f77f) {
                                          returnValue = YES;
                                      }
                                      else if(0x1F910 <= uc && uc <= 0x1F918) {
                                          //Supplemental Symbols And Pictographs — Emoticon faces
                                          returnValue = YES;
                                      }
                                      else if(0x1F919 <= uc && uc <= 0x1F9FF) {
                                          //Emoji 9.0 Candidates
                                          returnValue = YES;
                                      }
                                  } //if
                              }
                              else {
                                  if (0x2100 <= hs && hs <= 0x27ff) {
                                      returnValue = YES;
                                  }
                                  else if (0x203C == hs || 0x2049 == hs) {
                                      // General Punctuation — Double punctuation for vertical text
                                      //  ‼️  or ⁉️
                                      returnValue = YES;
                                  }
                                  else if(0x00A9 == hs || 0x00AE == hs) {
                                      // Latin 1 Supplement — Latin-1 punctuation and symbols
                                      //  ©️ or ®️
                                      returnValue = YES;
                                  }
                                  else if(0x2934 == hs || 0x2935 == hs) {
                                      //Supplemental Arrows B — Miscellaneous curved arrows
                                      // ⤴️ or  ⤵️
                                      returnValue = YES;
                                  }
                                  else if(0x2B05 <= hs && hs <= 0x2B07) {
                                      // Miscellaneous Symbols And Arrows — White and black arrows
                                      returnValue = YES;
                                  }
                                  else if (0x2B1B == hs || 0x2B1C == hs) {
                                      // Miscellaneous Symbols And Arrows — Squares
                                      returnValue = YES;
                                  }
                                  else if (0x2B50 == hs) {
                                      // Miscellaneous Symbols And Arrows — Stars
                                      returnValue = YES;
                                  }
                                  else if (0x2B55 == hs) {
                                      // Miscellaneous Symbols And Arrows — Traffic sign from ARIB STD B24
                                      returnValue = YES;
                                  }
                                  else if (0x3030 == hs) {
                                      // CJK Symbols And Punctuation — CJK symbols
                                      returnValue = YES;
                                  }
                                  else if (0x303D == hs) {
                                      // CJK Symbols And Punctuation — Other CJK punctuation
                                      returnValue = YES;
                                  }
                                  else if (0x3297 == hs || 0x3299 == hs) {
                                      // Enclosed CJK Letters And Months — Circled ideographs
                                      returnValue = YES;
                                  }
                                  else if (0x0023 == hs || 0x002A == hs) {
                                      // Basic Latin — ASCII punctuation and symbols
                                      returnValue = YES;
                                  }
                                  else if(substring.length == 3) {
                                      //digit 0-9
                                      const unichar next = [substring characterAtIndex:1];
                                      if (next == 0xfe0f && hs >= 0x0030 && hs<= 0x0039) {
                                          returnValue = YES;
                                      }
                                  }
                              }//
                          }];
    return returnValue;
}

- (NSString*)removeEmojiTag
{
    if ([self length] == 0) {
        return nil;
    }
    
    NSString *beginTag = @"[emoji]";
    NSString *endTag = @"[/emoji]";
    
    // check contain tag or not
    NSRange range = [self rangeOfString:beginTag options:NSCaseInsensitiveSearch];
    if (range.location == NSNotFound) { //non match any begin tag
        return self;
    }
    
    NSMutableString *utf8Text = [[NSMutableString alloc] init];
    
    // scan match string
    NSScanner *scanner = [NSScanner scannerWithString:self];
    while (![scanner isAtEnd])
    {
        // scan begin tag
        BOOL didMatchTag = NO;
        NSString *scanText = nil;
        BOOL didScan = [scanner scanUpToString:beginTag intoString:&scanText];
        if (!didScan) {
            // match at the begin
            didMatchTag = YES;
            scanner.scanLocation += beginTag.length; // skip it
        }
        else if (scanner.scanLocation < self.length) {
            // match
            didMatchTag = YES;
            scanner.scanLocation += beginTag.length; // skip it
            
            [utf8Text appendString:scanText]; //save part text
        }
        else {
            // not match, at the end of text.
            if ([scanText length] > 0) {
                [utf8Text appendString:scanText]; //save remain text
            }
            break;
        }
        
        // scan end tag
        if (didMatchTag) {
            scanText = nil; //reset
            didScan = [scanner scanUpToString:endTag intoString:&scanText];
            if (!didScan) {
                // match at the begin
                // wrong match
                utf8Text = nil; //clear
                break ;
            }
            else if (scanner.scanLocation < self.length) {
                // match end tag
                scanner.scanLocation += endTag.length; // skip it
                
                // build emoji
                NSMutableString *unicodeEmoji = [[NSMutableString alloc] init];
                NSArray *unicodeTexts = [scanText componentsSeparatedByString:@"#"];
                // build utf8 emoji
                for (NSString *unicodeText in unicodeTexts) {
                    if ([unicodeText hasPrefix:@"1d"] || [unicodeText hasPrefix:@"1f"]) {
                        // code point
                        [unicodeEmoji appendString:[self escapeCodePointText:unicodeText]];
                    }
                    else {
                        [unicodeEmoji appendFormat:@"\\u%@", unicodeText];
                    }
                } //for
                // unescape
                NSString *unescapedText = [NSString stringWithCString:[unicodeEmoji cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
                
                if (unescapedText != nil) {
                    [utf8Text appendString:unescapedText];
                }
            }
            else {
                // wrong match
                utf8Text = nil; //clear
                break;
            }
        }
    } //while
    
    scanner = nil;
    
    if ([utf8Text length] > 0) {
        return utf8Text;
    }
    
    return nil;
}

//helper
- (NSString*)escapeCodePointText:(NSString*)codePointText
{
    NSString *hexText = [[NSString alloc] initWithFormat:@"0x%@", codePointText];
    unsigned int codePoint = [self hexToInteger: hexText];
    
    //ref http://www.unicode.org/faq/utf_bom.html
    
    //constant
    const UTF32Char LEAD_OFFSET = 0xD800 - (0x10000 >> 10);
    // computations
    UTF16Char lead = LEAD_OFFSET + (codePoint >> 10);
    UTF16Char trail = 0xDC00 + (codePoint & 0x3FF);
    
    NSString *escapeText = [[NSString alloc] initWithFormat:@"\\u%x\\u%x", lead, trail];
    return escapeText;
}

// helper
- (unsigned int)hexToInteger:(NSString*)HexVal
{
    unsigned int decVal = 0 ;
    NSScanner* scan = [NSScanner scannerWithString:HexVal];
    [scan scanHexInt:&decVal];
    scan = nil;
    return decVal;
}

@end
