//
//  SelectCleanDateViewController.h
//  NACC
//
//  Created by MAGSHARE on 7/20/11.
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
#import "SettingsTableViewController.h"

@class CleanDateViewController;

@interface SelectCleanDateViewController : UIViewController <SettingsContainer>
{
    IBOutlet UIToolbar              *dpToolBar;         ///< The toolbar under the date picker.
    IBOutlet UIBarButtonItem        *todayButton;
    IBOutlet UIBarButtonItem        *cancelButton;
    IBOutlet UIBarButtonItem        *doneButton;
    IBOutlet UIView                 *dpView;
    
    UIDatePicker                    *datePicker;
    NSString                        *loc_datepicker_string_1;
    NSString                        *loc_datepicker_string_2;
    NSCalendar                      *myCalendar;
    
    /// This points to the global settings, maintained by the app delegate.
    NACC_SettingsPtr                mySettings;
    SettingsTableViewController     *settingsController;    ///< We only care about this, so we know when we're coming in from it.
    CleanDateViewController         *myCleanDateDisplayController;
}

- (IBAction)setToday;
- (IBAction)pickerDone:(id)sender;

- (void)setUpPicker;
- (void)takeDownDatePicker;
- (void)setSettingsController:(SettingsTableViewController *)in_controller;
- (void)setCDDisplayController:(CleanDateViewController *)in_controller;
- (void)setBeanieBackground;

@end
