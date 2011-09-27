//
//  InfoViewController.h
//  NACC
//
//  Created by MAGSHARE on 7/24/11.
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
#import "Settings.h"
#include <time.h>

@interface InfoViewController : UIViewController <SettingsContainer, UITabBarControllerDelegate>
{
    IBOutlet UILabel    *mainHeader;
    IBOutlet UILabel    *magshareLabel;
    IBOutlet UILabel    *versionLabel;
    IBOutlet UILabel    *versionValue;
    IBOutlet UILabel    *gitHubLinkLabel;
    IBOutlet UIButton   *gitHubLinkButton;
    IBOutlet UIButton   *magshareButton;
    IBOutlet UITextView *textView;
    
    NSString    *loc_info_string_1;
    NSString    *loc_info_string_2;
    NSString    *loc_info_string_3;
    NSString    *loc_info_string_4;
    NSString    *loc_info_string_5;
    NSString    *loc_info_string_6;
    NSString    *loc_info_string_7;
    NSString    *loc_info_string_8;
    
    /// This points to the global settings, maintained by the app delegate.
    NACC_SettingsPtr    mySettings;
    time_t              visitingMAGSHARE;
}

- (IBAction)visitURI:(id)sender;

- (void)setBeanieBackground;
- (time_t)isVisitingMAGSHARE;
- (void)clearVisitingMAGSHARE;
- (void)displayVersion;

@end
