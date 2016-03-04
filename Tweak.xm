//#import <UIKit/UIKit.h>

@interface SBLockScreenScrollView : UIScrollView 
@end

@interface textFieldHandler : UIViewController<UITextFieldDelegate>{

SBLockScreenScrollView* scrollView;
UIReferenceLibraryViewController *dictionaryViewController;
UITextField *currentTextField;
}


- (void)onDictTap;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)setScrollView:(SBLockScreenScrollView *)view;

@end

@implementation textFieldHandler : UIViewController

- (void)onDictTap{

[dictionaryViewController.view removeFromSuperview];

}

- (void)setScrollView:(SBLockScreenScrollView *)view{

scrollView=view;

}

- (void) orientationChanged:(NSNotification *)note
{

CGFloat scrollViewWidth = scrollView.frame.size.width;
CGFloat scrollViewHeight = scrollView.frame.size.height;

UIDevice * device = note.object;

switch(device.orientation){

case UIDeviceOrientationPortrait:

dictionaryViewController.view.frame = CGRectMake(
scrollViewHeight*0.75,
0,
scrollViewHeight*0.75,
scrollViewWidth*1.33
);

break;

case UIDeviceOrientationPortraitUpsideDown:

dictionaryViewController.view.frame = CGRectMake(
scrollViewHeight*0.75,
0,
scrollViewHeight*0.75,
scrollViewWidth*1.33
);

break;

case UIDeviceOrientationLandscapeLeft:

dictionaryViewController.view.frame = CGRectMake(
scrollViewHeight*1.32,
0,
scrollViewHeight*1.35,
scrollViewWidth*0.75
);

break;

case UIDeviceOrientationLandscapeRight:

dictionaryViewController.view.frame = CGRectMake(
scrollViewHeight*1.32,
0,
scrollViewHeight*1.35,
scrollViewWidth*0.75
);

break;

default:

break;
};

   
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{   

currentTextField = textField;

[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

[[NSNotificationCenter defaultCenter]
addObserver:self selector:@selector(orientationChanged:)
name:UIDeviceOrientationDidChangeNotification
object:[UIDevice currentDevice]];

return YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

CGFloat scrollViewWidth = scrollView.frame.size.width;
CGFloat scrollViewHeight = scrollView.frame.size.height;

[textField resignFirstResponder];

dictionaryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:textField.text];

dictionaryViewController.view.frame = CGRectMake(
scrollViewHeight*1.32,
0,
scrollViewHeight*1.35,
scrollViewWidth*0.75
);
    
UITapGestureRecognizer *dictTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDictTap)];

dictTapRecognizer.numberOfTapsRequired = 1;

[dictionaryViewController.view addGestureRecognizer:dictTapRecognizer];

[scrollView addSubview:dictionaryViewController.view];

return YES;
}
@end

%hook SBLockScreenView 
UITextField* textInputField;
-(void)didMoveToWindow {

if(!textInputField){
SBLockScreenScrollView *scrollView = MSHookIvar <SBLockScreenScrollView *>(self , "_foregroundScrollView");

CGFloat scrollViewWidth = scrollView.frame.size.width;
CGFloat scrollViewHeight = scrollView.frame.size.height;



textInputField = [[UITextField alloc] initWithFrame:CGRectMake(
2.0*scrollViewHeight, 
0.3*scrollViewWidth, 
0.4*scrollViewHeight,
0.07*scrollViewWidth
)];

[textInputField setReturnKeyType:UIReturnKeyDone];

textInputField.backgroundColor = [UIColor whiteColor];

textInputField.placeholder = @"Search Dictionary";

textFieldHandler *textFieldDelegate = [[textFieldHandler alloc] init];

textInputField.delegate=textFieldDelegate;

[textFieldDelegate setScrollView:scrollView];

[scrollView addSubview:textInputField];
}
%orig;

}
%end