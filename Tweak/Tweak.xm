#import <UIKit/UIKit.h>
#include <substrate.h>

@interface SBLockScreenScrollView : UIScrollView 
@end

@interface SBLockScreenViewControllerBase : NSObject
@end

@interface SBLockScreenView : UIView
@property (assign) id delegate; 												//@synthesize delegate=_delegate - In the implementation block
-(UIScrollView *)scrollView;
@end

@interface SBLockScreenViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate>
- (void)textFieldFinished:(id)sender;
@end


%hook SBLockScreenViewControllerBase

BOOL shouldAutoLock;
NSNumber* autoLockEnabled;
NSNumber* shouldShowTextField;

- (BOOL)canRelockForAutoDimTimer
{

	%orig;

	if([autoLockEnabled boolValue])
	{
		if(shouldAutoLock)
		{
			return YES;
		}
		else
		{
			return NO;
		}

	}
	else
	{
		return YES;
	}

}

%end



%hook SBLockScreenViewController

UITextField *textInputField;
SBLockScreenScrollView *scrollView;
UIReferenceLibraryViewController *dictionaryViewController;

-(void)loadView
{
	%orig;

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:
	[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.halfnet.locktionaryPrefs.plist"]];

	shouldShowTextField = [settings objectForKey:@"enabled"];
	autoLockEnabled = [settings objectForKey:@"autolock"];

	textInputField = [[UITextField alloc] init];

	[textInputField setReturnKeyType:UIReturnKeyDone];

	textInputField.backgroundColor = [UIColor whiteColor];

	textInputField.placeholder = @"Search Dictionary";
	
	[textInputField addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];

	scrollView = MSHookIvar <SBLockScreenScrollView *>(self.view , "_foregroundScrollView");

	[scrollView addSubview:textInputField];

	shouldAutoLock = YES;
}

-(void)viewWillAppear:(BOOL)arg1
{	
	%orig;

	
	

	CGFloat scrollViewWidth = scrollView.frame.size.width;
	CGFloat scrollViewHeight = scrollView.frame.size.height;

	[textInputField setFrame:CGRectMake(
	scrollViewWidth + 10.0f,
	scrollViewHeight * 0.3f,
	scrollViewWidth - 20.0f,
	scrollViewHeight * 0.07f
	)];

	[textInputField setHidden:![shouldShowTextField boolValue]];

	shouldAutoLock = YES;

}

-(void)viewWillDisappear:(BOOL)arg1
{
	[dictionaryViewController dismissModalViewControllerAnimated:YES];

	shouldAutoLock = YES;

	%orig;
}

%new
- (void)textFieldFinished:(UITextField *)textField
{

	[textField resignFirstResponder];

	dictionaryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:textField.text];
	
	[self presentModalViewController:dictionaryViewController animated:YES];  

	shouldAutoLock = NO;

}
%end

%hook UIReferenceLibraryViewController
- (void)_searchWeb:(id)arg1
{
	if(dictionaryViewController.isViewLoaded && dictionaryViewController.view.window)
	{
		[dictionaryViewController dismissModalViewControllerAnimated:YES];

		textInputField.text = @"Search Web Pressed";

		NSLog(@"Searching Web Not Supported");
	
	}
	else
	{
		%orig;
	}

}

- (void)_dismissModalReferenceView:(id)arg1
{
	if(dictionaryViewController.isViewLoaded && dictionaryViewController.view.window)
	{
		dictionaryViewController = nil;

		shouldAutoLock = YES;
		
	}

		%orig;
}

%end