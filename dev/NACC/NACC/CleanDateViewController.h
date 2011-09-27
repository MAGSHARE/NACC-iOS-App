//
//  CleanDateViewController.h
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
#import "KeytagScrollerViewController.h"
#import "SelectCleanDateViewController.h"
#import "SettingsTableViewController.h"
#import "InfoViewController.h"

#define _AVG_COUNT  20  ///< This is how many samples will be taken in an accelerometer average (1/5 second).

@interface CleanDateViewController : UIViewController <UIAccelerometerDelegate, UIPopoverControllerDelegate, SettingsContainer>
{
    struct NACC_Calc_Result clean_calc; ///< This holds the calculation result.
    
    // The are the xib-defined views. These are "convenience" pointers.
    IBOutlet UIButton           *cleanDateButton;   ///< The big "Enter Your Clean Date" button.
    IBOutlet UITextView         *resultsTextView;   ///< This is a standard read-only text view that shows the textual output.
    IBOutlet UIView             *calcView;          ///< This is a container for the key fobs display. We create subviews for it.
    IBOutlet UILabel            *headerLabel;       ///< This is the main header.
    IBOutlet UILabel            *congratulationsLabel;  ///< This contains a note of congratulations on anniversary dates.
    IBOutlet UIButton           *clearButton;       ///< This button is displayed when there are results, and allows them to be cleared.
    
    /// These are dynamically-constructed views and controllers.
    KeytagScrollerViewController    *keyTagController;
    UIView                          *shadowView;
    KeytagScroller                  *resultsScrollerView;
    SettingsTableViewController     *settingsController;    ///< We only care about this, so we know when we're coming in from it.
    SelectCleanDateViewController   *cleandatePickerController;
    UITabBarController              *myTabBarController;
    UIPopoverController             *datePickerPopover;
    
    /// These hold localized strings, for use during runtime.
    NSString                *loc_string_1;
    NSString                *loc_string_2;
    NSString                *loc_string_3;
    NSString                *loc_string_4;
    NSString                *loc_string_5;
    NSString                *loc_string_6;
    NSString                *loc_string_7;
    NSString                *loc_string_8;
    NSString                *loc_string_9;
    NSString                *loc_string_10;
    NSString                *loc_string_11;
    NSString                *loc_string_12;
    NSString                *loc_string_13;
    NSString                *loc_string_14;
    NSString                *loc_string_15;
    NSString                *loc_string_16;
    NSString                *loc_string_17;
    NSString                *loc_string_18;
    
    /// This points to the global settings, maintained by the app delegate.
    NACC_SettingsPtr    mySettings;
    
    BOOL                dateCalculated;
    
    double              accelavg[_AVG_COUNT];   ///< Used to average the accelerator
    int                 average_slot;           ///< Keeps track of which cell to update. We track the last _AVG_COUNT samples.
    int                 average_count;          ///< We don't start posting results until we get to _AVG_COUNT.
}

- (IBAction)enterCleanDate:(id)sender;
- (IBAction)clearResults:(id)sender;

- (void)closeDatePicker;
- (void)setSettingsController:(UIViewController *)inController;
- (void)setTabBarController:(UITabBarController *)in_controller;
- (void)setCleaDatePickerController:(SelectCleanDateViewController *)in_controller;
- (void)clearCleanCalc;
- (void)calculateCleandate:(NSDate *)cleanDate;
- (void)calcAndDisplay;

- (void)displayCleanDateInButton;
- (void)displayCleandate;

- (void)setBeanieBackground;
- (void)setShadow;

- (BOOL)isDateCalculated;
- (UIPopoverController *)getDatePickerPopover;

- (void)setupAccel;
- (void)readAccel:(UIAcceleration *)accel;
- (double)getAccelAvg;
- (void)stopAccel;

@end
