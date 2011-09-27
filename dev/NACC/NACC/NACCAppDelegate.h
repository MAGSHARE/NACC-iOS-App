//
//  NACCAppDelegate.h
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

#import <UIKit/UIKit.h>
#import "CleanDateViewController.h"
#import "SettingsTableViewController.h"
#import "SelectCleanDateViewController.h"
#import "InfoViewController.h"

@interface NACCAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
{
    CleanDateViewController         *myCDController;        ///< These are just used as a convenient way to track the controllers
    SettingsTableViewController     *mySettingsController;
    SelectCleanDateViewController   *selectCleantimeController;
    InfoViewController              *myInfoViewController;
    UITabBarController              *myTabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
