//
//  NSString+QISEmoji.h
//  YYK
//
//  Created by xiexianyu on 4/14/16.
//  Copyright © 2016 xiexianyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QISEmoji)

- (NSString*)escapeUnicodeEmoji;
- (NSString*)removeEmojiTag;

- (BOOL)isContainEmoji;
- (NSString*)tagEmoji;

@end
