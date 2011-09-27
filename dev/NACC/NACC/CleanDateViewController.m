//
//  CleanDateViewController.m
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

/**
 \brief This is the main cotroller. It will switch the date picker with the main view to allow selection of a cleandate, and will control the display of results.
 */

#import "CleanDateViewController.h"
#import <math.h>

@implementation CleanDateViewController

#pragma mark - UIPopoverControllerDelegate code

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [datePickerPopover autorelease];
    datePickerPopover = nil;
}

#pragma mark - SettingsContainer code

/**
 \brief Point to the settings in the central location.
 */
- (void)setSettingsPtr:(NACC_SettingsPtr)in_settings
{
    mySettings = in_settings;
}


#pragma mark - Standard Code

#pragma mark - Initializers
/**
 \brief Initializes the calculator view with the nib file.
 
 \returns the self object.
*/
- (id)init
{
    self = [super initWithNibName: @"CleanDateViewController" bundle:nil];
    
    if (self)
        {
        // We initialize all the local strings. These will be replaced with the correct ones at runtime.
        // We use this awkward method, because we want to be able to localize all the strings.
        loc_string_1 = [[NSString stringWithString:NSLocalizedString(@"BANNER-1", @"MAIN WINDOW -START: Banner")] retain];
        loc_string_2 = [[NSString stringWithString:NSLocalizedString(@"BUTTON-1", @"MAIN WINDOW -START: Button Text")] retain];
        
        loc_string_3 = [[NSString stringWithString:NSLocalizedString(@"TEXT-1", @"MAIN WINDOW -RESULTS: The first part of the results string")] retain];
        loc_string_4 = [[NSString stringWithString:NSLocalizedString(@"TEXT-2-AND", @"MAIN WINDOW -RESULTS: And")] retain];
        loc_string_5 = [[NSString stringWithString:NSLocalizedString(@"TEXT-DAYS-PLURAL", @"MAIN WINDOW -RESULTS: Days")] retain];
        loc_string_6 = [[NSString stringWithString:NSLocalizedString(@"TEXT-MONTHS-PLURAL", @"MAIN WINDOW -RESULTS: Months")] retain];
        loc_string_7 = [[NSString stringWithString:NSLocalizedString(@"TEXT-YEARS-PLURAL", @"MAIN WINDOW -RESULTS: Years")] retain];
        loc_string_8 = [[NSString stringWithString:NSLocalizedString(@"TEXT-3-WHICH", @"MAIN WINDOW -RESULTS: Which is")] retain];
        loc_string_9 = [[NSString stringWithString:NSLocalizedString(@"TEXT-4-EXCLAMATION", @"MAIN WINDOW -RESULTS: Exclamation mark")] retain];
        loc_string_10 = [[NSString stringWithString:NSLocalizedString(@"TEXT-5-COMMA", @"MAIN WINDOW -RESULTS: Comma")] retain];
        loc_string_11 = [[NSString stringWithString:NSLocalizedString(@"TEXT-DAY-SINGULAR", @"MAIN WINDOW -RESULTS: Day")] retain];
        loc_string_12 = [[NSString stringWithString:NSLocalizedString(@"TEXT-MONTH-SINGULAR", @"MAIN WINDOW -RESULTS: Month")] retain];
        loc_string_13 = [[NSString stringWithString:NSLocalizedString(@"TEXT-YEAR-SINGULAR", @"MAIN WINDOW -RESULTS: Year")] retain];
        loc_string_14 = [[NSString stringWithString:NSLocalizedString(@"CONGRATS-1", @"MAIN WINDOW -RESULTS: Birthday wishes")] retain];
        loc_string_15 = [[NSString stringWithString:NSLocalizedString(@"CONGRATS-2", @"MAIN WINDOW -RESULTS: Welcome message")] retain];
        loc_string_16 = [[NSString stringWithString:NSLocalizedString(@"BANNER-2", @"MAIN WINDOW -RESULTS: Banner Displayed for calculation results")] retain];
        
        loc_string_17 = [[NSString stringWithString:NSLocalizedString(@"TAB-BAR-1", @"TAB BAR (BOTTOM OF SCREEN): Title for the Cleantime Tab Bar Item")] retain];

        //Get the tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        
        //Give instance tbi a label
        [tbi setTitle:loc_string_17];
        
        //Create an instance of UIImage from a png file
        UIImage *i = [UIImage imageNamed:@"Time.png"];
        
        //Place that instance on the tab bar
        [tbi setImage:i];
        [self clearCleanCalc];
        }
    return self;
}

/**
 \brief Initializes the calculator view with the nib file (short-circuits any other attempts to do it otherwise).
 
 \returns the self object.
*/
-(id)initWithNibName:(NSString *)nibName
              bundle:(NSBundle *)bundle
{
    return [self init];
}

/**
 \brief We wait until the view has been loaded to set up the dynamic scroller for results.
 */
- (void)viewDidLoad
{
    [headerLabel setText:loc_string_1]; // Make sure the header test says what we want.
    [cleanDateButton setTitle:loc_string_2 forState:UIControlStateNormal];  // Same for the main button.
    
    // We are going to calculate the bounds, so the scroller is as wide as the window, reaches to the bottom of the screen, and starts just below the congratulations label.
    CGRect calcBounds = [calcView frame];
    CGRect labelFrame = [congratulationsLabel frame];
    int top = labelFrame.origin.y + labelFrame.size.height;
    calcBounds.origin.y = top;
    
    calcBounds.size.height -= top;
    
    // Set up the scroller. We control the scroller allocation from here, as it's a direct descendant of one of our views.
    resultsScrollerView = [[KeytagScroller alloc] initWithFrame:calcBounds];  // Create and set up the scroller.
    [resultsScrollerView setAutoresizesSubviews:YES];
    [resultsScrollerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [resultsScrollerView setContentSize:calcBounds.size];
    [resultsScrollerView setShowsVerticalScrollIndicator:YES];
    [resultsScrollerView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [calcView addSubview:resultsScrollerView];  // We place this into our container.
    
    // Hand off control of the scroller to our key tag controller
    keyTagController = [[[KeytagScrollerViewController alloc] initWithView:resultsScrollerView] retain];
    [keyTagController setSettingsPtr:mySettings];
    
    // This displays a shadow across the top of the keytag view, giving the appearance of a "drawer."
    shadowView = [[[UIView alloc] init] retain];
    [shadowView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [shadowView setBounds:CGRectMake(0.0, 0.0, calcBounds.size.width, 20)];
    [shadowView setFrame:CGRectMake(0.0, calcBounds.origin.y, calcBounds.size.width, 20)];
    [shadowView setHidden:YES];
    [shadowView setUserInteractionEnabled:NO];
    [self setShadow];
    [calcView addSubview:shadowView];
    [congratulationsLabel setText:@""]; // Clear the congratulations label.
    [resultsTextView setText:@""];  // Same with the result text.
    
    [self setBeanieBackground];
}

/**
 \brief Accessor -just so we can keep track of where we've been.
 */
- (void)setSettingsController:(UIViewController *)inController
{
    settingsController = (SettingsTableViewController *)inController;
}

/**
 \brief Point to the tab bar controller
 */
- (void)setTabBarController:(UITabBarController *)in_controller
{
    myTabBarController = in_controller;
}

/**
 \brief Point to the tab bar controller
 */
- (void)setCleaDatePickerController:(SelectCleanDateViewController *)in_controller
{
    cleandatePickerController = in_controller;
}

#pragma mark - Deallocation and unloading

/**
 \brief Called when deallocating the view.
*/
- (void)dealloc
{
    [keyTagController release];
    [shadowView release];
    [resultsScrollerView release];
    [settingsController release];
    
    [cleanDateButton release];
    [resultsTextView release];
    [calcView release];
    [headerLabel release];
    [congratulationsLabel release];

    [self clearCleanCalc];
    [clearButton release];
    
    [loc_string_1 release];
    [loc_string_2 release];
    [loc_string_3 release];
    [loc_string_4 release];
    [loc_string_5 release];
    [loc_string_6 release];
    [loc_string_7 release];
    [loc_string_8 release];
    [loc_string_9 release];
    [loc_string_10 release];
    [loc_string_11 release];
    [loc_string_12 release];
    [loc_string_13 release];
    [loc_string_14 release];
    [loc_string_15 release];
    [loc_string_16 release];
    [loc_string_17 release];
    [loc_string_18 release];

    [super dealloc];
}

/**
 \brief FIRE SALE: EVERYTHING MUST GO!
 */
- (void)viewDidUnload
{
    [self stopAccel];
    [clearButton release];
    clearButton = nil;
    [super viewDidUnload];
}

#pragma mark - NIB actions
/**
 \brief Clears the results, and leaves the app in its initial state.
 */
- (IBAction)clearResults:(id)sender
{
    [self clearCleanCalc];
    [headerLabel setText:loc_string_1]; // Make sure the header test is reset.
    [keyTagController reset];   // Clear the tags.
    [shadowView setHidden:YES]; // Hide the shadow
    [cleanDateButton setTitle:loc_string_2 forState:UIControlStateNormal];  // Reset the main button text.
    [congratulationsLabel setText:@""]; // Clear the congratulations label.
    [resultsTextView setText:@""];  // Same with the result text.
    [clearButton setHidden:YES];
    if ( !mySettings->saveCleantime )
        {
        [mySettings->cleanDate release];
        mySettings->cleanDate = [[NSDate date] retain];
        }
    [self stopAccel];
}

#pragma mark - Orientation

/**
 \brief iPad can rotate everywhere, iPhone, no upside-down.
 
 \returns a boolean. YES, if the orientation is supported.
*/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io   ///< Interface orientation
{
    BOOL    ret = ((io == UIInterfaceOrientationPortrait) || (io == UIInterfaceOrientationLandscapeLeft) || (io == UIInterfaceOrientationLandscapeRight));
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
        ret = YES;
        }
    
    // We also make the basic text centered, if we're wide.
    if (ret && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad || (io == UIInterfaceOrientationLandscapeLeft) || (io == UIInterfaceOrientationLandscapeRight)))
        {
        [resultsTextView setTextAlignment:UITextAlignmentCenter];
        }
    else
        {
        if ( ret )
            {
            [resultsTextView setTextAlignment:UITextAlignmentLeft];
            }
        }
    return ret;
}

#pragma mark - Custom Code

/************************************************************************//**
*                                 CUSTOM STUFF                              *
****************************************************************************/

#pragma mark - Direct View actions
/**
 \brief This is called to handle the user tapping the "Enter Clean Date" button.
        It will put up a UIDatePicker to allow the user to select a cleandate.
        Once the user has selected a cleandate, the date is reflected in the
        button text (ex: "Enter Your Clean Date" is replaced with "March 10, 2010".
        This also triggers the calculation and display of results.
        The date picker will be displayed in the results view, replacing any previous
        results.
 */
- (IBAction)enterCleanDate:(id)sender   ///< The button object
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
        datePickerPopover = [[UIPopoverController alloc] initWithContentViewController:cleandatePickerController];
        
        [datePickerPopover setDelegate:self];
        
        CGRect  displayRect = [cleanDateButton frame];
        displayRect.origin.y += displayRect.size.height;
        [datePickerPopover presentPopoverFromRect:displayRect
                                           inView:[self view]
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
        }
    else
        {
        [self presentModalViewController:cleandatePickerController animated:YES];
        }
}

#pragma mark - Calculations

/**
 \brief This just makes sure the cleandate result structure is completely initialized.
 */
- (void)clearCleanCalc
{
    clean_calc.totalDays = 0;
    clean_calc.days = 0;
    clean_calc.months = 0;
    clean_calc.years = 0;
    clean_calc.birthday = NO;
    clean_calc.keyTagsSpread = NO;
    clean_calc.whiteTag = NO;
    clean_calc.orangeTag = NO;
    clean_calc.greenTag = NO;
    clean_calc.redTag = NO;
    clean_calc.blueTag = NO;
    clean_calc.yellowTag = NO;
    clean_calc.glowTag = NO;
    clean_calc.greyTag = NO;
    clean_calc.blackTag = 0;
    clean_calc.graniteTag = NO;
    clean_calc.purpleTag = NO;
    
    dateCalculated = NO;
}
    
/**
 \brief This function will determine the interval between now and the cleandate, and will trigger the display of the results.
 
 \returns a NACC_Calc_Result struct, which contains the result of the calculation.
 */
- (void)calculateCleandate:(NSDate *)cleanDate
{
    [self clearCleanCalc];
    [shadowView setHidden:NO];
    
    NSDate  *calcDate = [NSDate date];
    
    NSCalendar  *myCalendar = [[NSCalendar currentCalendar] copy];
    
    // If we have any kind of Farsi localization, we use the Persian Solar Calendar
    if ( ([[[NSLocale currentLocale] localeIdentifier] substringToIndex:1] == @"fa") )
        {
        myCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSPersianCalendar];
        }
    
    // We get the total days, just to check for 90 or less.
    clean_calc.totalDays = trunc([calcDate timeIntervalSinceDate:cleanDate] / 86400.0);
    // This will give us the elapsed days, months and years.
    NSDateComponents    *comps = [myCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                               fromDate:cleanDate 
                                                 toDate:calcDate
                                                    options:0];

    if ( comps )
        {
        // Save the date calculation response.
        clean_calc.days = [comps day];
        clean_calc.months = [comps month];
        clean_calc.years = [comps year];
        
        // See if we have an NA birthday (1 day, 30, 60 or 90 days, 6 or 9 months, 1 year, 18 months, 2 years (or more).
        clean_calc.birthday =   (clean_calc.totalDays == 1)
                            ||  (clean_calc.totalDays == 30)
                            ||  (clean_calc.totalDays == 60)
                            ||  (clean_calc.totalDays == 90)
                            ||  ((clean_calc.years == 0) && (clean_calc.months == 6) && (clean_calc.days == 0))
                            ||  ((clean_calc.years == 0) && (clean_calc.months == 9) && (clean_calc.days == 0))
                            ||  ((clean_calc.years == 1) && (clean_calc.months == 0) && (clean_calc.days == 0))
                            ||  ((clean_calc.years == 1) && (clean_calc.months == 6) && (clean_calc.days == 0))
                            ||  ((clean_calc.years > 1) && (clean_calc.months == 0) && (clean_calc.days == 0));
        
        // Determine which tags will be displayed.
        clean_calc.whiteTag = YES;
        clean_calc.orangeTag = 29 < clean_calc.totalDays;
        clean_calc.greenTag = 59 < clean_calc.totalDays;
        clean_calc.redTag = 89 < clean_calc.totalDays;
        clean_calc.blueTag = (6 <= clean_calc.months) || (1 <= clean_calc.years);
        clean_calc.yellowTag = (9 <= clean_calc.months) || (1 <= clean_calc.years);
        clean_calc.glowTag = (1 <= clean_calc.years);
        clean_calc.greyTag = ((1 <= clean_calc.years) && (6 <= clean_calc.months)) || (2 <= clean_calc.years);
        clean_calc.blackTag = (2 <= clean_calc.years) ? clean_calc.years - 1 : 0;   // We display multiple black tags
        clean_calc.graniteTag = (10 <= clean_calc.years);
        clean_calc.purpleTag = (20 <= clean_calc.years);
        dateCalculated = YES;
        }
    
    [myCalendar release];
}

/**
 \brief Calculate the cleantime, and display the results.
 */
- (void)closeDatePicker
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
        [datePickerPopover dismissPopoverAnimated:YES];
        [datePickerPopover autorelease];
        datePickerPopover = nil;
        }
    else
        {
        [self dismissModalViewControllerAnimated:YES];
        }
}

/**
 \brief Calculate the cleantime, and display the results.
 */
- (void)calcAndDisplay
{
    [self dismissModalViewControllerAnimated:YES];
    [self stopAccel];
    [self calculateCleandate:mySettings->cleanDate];
    [self displayCleandate];
    [keyTagController displayKeytags:clean_calc];
    if ( mySettings->rollingScroller )  // If we are doing "gravity scrolling," we don't allow hand-scrolling.
        {
        [resultsScrollerView setUserInteractionEnabled:NO];
        [self setupAccel];
        }
    else
        {
        [resultsScrollerView setUserInteractionEnabled:YES];
        }
    
    [clearButton setHidden:NO];
    [headerLabel setText:loc_string_16];    // The header now says that this is your clean date.
}

#pragma mark - Displays

/**
 \brief This simply replaces the button title with the cleandate.
 */
- (void)displayCleanDateInButton
{
    // We will simply display the date, and no time.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [cleanDateButton setTitle:[dateFormatter stringFromDate:mySettings->cleanDate] forState:UIControlStateNormal];
    [dateFormatter release];
}

/**
 \brief Given the decimated interval, we actually build the string to be displayed.
*/
- (void)displayCleandate
{
    NSMutableString     *resultsString = [[NSMutableString alloc] initWithString:loc_string_3];   ///< This will hold the calculation tabulation results.
    
    if ( resultsString )
        {
        if ( clean_calc.totalDays > 1 )   // 90 days or less, we only count days.
            {
            [resultsString appendFormat:@" %d %@", clean_calc.totalDays, loc_string_5];
            
            if ( clean_calc.totalDays > 90 )   // 90 days or less, we only count days.
                {
                [resultsString appendFormat:@", %@", loc_string_8];
                
                // The logic here will seem a bit convoluted. The reason is that we are building a string. We'll see how it localizes...
                if ( clean_calc.years )
                    {
                    if ( clean_calc.years > 1 )   // We look for singular
                        {
                        [resultsString appendFormat:@" %d %@", clean_calc.years, loc_string_7];
                        }
                    else    
                        {
                        [resultsString appendFormat:@" %d %@", clean_calc.years, loc_string_13];
                        }
                    
                    if ( (clean_calc.days && !clean_calc.months) || (!clean_calc.days && clean_calc.months) )
                        {
                        [resultsString appendFormat:@" %@", loc_string_4];
                        }
                    else
                        {
                        if ( clean_calc.days && clean_calc.months )
                            {
                            [resultsString appendFormat:@"%@", loc_string_10];
                            }
                        }
                    }
                
                if ( clean_calc.months )
                    {
                    if ( clean_calc.months > 1 )   // We look for singular
                        {
                        [resultsString appendFormat:@" %d %@", clean_calc.months, loc_string_6];
                        }
                    else    
                        {
                        [resultsString appendFormat:@" %d %@", clean_calc.months, loc_string_12];
                        }
                    
                    if ( clean_calc.days )
                        {
                        [resultsString appendFormat:@" %@", loc_string_4];
                        }
                    }
                
                if ( clean_calc.days )
                    {
                    if ( clean_calc.days > 1 )   // We look for singular
                        {
                        [resultsString appendFormat:@" %d %@", clean_calc.days, loc_string_5];
                        }
                    else    
                        {
                        [resultsString appendFormat:@" %d %@", clean_calc.days, loc_string_11];
                        }
                    }
                }
            }
        else
            {
            if ( clean_calc.totalDays > 0 )
                {
                [resultsString appendFormat:@" %d %@", clean_calc.totalDays, loc_string_11];
                }
            else    // 0 days gets no string (welcome only).
                {
                [resultsString setString:@""];
                }
            }
        
        if ( clean_calc.totalDays > 0 )
            {
            [resultsString appendString:loc_string_9];
            }
        
        [resultsTextView setText:resultsString];
        [self displayCleanDateInButton];
        
        // See if congratulations are in order.
        if ( clean_calc.birthday )
            {
            [congratulationsLabel setText:loc_string_14];
            }
        else    // Welcome newcomers.
            {
            if ( clean_calc.totalDays == 0 )
                {
                [congratulationsLabel setText:loc_string_15];
                }
            else
                {
                [congratulationsLabel setText:@""];
                }
            }
        [resultsString release];
        }
}

/**
 \brief This uses a i-pixel-wide file to display a shadow across the scroll area. It is done in a CALayer.
 */
- (void)setShadow
{
    [[shadowView layer] setContentsGravity:kCAGravityResize];  // Stretch the image.
    [[shadowView layer] setBackgroundColor:[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    
    UIImage *layerImage = [UIImage imageNamed:@"Shadow.png"];
    CGImageRef image = [layerImage CGImage];
    
    [[shadowView layer] setContents:(id)image];
}

/**
 \brief This applies the "Beanie Background" to the results view.
 */
- (void)setBeanieBackground
{
    [[[self view] layer] setContentsGravity:kCAGravityResizeAspectFill];
    [[[self view] layer] setBackgroundColor:[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    
    UIImage *layerImage = [UIImage imageNamed:@"BlueBeanie.png"];
    CGImageRef image = [layerImage CGImage];
    
    [[[self view] layer] setContents:(id)image];
}

/**
 \brief Return true if we have a calculated cleantime.
 
 \returns a BOOL. YES if we have calculated a cleantime.
 */
- (BOOL)isDateCalculated
{
    return dateCalculated;
}

/**
 \brief get the popver (NOTE: This may be nil)
 
 \returns a pointer to an instance of UIPopoverController. It may be nil if there is no popover.
 */
- (UIPopoverController *)getDatePickerPopover
{
    return datePickerPopover;
}

#pragma mark - UIAccelerometerDelegate code
/**
 \brief We can have the tags scroll, in response to leaning the device. Catch the accelerometer here.
 */
- (void)accelerometer:(UIAccelerometer *)meter
        didAccelerate:(UIAcceleration *)accel
{
    [self readAccel:accel];
}

/**
 \brief The way this works, is that we measure the angle of the Y-axis (pitch) of the device.
        If it is leaning forward, we'll make the keytags roll that way, and vice-versa for backward.
        We use a rolling average of _AVG_COUNT samples, collected at 100Hz (fast). This allows us to have a
        smooth, yet responsive reaction to the device being moved.
        The scrolling is "weighted." The steeper the angle, the stronger the scroll.
        The average is held in a circular buffer. We don't care about which value is the newest.
 */
- (void)setupAccel
{
    if ( mySettings->rollingScroller )  // We only do this if the prefs call for it.
        {
        // Set up the accelerometer.
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.01];
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
        average_count = 0;  // Setting this to 0 is all you need to do to initialize things.
        }
    else
        {
        [[UIAccelerometer sharedAccelerometer] setDelegate:nil];    // Make sure the accelerometer is off.
        }
}

/**
 \brief We read and react to the pitch here. We use degrees for convenience.
        90° is stationary, >90° is pitched forward, and <90° is pitched backward.
 */
- (void)readAccel:(UIAcceleration *)accel
{
    double  x = accel.x;
    double  y = accel.y;
    double  z = accel.z;
    
    UIDeviceOrientation io = [[UIDevice currentDevice] orientation];
    
    double  axis = UIInterfaceOrientationIsLandscape(io) ? x : y;   // y In portait or upside-down, x, otherwise.
    
    double  angleYaxis = (acos (axis / sqrt ( x*x + y*y + z*z )) * 180.0) / M_PI;
    
    // We add the angle of the tilt to our average pool. This is a circular buffer, so we go back to the beginning when we reach the end.
    if ( average_slot == _AVG_COUNT )
        {
        average_slot = 0;
        }
    
    // This also means that we overwrite old values with new ones.
    accelavg[average_slot++] = angleYaxis;
    
    // If we have amassed enough for a full average, we then see about scrolling the view.
    if ( average_count == _AVG_COUNT )
        {
        // In order to give a consistent scroll speed, regardless of the number of tags, we use the height of the scroll contents.
        // This means that 1 tag scrolls as slowly as 20, or 20 tags scroll as quickly as 10.
        double   scrollerSizeHeight = [keyTagController getScrollContentSize].height;
        
        // This is a fairly arbitrary number, but 1/20 increments seems to do it.
        double  addTo = round ([self getAccelAvg] * (scrollerSizeHeight / 20));
        
        if ( abs(addTo) > 2 )   // This allows us to "stick" at a fairly horizontal plane.
            {
            // It's a very linear operation. The greater the angle, the bigger the scroll jump. This speeds up the scroll at steeper inclines.
            // We also can't go beyond the top or the bottom of the scroll view.
            double  scrollLoc = MIN ( scrollerSizeHeight, MAX ( 0.0, ([resultsScrollerView contentOffset].y + addTo) ) );
            
            // It's important not to animate this. If you animate, it looks like crap.
            [resultsScrollerView setContentOffset:CGPointMake(0.0, scrollLoc) animated:NO];
            }
        }
    else    // If we're not full yet, we simply add another angle to the average pool.
        {
        average_count = MIN(++average_count, _AVG_COUNT);   // Can't go beyond the number of slots available.
        }
}

/**
 \brief Average the buffer.
 \returns a double. It is a fraction that goes from -1.0 (fully leaning backward) to 1.0 (fully leaning forward).
 */
- (double)getAccelAvg
{
    double ret = -1;
    
    if ( average_count == _AVG_COUNT )
        {
        for ( int c = 0; c < _AVG_COUNT; c++ )
            {
            ret += accelavg[c];
            }
        
        ret = (((ret / _AVG_COUNT) -90) / 180);
        }
    
    return ret;
}

/**
 \brief Stop measuring the accelerometer.
 */
- (void)stopAccel
{
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

@end
