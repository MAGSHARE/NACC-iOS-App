//
//  KeytagScrollerViewController.h
//  NACC
//
//  Created by MAGSHARE on 7/21/11.
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
#import "KeyTagView.h"
#import "Settings.h"

/// This is the response struct from the calculation routine.
struct NACC_Calc_Result
{
    int     totalDays;      ///< The total number of days clean.
    int     days;           ///< The number of days in the date calculation.
    int     months;         ///< The number of mnths in the date calculation.
    int     years;          ///< The number of years in the date calculation.
    BOOL    birthday;       ///< YES if this is an anniversary time.
    BOOL    keyTagsSpread;  ///< If YES, the keytags will be displayed in an animated "spread"
    BOOL    showPurpleTag;  ///< If YES, then the purple "decades" tag will be displayed.
    BOOL    showGraniteTag; ///< If YES, then the granite "decade" tag will be shown.
    BOOL    whiteTag;       ///< YES if a white tag should be displayed.
    BOOL    orangeTag;      ///< YES if an orange tag should be displayed.
    BOOL    greenTag;       ///< YES if a green tag should be displayed.
    BOOL    redTag;         ///< YES if a red tag should be displayed.
    BOOL    blueTag;        ///< YES if a blue tag should be displayed.
    BOOL    yellowTag;      ///< YES if a yellow tag should be displayed.
    BOOL    glowTag;        ///< YES if a glow-in-the-dark tag should be displayed.
    BOOL    greyTag;        ///< YES if a grey tag should be displayed.
    int     blackTag;       ///< >=1 if a black tag should be displayed. The number is the number of tags.
    BOOL    graniteTag;     ///< YES if a granite tag should be displayed.
    BOOL    purpleTag;      ///< YES if a purple tag should be displayed.
};

typedef struct NACC_Calc_Result *NACC_Calc_ResultPtr;

/**
 \brief The reason for this class, is simply so that we can easily keep track of the keytag view.
 */
@interface KeytagScroller : UIScrollView
{
    UIView  *tagsView;
}

@property (nonatomic, retain) UIView  *tagsView;

@end

/**
 \brief This class acts as a controller for the display of the keytags.
        It manages the scroller (which is actually owned by the main controller) and lays out the tags.
 */
@interface KeytagScrollerViewController : UIViewController <UIScrollViewDelegate, SettingsContainer>
{
    UIView          *tagsView;
    UIScrollView    *myScroller;
    
    NACC_SettingsPtr    mySettings;     ///< Point to the global settings, maintained by the SettingsTableViewController instance.
}
- (id)initWithView:(UIScrollView *)inView;
- (void)displayKeytags:(struct NACC_Calc_Result)clean_calc;
- (int)displayKeytag:(int)tagIndex tagTop:(int)tagTop;
- (void)reset;
- (void)clearTagSubviews;
- (CGSize)getScrollContentSize;
- (void)setBeanieBackground;

@end
