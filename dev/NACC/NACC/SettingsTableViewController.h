//
//  SettingsViewController.h
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
#import <QuartzCore/QuartzCore.h>
#import "Settings.h"

@interface SettingsClass : NSObject <NSCoding>
{
    NACC_Settings   mySettings;
}

- (NACC_SettingsPtr)getSettings;
- (void)setCleanTime:(NSDate *)inDate;

@end

@interface SettingsTableViewController : UIViewController <UITabBarControllerDelegate>
{
    IBOutlet UILabel    *headingLabel;              ///< The main page heading
    
    IBOutlet UISwitch   *displayGraniteSwitch;      ///< The switch for the granite keytag pref
    IBOutlet UISwitch   *displayPurpleSwitch;       ///< The switch for the purple keytag pref
    IBOutlet UISwitch   *purpleEveryTenYearsSwitch; ///< The switch for the purple every ten years pref
    IBOutlet UISwitch   *saveCleantimeSwitch;       ///< The switch for the save cleanetime pref
    IBOutlet UISwitch   *limitDatesSwitch;          ///< The switch for the limit dates pref
    IBOutlet UISwitch   *rollingScrollerSwitch;
    
    /// These are all labels for the above switches. They are clickable buttons that will toggle their respective switches.
    IBOutlet UIButton   *displayGraniteLabel;
    IBOutlet UIButton   *displayPurpleLabel;
    IBOutlet UIButton   *displayPurpleEveryTenYearsLabel;
    IBOutlet UIButton   *saveCleantimeLabel;
    IBOutlet UIButton   *limitDatesLabel;
    IBOutlet UIButton   *rollingScrollerLabel;
    
    /// These hold localized strings, for use during runtime.
    NSString            *loc_settings_string_1;
    NSString            *loc_settings_string_2;
    NSString            *loc_settings_string_3;
    NSString            *loc_settings_string_4;
    NSString            *loc_settings_string_5;
    NSString            *loc_settings_string_6;
    NSString            *loc_settings_string_7;
    NSString            *loc_settings_string_8;
    
    SettingsClass       *mySettings;    ///< These are the global settings. This instance is used throughout the app
}
/// The switches call these. They can also be called from the label buttons.
- (IBAction)displayGraniteChanged:(id)sender;
- (IBAction)displayPurpleChanged:(id)sender;
- (IBAction)purpleEveryTenYearsChanged:(id)sender;
- (IBAction)saveCleantimeChanged:(id)sender;
- (IBAction)limitDatesChanged:(id)sender;
- (IBAction)rollingScrollerChanged:(id)sender;

/// Accessors for the cleantime property
- (void)setCleanTime:(NSDate *)inDate;
- (NSDate *)getCleanTime;

- (void)setBeanieBackground;
- (NSString *)docPath;
- (BOOL)saveChanges;
- (void)getData;
- (NACC_SettingsPtr)getSettings;

@end
