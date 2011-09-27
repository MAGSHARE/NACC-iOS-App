//
//  SelectCleanDateViewController.m
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

#import "SelectCleanDateViewController.h"
#import "CleanDateViewController.h"

@implementation SelectCleanDateViewController

#pragma mark - SettingsContainer code

/**
 \brief Point to the settings in the central location.
 */
- (void)setSettingsPtr:(NACC_SettingsPtr)in_settings
{
    mySettings = in_settings;
}

#pragma mark - SelectCleanDateViewController code

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (id)init
    {
    self = [super initWithNibName: @"SelectCleanDateViewController" bundle:nil];
    
    if (self)
        {
        loc_datepicker_string_1 = [[NSString stringWithString:NSLocalizedString(@"DATE-PICKER-TODAY", @"The title for the 'Today' button in the date picker toolbar")] retain];
        loc_datepicker_string_2 = [[NSString stringWithString:NSLocalizedString(@"TAB-BAR-2", @"TAB BAR (BOTTOM OF SCREEN): Title for the Cleantime Tab Bar Item")] retain];
        
        if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad )
            {
            [self setContentSizeForViewInPopover:[[self view] bounds].size];
            }
        else
            {
            [self setModalPresentationStyle:UIModalPresentationPageSheet];
            [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            }
        }
    return self;
}

- (void)dealloc
{
    [dpToolBar release];
    [todayButton release];
    [loc_datepicker_string_1 release];
    [loc_datepicker_string_2 release];
    [myCalendar release];

    [cancelButton release];
    [doneButton release];
    [dpView release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [dpToolBar release];
    dpToolBar = nil;
    
    [todayButton release];
    todayButton = nil;
}

#pragma mark - View lifecycle
/**
 \brief We set the background here, in case the view gets unloaded in a memory crisis.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBeanieBackground];
}

/**
 \brief Just before the view appears, we set up the dynamic date picker.
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpPicker];
}

/**
 \brief We scrag it when we are about to disappear.
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self takeDownDatePicker];
}

- (void)setUpPicker
{
    if ( datePicker )
        {
        [self takeDownDatePicker];  // Should never happen.
        }
    
    CGRect  dpFrame = [dpView bounds];
    
    myCalendar = [[NSCalendar currentCalendar] copy];
    
    datePicker = [[[UIDatePicker alloc] initWithFrame:dpFrame] retain];
    
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    if ( [[NSLocale currentLocale] localeIdentifier] == @"fa_IR" )
        {
        myCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSPersianCalendar];
        }
    
    [datePicker setCalendar:myCalendar];
    
    if ( mySettings->limitDates )   // If the user has chosen to limit dates, then we do so.
        {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:17];
        [comps setMonth:8];
        [comps setYear:1953];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDate  *firstMeeting = [gregorian dateFromComponents:comps];

        NSDate *today = [NSDate date];
        
        [comps release];
        [gregorian release];
        
        [datePicker setMinimumDate:firstMeeting];   // Can't go past the first NA meeting.
        [datePicker setMaximumDate:today];          // Can't go past today.
        }
    
    // If we are not remembering the cleandate, we clear the picker, by setting it to today.
    if ( !mySettings->saveCleantime )
        {
        [mySettings->cleanDate release];
        mySettings->cleanDate = [[NSDate date] retain];
        }
    
    [datePicker setDate:mySettings->cleanDate animated:NO];
    [todayButton setTitle:loc_datepicker_string_1];
    
    [dpView addSubview:datePicker];
}

- (void)takeDownDatePicker
{
    if ( datePicker )
        {
        [datePicker removeFromSuperview];
        [datePicker release];
        datePicker = nil;
        [myCalendar release];
        myCalendar = nil;
        }
}

- (void)viewDidUnload
{
    [cancelButton release];
    cancelButton = nil;
    [doneButton release];
    doneButton = nil;
    [dpView release];
    dpView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    BOOL    ret = ((io == UIInterfaceOrientationPortrait) || (io == UIInterfaceOrientationLandscapeLeft) || (io == UIInterfaceOrientationLandscapeRight));
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
        ret = YES;
        }
    return ret;
}

/**
 \brief Sets the date picker to today
 */
- (IBAction)setToday
{
    if ( datePicker )
        {
        [datePicker setDate:[NSDate date]];
        }
}

/**
 \brief This is called when the picker is dismissed. It re-establishes the original items, and triggers a cleantime calculation.
 */
- (IBAction)pickerDone:(id)sender
{
    if ( sender == doneButton )
        {
        [mySettings->cleanDate release];
        mySettings->cleanDate = [[[datePicker date] copy] retain];
        [settingsController saveChanges];
        [myCleanDateDisplayController calcAndDisplay];
        }
    [myCleanDateDisplayController closeDatePicker];
}

/**
 \brief This allows the main controller to tell this controller about the other controller.
        Confused, yet? ;)
 */
- (void)setSettingsController:(SettingsTableViewController *)in_controller
{
    settingsController = in_controller;
}

/**
 \brief Point to the Clean Date Display controller
 */
- (void)setCDDisplayController:(CleanDateViewController *)in_controller
{
    myCleanDateDisplayController = in_controller;
}

/**
 \brief This applies the "Beanie Background" to the results view.
 */
- (void)setBeanieBackground
{
    [[[self view] layer] setContentsGravity:kCAGravityResizeAspectFill];
    [[[self view] layer] setBackgroundColor:[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    
    UIImage *layerImage = [UIImage imageNamed:@"BeanieBack.png"];
    CGImageRef image = [layerImage CGImage];
    
    [[[self view] layer] setContents:(id)image];
}

@end
