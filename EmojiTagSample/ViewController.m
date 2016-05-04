//
//  ViewController.m
//  EmojiTagSample
//
//  Created by xiexianyu on 5/4/16.
//  Copyright © 2016 QIS. All rights reserved.
//

#import "ViewController.h"
#import "NSString+QISEmoji.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UITextView *tagTextView;
@property (weak, nonatomic) IBOutlet UITextView *checkTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleButtonTagEmoji:(id)sender {
    NSString *text = self.inputTextView.text;
    
    // tag emoji
    NSString *tagText = [text escapeUnicodeEmoji];
    self.tagTextView.text = tagText;
    
    // remove tag
    NSString *checkText = [tagText removeEmojiTag];
    self.checkTextView.text = checkText;
}

- (IBAction)handleButtonClearAll:(id)sender {
    self.inputTextView.text = nil;
    self.tagTextView.text = nil;
    self.checkTextView.text = nil;
}

- (IBAction)handleTap:(id)sender {
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    [self.inputTextView resignFirstResponder];
    [self.tagTextView resignFirstResponder];
    [self.checkTextView resignFirstResponder];
}

@end
