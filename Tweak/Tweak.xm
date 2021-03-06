#import <UIKit/UIKit.h>
#include <substrate.h>

@interface SBLockScreenScrollView : UIScrollView 
@end

@interface SBLockScreenViewControllerBase : NSObject
@end

@interface SBLockScreenView : UIView
@property (assign) id delegate;
-(UIScrollView *)scrollView;
@end

@interface SBLockScreenViewController : UIViewController <UISearchBarDelegate, UINavigationControllerDelegate>
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
@end


%hook SBLockScreenViewControllerBase

BOOL shouldAutoLock;
NSNumber* autoLockEnabled;
NSNumber* shouldShowDictSearchBar;

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

UISearchBar *dictSearchBar;
SBLockScreenScrollView *scrollView;
UIReferenceLibraryViewController *dictionaryViewController;

-(void)loadView
{
	%orig;

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:
	[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.halfnet.locktionaryPrefs.plist"]];

	shouldShowDictSearchBar = [settings objectForKey:@"enabled"];
	autoLockEnabled = [settings objectForKey:@"autolock"];

	dictSearchBar = [[UISearchBar alloc] init];

	[dictSearchBar setBackgroundImage:[[UIImage alloc]init]];

	dictSearchBar.backgroundColor = [UIColor whiteColor];

	dictSearchBar.placeholder = @"Search Dictionary";

	dictSearchBar.layer.cornerRadius = 10;

	dictSearchBar.delegate = self;

	scrollView = MSHookIvar <SBLockScreenScrollView *>(self.view , "_foregroundScrollView");

	[scrollView addSubview:dictSearchBar];

	shouldAutoLock = YES;
}

-(void)viewWillAppear:(BOOL)arg1
{	
	%orig;

	
	

	CGFloat scrollViewWidth = scrollView.frame.size.width;
	CGFloat scrollViewHeight = scrollView.frame.size.height;

	[dictSearchBar setFrame:CGRectMake(
	scrollViewWidth * 1.35,
	scrollViewHeight * 0.04f,
	scrollViewWidth * 0.3f,
	scrollViewHeight * 0.05f
	)];

	[dictSearchBar setHidden:![shouldShowDictSearchBar boolValue]];

	shouldAutoLock = YES;

}

-(void)viewWillDisappear:(BOOL)arg1
{
	[dictionaryViewController dismissModalViewControllerAnimated:YES];

	shouldAutoLock = YES;

	%orig;
}

%new
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];

	dictionaryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:searchBar.text];
	
	[self presentModalViewController:dictionaryViewController animated:YES];  

	shouldAutoLock = NO;
}
%end

%hook UIReferenceLibraryViewController
- (void)_searchWeb:(id)arg1
{
	if(dictionaryViewController.isViewLoaded && dictionaryViewController.view.window)
	{
		UIAlertController *alertController = [UIAlertController
			      alertControllerWithTitle:@"Not Supported"
			      message:@"Searching the web is not supported on the Lock Screen"
			      preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction *okAction = [UIAlertAction 
			actionWithTitle:@"OK"
			style:UIAlertActionStyleCancel
			handler:^(UIAlertAction *action)
				{
					NSLog(@"OK action");
				}
			];

		[alertController addAction:okAction];

		[self presentViewController:alertController animated:YES completion:nil];

	
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