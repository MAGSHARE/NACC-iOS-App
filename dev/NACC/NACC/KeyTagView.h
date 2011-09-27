//
//  KeyTagViewController.h
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

/**
 \brief This struct will be used in a SINGLETON, to hold the basic metrics and raw materials for drawing tags.
 */
struct KeyFobImageInfoStruct
{
    NSArray     *image_file_names;      ///< This is an array of file names. The tag index will choose which filename to use.
    NSString    *closed_ring_fileName;  ///< If the ring is closed, this is the root file name.
    NSString    *open_ring_fileName;    ///< Same for open.
    NSString    *small_suffix;          ///< Small files use this suffix.
    NSString    *large_suffix;          ///< Same for large.
    CGSize      small_size_fob;         ///< The dimensions for a small-sized key fob image.
    CGSize      large_size_fob;         ///< ...and for a large.
    CGSize      small_size_ring;        ///< The same for the ring (both "open" and "closed" are the same size).
    CGSize      large_size_ring;        ///< Large ring.
    CGSize      small_size_total;       ///< This is the total dimension for a tab UIView
    CGSize      large_size_total;       ///< Same for large.
    CGSize      small_tag_text;         ///< The size for the tag text (small)
    CGSize      large_tag_text;         ///< The size for the tag text (large)
    int         offset_small_ring;      ///< This is the overlap for a small key fob over a small ring.
    int         offset_large_ring;      ///< Same for large.
    int         offset_small_overlap;   ///< This is the overlap between two KeyTagView in a chain.
    int         offset_large_overlap;   ///< Same for large.
    int         offset_small_tag_text;  ///< This is the offset from the top for the tag text (small).
    int         offset_large_tag_text;  ///< This is the offset from the top for the tag text (large).
    int         size_switch_threshold;  ///< The screen size width that triggers a switch to isLarge = YES.
};

typedef struct KeyFobImageInfoStruct *KeyFobImageInfoPtr;

@interface KeyTagView : UIView
{
    NSString    *fileName;
    BOOL        isLarge;
    BOOL        ringClosed;
}

+ (KeyFobImageInfoPtr)imageFileInfo;

- (id)initWithTagIndex:(int)index isClosed:(BOOL)in_isClosed;

- (void)setFileName:(NSString *)in_fileName;
- (NSString *)getFileName;

- (void)setIsLarge:(BOOL)in_isLarge;
- (BOOL)getIsLarge;

- (void)setRingClosed:(BOOL)in_ringClosed;
- (BOOL)getRingClosed;

- (void)buildTag;
@end
