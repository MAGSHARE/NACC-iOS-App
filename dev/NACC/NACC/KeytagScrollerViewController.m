//
//  KeytagScrollerViewController.m
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

#import "KeytagScrollerViewController.h"
#import <QuartzCore/QuartzCore.h>

/**
 This class simply has a data member that can be used to easily track the dynamic keytag view. It takes over the initialized view from the scroller.
 */

@implementation KeytagScroller

@synthesize tagsView;

- (void)dealloc
{
    [tagsView release];
    [super dealloc];
}
@end

/**
 \brief This class controls the display of the key fobs. It will construct a chain of individual KeyTagView objects, and scroll to the bottom when done.
 */

@implementation KeytagScrollerViewController

/**
 \brief Point to the settings in the central location.
 */
- (void)setSettingsPtr:(NACC_SettingsPtr)in_settings
{
    mySettings = in_settings;
}

/**
 \brief This is a custom initializer. It allows us to know about our scroller.
 */
- (id)initWithView:(KeytagScroller *)inView
{
    self = [super init];
    
    if ( self )
        {
        // Create the container view.
        tagsView = [[[UIView alloc] init] retain];
        CGRect  frameRect = [inView bounds];
        [tagsView setAutoresizesSubviews:YES];
        [tagsView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [tagsView setBounds:frameRect];
        [tagsView setFrame:frameRect];
        // Add it to the scroller.
        [inView addSubview:tagsView];
        [self setView:inView];
        [inView setTagsView:tagsView];
        myScroller = inView;    // This is a "convenience." The scroller is actually controlled by the CleanDateController instance.
        }
    
    return self;
}

- (void)dealloc
{
    [self clearTagSubviews];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self clearTagSubviews];
    
    [super viewDidUnload];
}

#pragma mark - Custom Code

/************************************************************************//**
*                                 CUSTOM STUFF                              *
****************************************************************************/

/**
 \brief This displays the spread of tags. If the tags are not spread, then the single tag shown
 will be the last one that the user was to have received, and will be touchable. Touching the
 tag will result in this function being called with spreadout equal to YES. If spreadout is
 equal to YES, then the tags will be displayed in an animated fashion, and touching them will
 cause this function to be called with a spreadout of NO.
 */
- (void)displayKeytags:(struct NACC_Calc_Result)clean_calc
{
    [self clearTagSubviews];

    int tagIndex = 0;   ///< This tracks which tag to show.
    int tagTop = 0;     ///< This tracks the top of the tag.

    if ( clean_calc.whiteTag )
        {
        tagTop = [self displayKeytag:tagIndex tagTop:tagTop];
        }

    tagIndex++;

    if ( clean_calc.orangeTag )
        {
        tagTop = [self displayKeytag:tagIndex tagTop:tagTop];
        }

    tagIndex++;

    if ( clean_calc.greenTag )
        {
        tagTop = [self displayKeytag:tagIndex tagTop:tagTop];
        }

    tagIndex++;

    if ( clean_calc.redTag )
        {
        tagTop = [self displayKeytag:tagIndex tagTop:tagTop];
        }

    tagIndex++;

    if ( clean_calc.blueTag )
        {
        tagTop = [self displayKeytag:tagIndex tagTop:tagTop];
        }

    tagIndex++;

    if ( clean_calc.yellowTag )
        {
        tagTop = [self displayKeytag:tagIndex tagTop:tagTop];
        }

    tagIndex++;

    if ( clean_calc.glowTag )
        {
        tagTop = [self displayKeytag:tagIndex tagTop:tagTop];
        }

    tagIndex++;

    if ( clean_calc.greyTag )
        {
        tagTop = [self displayKeytag:tagIndex tagTop:tagTop];
        }

    tagIndex++;

    if ( clean_calc.blackTag )  // Years can be multiple.
        {
        for ( int index = 0; index < clean_calc.blackTag; index++ )
            {
            if ( (index == 8) && mySettings->displayGranite )  // If we are showing a decade tag, we show that, instead of the black.
                {
                tagTop = [self displayKeytag:tagIndex + 1 tagTop:tagTop];
                }
            else
                {
                if ( (index > 17) && !((index + 2) % 10) && mySettings->displayPurple && ((index < 19) || (mySettings->purpleEveryTenYears)) )  // Purple tag does the same as the decade tag, but a bit later.
                    {
                    tagTop = [self displayKeytag:tagIndex + 2 tagTop:tagTop];
                    }
                else
                    {
                    tagTop = [self displayKeytag:tagIndex tagTop:tagTop];
                    }
                }
            }
        }
    
    // This is where we make sure that the scroller and the scrolled know how big they need to be.
    KeyFobImageInfoPtr  myInfo = [KeyTagView imageFileInfo];
    
    BOOL isLarge = [[UIScreen mainScreen] bounds].size.width > myInfo->size_switch_threshold;
    
    int tagBottom = tagTop + (isLarge ? myInfo->large_size_total.height : myInfo->small_size_total.height) - (isLarge ? myInfo->offset_large_overlap : myInfo->offset_small_overlap);

    CGRect  tagsBounds = CGRectMake(0.0,
                                    0.0,
                                    [myScroller frame].size.width,
                                    tagBottom);
    
    [tagsView setBounds:tagsBounds];
    [tagsView setFrame:tagsBounds];
    [myScroller setContentSize:tagsBounds.size];
    [self setBeanieBackground];
    [tagsView setNeedsDisplay];
}

/**
 \brief This displays one single keytag, and extends the scroller view to encompass it.
 
 \returns an int. A new value for tagTop, so the next one will be shown lower.
*/
- (int)displayKeytag:(int)tagIndex
               tagTop:(int)tagTop
{
    KeyTagView  *keyFobView = [[KeyTagView alloc] initWithTagIndex:tagIndex isClosed:0 == tagTop];
    
    KeyFobImageInfoPtr  myInfo = [KeyTagView imageFileInfo];
    
    int offset = ([keyFobView getIsLarge] ? myInfo->offset_large_overlap : myInfo->offset_small_overlap);
    
    if ( keyFobView )
        {
        [keyFobView buildTag];
        
        CGRect  keytag_bounds = [keyFobView bounds];
        
        // This is where the view will be placed in the container.
        CGPoint top_left = CGPointMake((([myScroller frame].size.width - keytag_bounds.size.width) / 2.0), tagTop );

#ifdef _BOUNDS_DEBUG
        NSLog(@"tag draw: key fob bounds: left: %f, top: %f, width: %f, height: %f",[keyFobView bounds].origin.x, [keyFobView bounds].origin.y, [keyFobView bounds].size.width, [keyFobView bounds].size.height);
        NSLog(@"tag draw: scroller bounds: left: %f, top: %f, width: %f, height: %f",[myScroller bounds].origin.x, [myScroller bounds].origin.y, [myScroller bounds].size.width, [myScroller bounds].size.height);
        NSLog(@"tag draw: scroller frame: left: %f, top: %f, width: %f, height: %f",[myScroller frame].origin.x, [myScroller frame].origin.y, [myScroller frame].size.width, [myScroller frame].size.height);
        NSLog(@"tag draw: scroller contentOffset: x: %f, y: %f", [myScroller contentOffset].x, [myScroller contentOffset].y);
        NSLog(@"tag draw: scroller contentSize: x: %f, y: %f", [myScroller contentSize].width, [myScroller contentSize].height);
        NSLog(@"topLeft: x: %f, y: %f", top_left.x, top_left.y);
#endif
        
        CGRect imageFrame = CGRectMake(top_left.x, top_left.y, keytag_bounds.size.width, keytag_bounds.size.height);
        
        [keyFobView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [keyFobView setFrame:imageFrame];
        [tagsView addSubview:keyFobView];
        [keyFobView release];
        }
    
    return tagTop + offset;
}

/**
 \brief Resets the scroller to "pristine."
 */
- (void)reset
{
    [self clearTagSubviews];
    [[myScroller layer] setContents:nil];
}

/**
 \brief Removes all of the tag subviews from the container.
 */
- (void)clearTagSubviews
{
    NSArray *subViews = [tagsView subviews];
    
    for ( int index = [subViews count]; index-- > 0; )
        {
        UIView  *theView = [subViews objectAtIndex:index];
        
        [theView removeFromSuperview];
        }
    
    CGRect  tagsRect = CGRectMake(0.0, 0.0, [myScroller frame].size.width, 0);
    [tagsView setBounds:tagsRect];
    [tagsView setFrame:tagsRect];
    [myScroller setContentSize:[myScroller frame].size];
}

/**
 \brief This function exists only to give the "auto scroll" after the results are calculated somewhere to go.
 */
- (CGSize)getScrollContentSize
{
    return CGSizeMake([tagsView bounds].size.width, [tagsView bounds].size.height - [myScroller bounds].size.height);
}

/**
 \brief This applies the "Beanie Background" to the results view.
 */
- (void)setBeanieBackground
{
    [[myScroller layer] setContentsGravity:kCAGravityResizeAspectFill];  // Stretch or compress the image.
    [[myScroller layer] setBackgroundColor:[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    
    UIImage *layerImage = [UIImage imageNamed:@"BeanieBack.png"];
    CGImageRef image = [layerImage CGImage];
    
    [[myScroller layer] setContents:(id)image];
}

@end
