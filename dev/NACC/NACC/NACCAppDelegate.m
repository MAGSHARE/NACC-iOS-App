//
//  NACCAppDelegate.m
//  NACC
//
//  Created by MAGSHARE on 7/19/11.
//  Copyright 2011 MAGSHARE. All rights reserved.
//
/*
 This is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 NACC is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this code.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "NACCAppDelegate.h"

@implementation NACCAppDelegate


@synthesize window=_window;

#pragma mark - UITabBarDelegate code

/**
 \brief This animates the view transitions, and also sets up anything that needs doing between views.
 */
- (BOOL)tabBarController:(UITabBarController *)tabBarController
    shouldSelectViewController:(UIViewController *)viewController
    {
    BOOL ret = NO;
    
    // Need to have all of these to work.
    if ( tabBarController && [tabBarController view] && viewController && [viewController view] )
        {
        UIView  *srcView = [[tabBarController selectedViewController] view];
        UIView  *dstView = [viewController view];
        
        if ( srcView != dstView )
            {            
            if ( viewController == myCDController )
                {
                if ( [myCDController isDateCalculated] )    // If there were tags, we display them.
                    {
                    [myCDController calcAndDisplay];
                    }
                }
            
            // Make it so that going to and from the main cleantime view is animated, but not between the other two views. This makes the cleantime view more important.
            [UIView transitionFromView:srcView
                                toView:dstView
                              duration:0.25
                               options:( viewController == myCDController ) ? UIViewAnimationOptionTransitionCurlDown
                                      : ([tabBarController selectedViewController] == myCDController) ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionNone
                            completion:nil];
            ret = YES;
            }
        }
    
    return ret;
}
/************************************************************************//**
*                               STANDARD STUFF                              *
****************************************************************************/

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ( [KeyTagView imageFileInfo] )   // Serious problems if this ever returns nil.
        {
        // Create the tabBarController
        myTabBarController = [[UITabBarController alloc] init];
        
        // Create three view controllers
        myCDController = [[CleanDateViewController alloc] init];
        mySettingsController = [[SettingsTableViewController alloc] init];
        selectCleantimeController = [[SelectCleanDateViewController alloc] init];
        myInfoViewController = [[InfoViewController alloc] init];
        
        [myCDController setSettingsController:mySettingsController];    // This allows the calculator to know when we are coming in from the prefs.
        [myCDController setTabBarController:myTabBarController];        // This allows the calculator to call the set view.
        [myCDController setCleaDatePickerController:selectCleantimeController];    // So that the cleantime can present a modal dialog.
        [selectCleantimeController setCDDisplayController:myCDController];
        
        NSArray *viewControllers = [NSArray arrayWithObjects:myCDController, mySettingsController, myInfoViewController, nil];
        
        [selectCleantimeController setSettingsPtr:[mySettingsController getSettings]];
        [myCDController setSettingsPtr:[mySettingsController getSettings]];
        [myInfoViewController setSettingsPtr:[mySettingsController getSettings]];
        
        [myTabBarController setViewControllers:viewControllers animated:YES];
        [myTabBarController setDelegate:self];

        // Set tabBarController as rootViewController of window
        [[self window] setRootViewController:myTabBarController];
        
        [self.window makeKeyAndVisible];
        return YES;
        }
    else
        {
        return NO;
        }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [myInfoViewController clearVisitingMAGSHARE];
}

/**
 \brief We use this to clear the results and make sure we always start on the calculator.
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // We have a special exemption for this.
    if ( !(([myTabBarController selectedIndex] == 2) && (time(0) - [myInfoViewController isVisitingMAGSHARE]) < 18000) )
        {
        [myCDController clearResults:nil];
        [myTabBarController setSelectedIndex:0];
        }
}

/**
 \brief bye now
 */
- (void)dealloc
{
    [myCDController release];
    [myInfoViewController release];
    [mySettingsController release];
    [selectCleantimeController release];
    [myTabBarController release];
    [_window release];
    if ( [KeyTagView imageFileInfo] )   // Serious problems if this ever returns nil.
        {
        NSArray *imageNames = [KeyTagView imageFileInfo]->image_file_names;
        
        if ( imageNames )
            {
            [imageNames release];
            }
        
        free ( [KeyTagView imageFileInfo] );
        }
    [super dealloc];
}

@end
