//
//  LoadingHUDView.m
//  Created by Devin Ross on 7/2/09.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */
#import "LoadingHUDView.h"
#import "NSString+Additions.h"
#import "UIView+Draw.h"


#define WIDTH_MARGIN 20
#define HEIGHT_MARGIN 20

@interface LoadingHUDView (PrivateMethods)
- (CGSize) calculateHeightOfTextFromWidth:(NSString*)text font: (UIFont*)withFont width:(float)width linebreak:(NSLineBreakMode)lineBreakMode;
@end


@implementation LoadingHUDView
@synthesize radius;

- (id) initWithTitle:(NSString*)ttl message:(NSString*)msg{
	if(self = [super initWithFrame:CGRectMake(0, 0, 280, 200)]){
		
		_title = [ttl copy];
		_message = [msg copy];
		_activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[self addSubview:_activity];
		_hidden = YES;
		self.backgroundColor = [UIColor clearColor];
		
	}
	return self;
}
- (id) initWithTitle:(NSString*)ttl{
    
    self = [self initWithTitle:ttl message:nil];
	if(!self) 
        return nil;
	return self;	
}

- (void) drawRect:(CGRect)rect {
	
	if(_hidden) return;
	int width, rWidth, rHeight, x;
	
	
	UIFont *titleFont = [UIFont boldSystemFontOfSize:16];
	UIFont *messageFont = [UIFont systemFontOfSize:12];
	
	CGSize s1 = [self calculateHeightOfTextFromWidth:_title font:titleFont width:200 linebreak:NSLineBreakByTruncatingTail];
	CGSize s2 = [self calculateHeightOfTextFromWidth:_message font:messageFont width:200 linebreak:NSLineBreakByCharWrapping];
	
	if([_title length] < 1) s1.height = 0;
	if([_message length] < 1) s2.height = 0;
	
	
	rHeight = (s1.height + s2.height + (HEIGHT_MARGIN*2) + 10 + _activity.frame.size.height);
	rWidth = width = (s2.width > s1.width) ? (int) s2.width : (int) s1.width;
	rWidth += WIDTH_MARGIN * 2;
	x = (280 - rWidth) / 2;
	
	_activity.center = CGPointMake(280/2,HEIGHT_MARGIN + _activity.frame.size.height/2);
	
	
	//DLog(@"DRAW RECT %d %f",rHeight,self.frame.size.height);
	
	// DRAW ROUNDED RECTANGLE
	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9] set];
	CGRect r = CGRectMake(x, 0, rWidth,rHeight);
	[UIView drawRoundRectangleInRect:r 
						  withRadius:10.0 
							   color:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75]];
	
	
	// DRAW FIRST TEXT
//	[[UIColor whiteColor] set];
	r = CGRectMake(x+WIDTH_MARGIN, _activity.frame.size.height + 10 + HEIGHT_MARGIN, width, s1.height);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName:titleFont, NSParagraphStyleAttributeName:paragraphStyle.copy,NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize titleSize = [_title sizeWithAttributes:attributes];
    [_title drawInRect:r withAttributes:attributes];
	
	
	// DRAW SECOND TEXT
	r.origin.y += titleSize.height;
	r.size.height = s2.height;
    
    
    NSMutableParagraphStyle *messageParagraphStyle = [[NSMutableParagraphStyle alloc]init];
    messageParagraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    messageParagraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *messageAttributes = @{NSFontAttributeName:messageFont, NSParagraphStyleAttributeName:messageParagraphStyle.copy,NSForegroundColorAttributeName:[UIColor whiteColor]};
    [_message drawInRect:r withAttributes:messageAttributes];
	
	
	
}


- (void) setTitle:(NSString*)str{
	_title = [str copy];
	//[self updateHeight];
	[self setNeedsDisplay];
}
- (NSString*) title{
	return _title;
}

- (void) setMessage:(NSString*)str{
	_message = [str copy];
	[self setNeedsDisplay];
}
- (NSString*) message{
	return _message;
}

- (void) setRadius:(float)f{
	if(f==radius) return;
	
	radius = f;
	[self setNeedsDisplay];
	
}

- (void) startAnimating{
	if(!_hidden) return;
	_hidden = NO;
	[self setNeedsDisplay];
	[_activity startAnimating];
	
}
- (void) stopAnimating{
	if(_hidden) return;
	_hidden = YES;
	[self setNeedsDisplay];
	[_activity stopAnimating];
	
}


- (CGSize) calculateHeightOfTextFromWidth:(NSString*)text font: (UIFont*)withFont width:(float)width linebreak:(NSLineBreakMode)lineBreakMode{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary *attributes = @{NSFontAttributeName:withFont, NSParagraphStyleAttributeName:paragraphStyle.copy};
	return [text boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL].size;
}
- (void) adjustHeight{
	
	CGSize s1 = [_title heightWithFont:[UIFont boldSystemFontOfSize:16.0] 
								 width:200.0 
							 linebreak:NSLineBreakByTruncatingTail];
	
	CGSize s2 = [_message heightWithFont:[UIFont systemFontOfSize:12.0] 
								   width:200.0 
							   linebreak:NSLineBreakByCharWrapping];

	CGRect r = self.frame;
	r.size.height = s1.height + s2.height + 20;
	self.frame = r;
}



@end