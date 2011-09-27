//
//  Settings.h
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

struct NACC_Settings_Struct
{
    BOOL    displayGranite;
    BOOL    displayPurple;
    BOOL    purpleEveryTenYears;
    BOOL    saveCleantime;
    BOOL    limitDates;
    BOOL    rollingScroller;
    NSDate  *cleanDate;
};

typedef struct NACC_Settings_Struct NACC_Settings;
typedef struct NACC_Settings_Struct *NACC_SettingsPtr;

@protocol SettingsContainer

@required
- (void)setSettingsPtr:(NACC_SettingsPtr)in_settings;

@end