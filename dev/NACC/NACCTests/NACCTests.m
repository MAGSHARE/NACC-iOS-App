//
//  NACCTests.m
//  NACCTests
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

#import "NACCTests.h"
#import "KeyTagView.h"


@implementation NACCTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testKeyTagView
{
    KeyTagView  *testSubject = [[KeyTagView alloc] init];
    
    if ( testSubject )
        {
        KeyFobImageInfoPtr  myInfo = [KeyTagView imageFileInfo];
        
        NSString *fName = [myInfo->image_file_names objectAtIndex:0];
        
        [testSubject setFileName:fName];
        [testSubject buildTag];
        [testSubject release];
        }
}

@end
