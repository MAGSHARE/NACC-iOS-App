//
//  KeyTagViewController.m
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

/**
 \brief This class will control a UIView for one single key fob.
        Key fobs can be "open" or "closed."
        "open" key fobs have a gap in the ring, to allow them to appear in a chain.
        "closed" key fobs have a full ring. The first key fob in a chain will be "closed," and subsequent ones in the chain will be "open."
        The key fobs are assembled from a few files. Large screens get large fobs (the "isLarge" parameter). However, high-res screens (retina)
        get a regular-sized key fob, constructed from high-resolution files.
 */
#import "KeyTagView.h"
#import <QuartzCore/QuartzCore.h>

static  KeyFobImageInfoPtr  s_imageFileInfo = nil;

@implementation KeyTagView


/************************************************************************//**
*                           STATIC SINGLETON DATA                           *
****************************************************************************/
/**
 \brief this function populates a static data variable with the various bits of information we will use to determine the raw materials for drawing tags.
 */
+ (KeyFobImageInfoPtr)imageFileInfo
{
    if (!s_imageFileInfo)
        {
        s_imageFileInfo = (KeyFobImageInfoPtr)malloc(sizeof(struct KeyFobImageInfoStruct));
        
        if ( s_imageFileInfo )
            {
            s_imageFileInfo->image_file_names = [[NSArray alloc] initWithObjects:@"01_White", @"02_Orange", @"03_Green", @"04_Red", @"05_Blue", @"06_Yellow", @"07_Year", @"08_Gray", @"09_Black", @"10_Granite", @"11_Purple", nil];
            s_imageFileInfo->closed_ring_fileName = @"ClosedRing";
            s_imageFileInfo->open_ring_fileName = @"OpenRing";
            s_imageFileInfo->small_suffix = @"_160";
            s_imageFileInfo->large_suffix = @"_320";
            s_imageFileInfo->small_size_fob = CGSizeMake(160.0, 204.0);
            s_imageFileInfo->large_size_fob = CGSizeMake(320.0, 409.0);
            s_imageFileInfo->small_size_ring = CGSizeMake(103.0, 97.0);
            s_imageFileInfo->large_size_ring = CGSizeMake(206.0, 194.0);
            s_imageFileInfo->small_size_total = CGSizeMake(160.0, 288.0);
            s_imageFileInfo->large_size_total = CGSizeMake(320.0, 579.0);
            s_imageFileInfo->small_tag_text = CGSizeMake(160.0, 160.0);
            s_imageFileInfo->large_tag_text = CGSizeMake(320.0, 320.0);
            s_imageFileInfo->offset_small_ring = 13;
            s_imageFileInfo->offset_large_ring = 24;
            s_imageFileInfo->offset_small_overlap = 90;
            s_imageFileInfo->offset_large_overlap = 180;
            s_imageFileInfo->offset_small_tag_text = 123;
            s_imageFileInfo->offset_large_tag_text = 246;
            s_imageFileInfo->size_switch_threshold = 400;
            }
        }
    
    return s_imageFileInfo;
}

/**
 \brief Custom initializer with the tag index (determines which tag), and whether or not the tag is "closed" (no gap at the top).
 */
- (id)initWithTagIndex:(int)index
              isClosed:(BOOL)in_isClosed
{
    self = [self init];
    
    if ( self )
        {
        KeyFobImageInfoPtr  myInfo = [KeyTagView imageFileInfo];
        
        fileName = [myInfo->image_file_names objectAtIndex:index];
        [self setRingClosed:in_isClosed];
        [self setIsLarge:[[UIScreen mainScreen] bounds].size.width > myInfo->size_switch_threshold];
        }
    
    return self;
}

/**
 \brief The standard initializer. Sets some basic data members.
 */
- (id)init
{
    self = [super init];
    
    if ( self )
        {
        fileName = nil;
        isLarge = NO;
        ringClosed = NO;
        }
    
    return self;
}

/**
 \brief We override the setBounds method, in order to force the view to use the size for one tag.
 */
- (void)setBounds:(CGRect)bounds
{
    KeyFobImageInfoPtr  myInfo = [KeyTagView imageFileInfo];
    
    float width = (isLarge ? myInfo->large_size_fob.width : myInfo->small_size_fob.width);
    float height = (isLarge ? myInfo->large_size_fob.height + myInfo->large_size_ring.height - (float)myInfo->offset_large_ring
                            : myInfo->small_size_fob.height + myInfo->small_size_ring.height - (float)myInfo->offset_small_ring);
    
    [super setBounds:CGRectMake(0.0, 0.0, width, height)];
}

- (void)setFileName:(NSString *)in_fileName
{
    fileName = in_fileName;
}

- (NSString *)getFileName
{
    return fileName;
}

- (void)setIsLarge:(BOOL)in_isLarge
{
    isLarge = in_isLarge;
}

- (BOOL)getIsLarge
{
    return isLarge;
}

- (void)setRingClosed:(BOOL)in_ringClosed
{
    ringClosed = in_ringClosed;
}

- (BOOL)getRingClosed
{
    return ringClosed;
}

/************************************************************************//**
*                                 CUSTOM STUFF                              *
****************************************************************************/

/**
 \brief This function constructs the contents of the tag view with CALayers, composed of "parts" from files in the bundle.
        The end result is a transparent view that has an image of one tag (selected by the tagIndex), with a ring that is either "open" or "closed."
 */
- (void)buildTag
{
    if ( fileName )
        {
        // We start by loading our basic data. This is a static SINGLETON.
        KeyFobImageInfoPtr  myInfo = [KeyTagView imageFileInfo];
        
        // Start off empty and transparent.
        [self setBounds:CGRectZero];
        [self setTransform:CGAffineTransformIdentity];
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
        
        // Get the tag display bounds. This will account for screen size and whatnot.
        CGRect  myBounds = [self bounds];
        
        // We start off at the top of the screen.
        float ring_top =    0.0;
        
        // These three lines construct the filename of the ring file, based on the tag/screen size, and the isClosed datamember.
        NSMutableString    *ringFileName = [NSMutableString stringWithString:(ringClosed ? myInfo->closed_ring_fileName : myInfo->open_ring_fileName)];
        [ringFileName appendString:myInfo->large_suffix];   // As of version 2.1, we will always use the large size for the source image, and let the scaler present it the right way.
        [ringFileName appendString:@".png"];
        
        // OK, set it into a layer.
        CALayer *ringBearer = [[CALayer alloc] init];
        [ringBearer setAnchorPoint:CGPointMake(0.0, 0.0)];
        [ringBearer setContentsGravity:kCAGravityResize];   // This makes sure we scale for retina.
        [ringBearer setBackgroundColor:[[UIColor colorWithWhite:0 alpha:0] CGColor]];
        
        // This will be the size of the tag. Remember that a retina display uses the standard size, but always loads a hi-res file.
        CGRect  ringBounds = CGRectMake(    0.0,
                                            0.0,
                                            (isLarge ? myInfo->large_size_ring.width : myInfo->small_size_ring.width),
                                            (isLarge ? myInfo->large_size_ring.height : myInfo->small_size_ring.height));
        
        [ringBearer setBounds:ringBounds];
        
        // This sets the position within the view. The ring is centered.
        [ringBearer setPosition:CGPointMake(((myBounds.size.width - ringBounds.size.width) / 2.0), ring_top)];
        
        // Set the image into the layer.
        UIImage *layerImage = [UIImage imageNamed:ringFileName];
        CGImageRef image = [layerImage CGImage];
        [ringBearer setContents:(id)image];
        
        // Add the layer to the view.
        [[self layer] addSublayer:ringBearer];
        [ringBearer release];   // Let Go and Let God...
        
        // Now, we repeat the process with the tag image. Remember that the tabIndex will select which file to use.
        NSMutableString    *tagFileName = [NSMutableString stringWithString:fileName];
        //        [tagFileName appendString:myInfo->large_suffix];
        [tagFileName appendString:@"_Body.png"];
        
        CALayer *tagYerIt = [[CALayer alloc] init];
        [tagYerIt setAnchorPoint:CGPointMake(0.0, 0.0)];
        [tagYerIt setContentsGravity:kCAGravityResize];
        [tagYerIt setBackgroundColor:[[UIColor colorWithWhite:0 alpha:0] CGColor]];
        
        CGRect  tagBounds = CGRectMake(    0.0,
                                       0.0,
                                       (isLarge ? myInfo->large_size_fob.width : myInfo->small_size_fob.width),
                                       (isLarge ? myInfo->large_size_fob.height : myInfo->small_size_fob.height));
        
        [tagYerIt setBounds:tagBounds];
        
        // We set the top of the tab to a predetermined "overlap," so it appears as if the ring is going through it.
        float keyfob_top = (ringBounds.size.height -  (isLarge ? (float)myInfo->offset_large_ring : (float)myInfo->offset_small_ring));
        
        [tagYerIt setPosition:CGPointMake(((myBounds.size.width - tagBounds.size.width) / 2.0), keyfob_top)];
        
        layerImage = [UIImage imageNamed:tagFileName];
        image = [layerImage CGImage];
        [tagYerIt setContents:(id)image];
        
        [[self layer] addSublayer:tagYerIt];
        [tagYerIt release];
        
        // Now, we repeat the process with the tag text image. Remember that the tabIndex will select which file to use.
        NSMutableString    *tagFaceName = [NSMutableString stringWithString:fileName];
        //        [tagFileName appendString:myInfo->large_suffix];
        [tagFaceName appendString:@"_Face.png"];
        
        CALayer *tagFace = [[CALayer alloc] init];
        [tagFace setAnchorPoint:CGPointMake(0.0, 0.0)];
        [tagFace setContentsGravity:kCAGravityResize];
        [tagFace setBackgroundColor:[[UIColor colorWithWhite:0 alpha:0] CGColor]];
        
        CGRect  tagFaceBounds = CGRectMake(    0.0,
                                       0.0,
                                       (isLarge ? myInfo->large_tag_text.width : myInfo->small_tag_text.width),
                                       (isLarge ? myInfo->large_tag_text.height : myInfo->small_tag_text.height));
        
        [tagFace setBounds:tagFaceBounds];
        
        // We set the top of the tab to a predetermined "overlap," so it appears as if the ring is going through it.
        float tag_face_top = (isLarge ? (float)myInfo->offset_large_tag_text : (float)myInfo->offset_small_tag_text);
        
        [tagFace setPosition:CGPointMake(((myBounds.size.width - tagFaceBounds.size.width) / 2.0), tag_face_top)];
        
        layerImage = [UIImage imageNamed:tagFaceName];
        image = [layerImage CGImage];
        [tagFace setContents:(id)image];
        
        [[self layer] addSublayer:tagFace];
        [tagFace release];
        }
}

@end
