//
//  SettingsViewController.m
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
 
 \brief This file contains two classes that encompass the display, maintenance and persistent storage of the app preferences.
 
 The prefs window has a simple set of switches that allows the user to select a few preferences.
 
 These are stored in an extremely simple class, called "SettingsClass," which also acts as a single point of reference.
 
 All other parts of the app check this instance for the state of the preferences, and the SettingsViewController will
 present and control a page that allows the user to see and change the state of these preferences.
 
 The one preference that will be changed by the Cleantime display is the actual cleandate, which is stored with the prefs.
 If the user chooses not to save it, then it is always changed to today. Otherwise, it is completely persistent.
 */

#import "SettingsTableViewController.h"

/**
 This class is an NSCoder class, which is how the persistent data is stored.
 */
#pragma mark - SettingsClass Class Implementation

@implementation SettingsClass : NSObject

/**
 \brief Get a pointer to this instance's settings.
 */
- (NACC_SettingsPtr)getSettings
{
    return &mySettings;
}

/**
 \brief Raw initializer -seldom called.
 */
- (id)init
{
    self = [super init];
    if ( self )
        {
        // These are the very "rawest" settings.
        mySettings.displayGranite = YES;
        mySettings.displayPurple = YES;
        mySettings.purpleEveryTenYears = NO;
        mySettings.saveCleantime = NO;
        mySettings.limitDates = YES;
        mySettings.rollingScroller = NO;
        mySettings.cleanDate = [[NSDate date] retain];
        }
    return self;
}

/**
 \brief This sets a new clean time date, and releases the old one. The cleantime date is copied and retained.
 */
- (void)setCleanTime:(NSDate *)inDate
{
    if ( mySettings.cleanDate )
        {
        [mySettings.cleanDate release];
        }
    
    mySettings.cleanDate = [[inDate copy] retain];
}

/**
 \brief We need to release the cleantime date.
 */
- (void)dealloc
{
    [mySettings.cleanDate release];
    [super dealloc];
}

/**
 \brief Save the settings.
 */
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBool:mySettings.displayGranite forKey:@"displayGranite"];
    [encoder encodeBool:mySettings.displayPurple forKey:@"displayPurple"];
    [encoder encodeBool:mySettings.purpleEveryTenYears forKey:@"purpleEveryTenYears"];
    [encoder encodeBool:mySettings.saveCleantime forKey:@"saveCleantime"];
    [encoder encodeBool:mySettings.limitDates forKey:@"limitDates"];
    [encoder encodeObject:mySettings.cleanDate forKey:@"CleanDate"];
    [encoder encodeBool:mySettings.rollingScroller forKey:@"rollingScroller"];
}

/**
 \brief Initialize with saved settings.
 */
-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if ( self && decoder )
        {
        mySettings.displayGranite = [decoder decodeBoolForKey:@"displayGranite"];
        mySettings.displayPurple = [decoder decodeBoolForKey:@"displayPurple"];
        mySettings.purpleEveryTenYears = [decoder decodeBoolForKey:@"purpleEveryTenYears"];
        mySettings.saveCleantime = [decoder decodeBoolForKey:@"saveCleantime"];
        
        // These are later prefs, so we test for them, first.
        if ( [decoder containsValueForKey:@"limitDates"] )
            {
            mySettings.limitDates = [decoder decodeBoolForKey:@"limitDates"];
            }
        else
            {
            mySettings.limitDates = YES;
            }
        
        if ( [decoder containsValueForKey:@"rollingScroller"] )
            {
            mySettings.rollingScroller = [decoder decodeBoolForKey:@"rollingScroller"];
            }
        else
            {
            mySettings.rollingScroller = NO;
            }
        
        // This is special, because it's an allocated and retained object.
        if ( [decoder containsValueForKey:@"CleanDate"] )
            {
            mySettings.cleanDate = [[decoder decodeObjectForKey:@"CleanDate"] retain];
            }
        else
            {
            mySettings.cleanDate = [[NSDate date] retain];
            }
        
        if ( !mySettings.saveCleantime )
            {
            [mySettings.cleanDate release];
            mySettings.cleanDate = [[NSDate date] retain];
            }
        }

    return self;
}

@end

#pragma mark - SettingsTableViewController Class Implementation

/**
 \brief This class controls the settings page.
 */
@implementation SettingsTableViewController

#pragma mark - UITabBarDelegate code
/**
 \brief All this does, is see if the settings page has been invoked, and sets a flag, if so.
 */
- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController
{
    [UIView transitionFromView:[self view]
                        toView:[viewController view]
                      duration:0.2
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:nil];
    return YES;
}

#pragma mark - Nib code
/**
 \brief React to the switch or the label being clicked. Label clicks result in a value toggle.
 */
- (IBAction)displayGraniteChanged:(id)sender
{
    // The reason for this bit of whackiness, is because the labels are actually buttons, so clicking on a label
    // will actuate the switch. We see if the sender is the switch. If so, we don't do anything. However, if it's the
    // label, we reverse the switch.
    if ( sender != displayGraniteSwitch )
        {
        [displayGraniteSwitch setOn:![displayGraniteSwitch isOn] animated:YES];
        }
    [mySettings getSettings]->displayGranite = [displayGraniteSwitch isOn];
    [self saveChanges];
}

/**
 \brief React to the switch or the label being clicked. Label clicks result in a value toggle.
 */
- (IBAction)displayPurpleChanged:(id)sender
{
    if ( sender != displayPurpleSwitch )
        {
        [displayPurpleSwitch setOn:![displayPurpleSwitch isOn] animated:YES];
        }
    [mySettings getSettings]->displayPurple = [displayPurpleSwitch isOn];
    [self saveChanges];
}

/**
 \brief React to the switch or the label being clicked. Label clicks result in a value toggle.
 */
- (IBAction)purpleEveryTenYearsChanged:(id)sender
{
    if ( sender != purpleEveryTenYearsSwitch )
        {
        [purpleEveryTenYearsSwitch setOn:![purpleEveryTenYearsSwitch isOn] animated:YES];
        }
    [mySettings getSettings]->purpleEveryTenYears = [purpleEveryTenYearsSwitch isOn];
    [self saveChanges];
}

/**
 \brief React to the switch or the label being clicked. Label clicks result in a value toggle.
 */
- (IBAction)saveCleantimeChanged:(id)sender
{
    if ( sender != saveCleantimeSwitch )
        {
        [saveCleantimeSwitch setOn:![saveCleantimeSwitch isOn] animated:YES];
        }
    [mySettings getSettings]->saveCleantime = [saveCleantimeSwitch isOn];
    [self saveChanges];
}

/**
 \brief React to the switch or the label being clicked. Label clicks result in a value toggle.
 */
- (IBAction)limitDatesChanged:(id)sender
{
    if ( sender != limitDatesSwitch )
        {
        [limitDatesSwitch setOn:![limitDatesSwitch isOn] animated:YES];
        }
    [mySettings getSettings]->limitDates = [limitDatesSwitch isOn];
    [self saveChanges];
}

/**
 \brief React to the switch or the label being clicked. Label clicks result in a value toggle.
 */
- (IBAction)rollingScrollerChanged:(id)sender
{
    if ( sender != rollingScrollerSwitch )
        {
        [rollingScrollerSwitch setOn:![rollingScrollerSwitch isOn] animated:YES];
        }
    [mySettings getSettings]->rollingScroller = [rollingScrollerSwitch isOn];
    [self saveChanges];
}

#pragma mark standard code

/**
 \brief Standard-issue init.
 */
- (id)init
{
    self = [super init];
    
    if (self)
        {
        [self getData];
        
        // We initialize all the local strings. These will be replaced with the correct ones at runtime.
        loc_settings_string_1 = [[NSString stringWithString:NSLocalizedString(@"TAB-BAR-2", @"TAB BAR (BOTTOM OF SCREEN): Title for the Settings Tab Bar Item")] retain];
        
        loc_settings_string_2 = [[NSString stringWithString:NSLocalizedString(@"SETTINGS-LABEL-1", @"SETTINGS: Label for the granite tag setting")] retain];
        loc_settings_string_3 = [[NSString stringWithString:NSLocalizedString(@"SETTINGS-LABEL-2", @"SETTINGS: Label for the purple tag setting")] retain];
        loc_settings_string_4 = [[NSString stringWithString:NSLocalizedString(@"SETTINGS-LABEL-3", @"SETTINGS: Label for the every ten years setting")] retain];
        loc_settings_string_5 = [[NSString stringWithString:NSLocalizedString(@"SETTINGS-LABEL-4", @"SETTINGS: Label for the save cleantime setting")] retain];
        loc_settings_string_6 = [[NSString stringWithString:NSLocalizedString(@"SETTINGS-LABEL-5", @"SETTINGS: Label for the Limit Dates Switch")] retain];
        loc_settings_string_8 = [[NSString stringWithString:NSLocalizedString(@"SETTINGS-LABEL-6", @"SETTINGS: Label for the Gravity Scrolling Switch")] retain];
        
        loc_settings_string_7 = [[NSString stringWithString:NSLocalizedString(@"SETTINGS-BANNER-1", @"SETTINGS: Main Heading for the settings page")] retain];
        
        //Get the tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        
        //Give instance tbi a label
        [tbi setTitle:loc_settings_string_1];
        
        //Create an instance of UIImage from a png file
        UIImage *i = [UIImage imageNamed:@"Prefs.png"];
        
        //Place that instance on the tab bar
        [tbi setImage:i];
        }
    
    return self;
}

/**
 \brief Bye now...
 */
- (void)dealloc
{
    [self saveChanges];
    [displayGraniteSwitch release];
    [displayPurpleSwitch release];
    [purpleEveryTenYearsSwitch release];
    [saveCleantimeSwitch release];
    [displayGraniteLabel release];
    [displayPurpleLabel release];
    [displayPurpleEveryTenYearsLabel release];
    [saveCleantimeLabel release];
    [mySettings release];
    [headingLabel release];
    [limitDatesLabel release];
    [limitDatesSwitch release];
    
    [loc_settings_string_1 release];
    [loc_settings_string_2 release];
    [loc_settings_string_3 release];
    [loc_settings_string_4 release];
    [loc_settings_string_5 release];
    [loc_settings_string_6 release];
    [loc_settings_string_7 release];
    [loc_settings_string_8 release];
    
    [rollingScrollerSwitch release];
    [rollingScrollerLabel release];
    [super dealloc];
}

/**
 \brief We set up the localized strings here, because a memory warning may flush everything.
 */
- (void)viewDidLoad
{
    [self setBeanieBackground];
    
    [headingLabel setText:loc_settings_string_7];
    
    [displayGraniteLabel setTitle:loc_settings_string_2 forState:UIControlStateNormal];
    [displayPurpleLabel setTitle:loc_settings_string_3 forState:UIControlStateNormal];
    [displayPurpleEveryTenYearsLabel setTitle:loc_settings_string_4 forState:UIControlStateNormal];
    [saveCleantimeLabel setTitle:loc_settings_string_5 forState:UIControlStateNormal];
    [limitDatesLabel setTitle:loc_settings_string_6 forState:UIControlStateNormal];
    [rollingScrollerLabel setTitle:loc_settings_string_8 forState:UIControlStateNormal];
    
    [displayGraniteSwitch setOn:[mySettings getSettings]->displayGranite];
    [displayPurpleSwitch setOn:[mySettings getSettings]->displayPurple];
    [purpleEveryTenYearsSwitch setOn:[mySettings getSettings]->purpleEveryTenYears];
    [saveCleantimeSwitch setOn:[mySettings getSettings]->saveCleantime];
    [limitDatesSwitch setOn:[mySettings getSettings]->limitDates];
    [rollingScrollerSwitch setOn:[mySettings getSettings]->rollingScroller];
}

/**
 \brief If we're gettin' low, we SCRAM the reactor...
 */
- (void)viewDidUnload
{
    [displayGraniteSwitch release];
    displayGraniteSwitch = nil;
    [displayPurpleSwitch release];
    displayPurpleSwitch = nil;
    [purpleEveryTenYearsSwitch release];
    purpleEveryTenYearsSwitch = nil;
    [saveCleantimeSwitch release];
    saveCleantimeSwitch = nil;
    [displayGraniteLabel release];
    displayGraniteLabel = nil;
    [displayPurpleLabel release];
    displayPurpleLabel = nil;
    [displayPurpleEveryTenYearsLabel release];
    displayPurpleEveryTenYearsLabel = nil;
    [saveCleantimeLabel release];
    saveCleantimeLabel = nil;
    [headingLabel release];
    headingLabel = nil;
    [limitDatesLabel release];
    limitDatesLabel = nil;
    [limitDatesSwitch release];
    limitDatesSwitch = nil;
    [rollingScrollerSwitch release];
    rollingScrollerSwitch = nil;
    [rollingScrollerLabel release];
    rollingScrollerLabel = nil;
    [super viewDidUnload];
}

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

    return ret;
}

#pragma mark Custom code.
/**
 \brief
 */
- (void)setCleanTime:(NSDate *)inDate
{
    [mySettings setCleanTime:inDate];
}

/**
 \brief 
 */
- (NSDate *)getCleanTime
{
    return [mySettings getSettings]->cleanDate;
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

/**
 \brief 
 */
- (NACC_SettingsPtr)getSettings
{
    return [mySettings getSettings];
}

/**
 \brief 
 */
- (NSString *)docPath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"NACC.data"];
}

/**
 \brief 
 */
- (BOOL)saveChanges
{
    return [NSKeyedArchiver archiveRootObject:mySettings toFile:[self docPath]];
}

/**
 \brief 
 */
- (void)getData
{
    if ( mySettings )
        {
        [mySettings release];
        mySettings = nil;
        }
    
    mySettings = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self docPath]] retain];
    
    if ( !mySettings )
        {
        mySettings = [[[SettingsClass alloc] init] retain];
        }
}

@end
