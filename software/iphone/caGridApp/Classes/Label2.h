// Label2.h
// (c) 2009 Ivan Misuno, www.cuberoom.biz

#import <UIKit/UIKit.h>

typedef enum
	{
		VerticalAlignmentTop = 0, // default
		VerticalAlignmentMiddle,
		VerticalAlignmentBottom,
	} VerticalAlignment;

@interface Label2 : UILabel
{
@private
	VerticalAlignment _verticalAlignment;
}

@property (nonatomic) VerticalAlignment verticalAlignment;

@end