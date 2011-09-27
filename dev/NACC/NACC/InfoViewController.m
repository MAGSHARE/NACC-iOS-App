//
//  InfoViewController.m
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

#import "InfoViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation InfoViewController

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

/**
 \brief Point to the settings in the central location.
 */
- (void)setSettingsPtr:(NACC_SettingsPtr)in_settings
{
    mySettings = in_settings;
}

- (id)init
{
    self = [super init];
    
    if (self)
        {
        loc_info_string_1 = [[NSString stringWithString:NSLocalizedString(@"TAB-BAR-3", @"TAB BAR (BOTTOM OF SCREEN): Title for the Info Tab Bar Item")] retain];
        
        loc_info_string_2 = [[NSString stringWithString:NSLocalizedString(@"INFO-BANNER-1", @"INFO WINDOW: The main header for the info window")] retain];
        
        loc_info_string_3 = [[NSString stringWithString:NSLocalizedString(@"INFO-BANNER-2", @"INFO WINDOW: The secondary header in the info window.")] retain];
        loc_info_string_4 = [[NSString stringWithString:NSLocalizedString(@"INFO-LABEL-1", @"INFO WINDOW: The label for the version in the info window.")] retain];
        loc_info_string_5 = [[NSString stringWithString:NSLocalizedString(@"INFO-LABEL-2", @"INFO WINDOW: Label for the Source Code Link")] retain];
        loc_info_string_6 = [[NSString stringWithString:NSLocalizedString(@"INFO-SCROLLING-TEXT", @"INFO WINDOW: The Text In The Scrolling Info Area")] retain];
        loc_info_string_7 = [[NSString stringWithString:NSLocalizedString(@"INFO-URI-1", @"INFO WINDOW: The URI for MAGSHARE")] retain];
        loc_info_string_8 = [[NSString stringWithString:NSLocalizedString(@"INFO-URI-2", @"INFO WINDOW: The URI for the GitHub Source")] retain];
        
        //Get the tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        
        //Give instance tbi a label
        [tbi setTitle:loc_info_string_1];
        
        //Create an instance of UIImage from a png file
        UIImage *i = [UIImage imageNamed:@"InfoButton.png"];
        
        //Place that instance on the tab bar
        [tbi setImage:i];
        
        [self clearVisitingMAGSHARE];
        }
    return self;
}

- (void)viewDidLoad
{
    [self setBeanieBackground];
    
    [mainHeader setText:loc_info_string_2];
    [magshareLabel setText:loc_info_string_3];
    [versionLabel setText:loc_info_string_4];
    [gitHubLinkLabel setText:loc_info_string_5];
    [magshareButton setTitle:loc_info_string_7 forState:UIControlStateNormal];
    [gitHubLinkButton setTitle:loc_info_string_8 forState:UIControlStateNormal];
    [textView setText:loc_info_string_6];
    
    [self displayVersion];
}

- (void)dealloc
{
    [mainHeader release];
    [magshareLabel release];
    [versionLabel release];
    [versionValue release];
    [gitHubLinkLabel release];
    [textView release];
    
    [loc_info_string_1 release];
    [loc_info_string_2 release];
    [loc_info_string_3 release];
    [loc_info_string_4 release];
    [loc_info_string_5 release];
    [loc_info_string_6 release];
    [loc_info_string_7 release];
    [loc_info_string_8 release];
    
    [gitHubLinkButton release];
    [magshareButton release];
    [super dealloc];
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
    
    return ret;
}

/**
 \brief Take the user to the source.
 */
- (IBAction)visitURI:(id)sender
{
    visitingMAGSHARE = time(0); // This lets the app know not to reset everything when we come back.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[(UIButton *)sender currentTitle]]];
}

/**
 \brief This applies the "Beanie Background" to the results view.
 */
- (void)setBeanieBackground
{
    [[[self view] layer] setContentsGravity:kCAGravityResizeAspectFill];  // Stretch or compress the image.
    [[[self view] layer] setBackgroundColor:[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    
    UIImage *layerImage = [UIImage imageNamed:@"BeanieBack.png"];
    CGImageRef image = [layerImage CGImage];
    
    [[[self view] layer] setContents:(id)image];
}

- (void)viewDidUnload
{
    [mainHeader release];
    mainHeader = nil;
    [magshareLabel release];
    magshareLabel = nil;
    [versionLabel release];
    versionLabel = nil;
    [versionValue release];
    versionValue = nil;
    [gitHubLinkLabel release];
    gitHubLinkLabel = nil;
    [textView release];
    textView = nil;
    [gitHubLinkButton release];
    gitHubLinkButton = nil;
    [magshareButton release];
    magshareButton = nil;
    [super viewDidUnload];
}

- (time_t)isVisitingMAGSHARE
{
    return visitingMAGSHARE;
}

- (void)clearVisitingMAGSHARE
{
    visitingMAGSHARE = 0;
}

- (void)displayVersion
{
    NSString        *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary    *plistFile = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString        *versionInfo = [plistFile valueForKey:@"CFBundleVersion"];
    [versionValue setText:versionInfo];
}

@end
