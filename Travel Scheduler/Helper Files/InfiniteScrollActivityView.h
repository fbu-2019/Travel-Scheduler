
#import <UIKit/UIKit.h>

@interface InfiniteScrollActivityView : UIView
    
@property (class, nonatomic, readonly) CGFloat defaultHeight;
    
- (void)startAnimating;
- (void)stopAnimating;
    
@end
