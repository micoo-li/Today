#import <Cocoa/Cocoa.h>

@interface DHCircularProgressView : NSView

@property (readwrite, retain) NSColor *fillColor;
@property (readwrite, retain) NSColor *progressColor;

- (void)incrementBy:(double)value;
- (void)setMaxValue:(double)maxValue;
- (void)setCurrentValue:(double)currentValue;
- (void)setIncrementalSteps:(NSArray *)incrementalSteps;

-(void)setBackgroundColor:(NSColor *)color;

- (double)currentValue;
- (double)maxValue;

@end
