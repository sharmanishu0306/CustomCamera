//
//  SampleRecordData.swift
//  VideoRecordingPOC
//
//  Created by Nishu Sharma on 19/04/21.
//

import Foundation
import UIKit



// Testing on iPhone 8 64 GB


// MARK:- H.264

//MARK:- 30 FPS

// Case 1 for 1280P X 720P
// 1 min = 45 MB, 10 min = 450 MB

// Case 2 for 1920P X 1080P
// 1 min = 102 MB, 10 min = 1020 MB

// Case 3 for 3840P X 2160P(4K)
//  1 min = 415 MB, 10 min = 4150 MB

//MARK:- 60 FPS

// Case 1 for 1280P X 720P
// 1 min = 87 MB, 10 min = 870 MB

// Case 2 for 1920P X 1080P
// 1 min = 200 MB, 10 min = 2000 MB

// Case 3 for 3840P X 2160P(4K)
// 1 min = 776 MB, 10 min = 7760 MB



// MARK:- HEVC - High Efficient Video Coding, this format is best for good video quality and save disk space upto 50% than standard format uses

// MARK:- 30 FPS

// Case 1 for 1280P X 720P
// 1 min = 24 MB, 10 min = 240 MB

// Case 2 for 1920P X 1080P
// 1 min = 52 MB, 10 min = 520 MB

// Case 3 for 3840P X 2160P(4K)
// 1 min = 205 MB, 10 min = 2050 MB



// MARK:- 60 FPS
// Case 1 for 1280P X 720P
// 1 min = 47 MB, 10 min = 470 MB

// Case 2 for 1920P X 1080P
// 1 min = 104 MB, 10 min = 1040 MB

// Case 3 for 3840P X 2160P(4K)
// 1 min = 411 MB, 10 min = 4110 MB


struct FramePerSecond30
{
    
    var resolution_720 : Int
    {
        if isChipsetGreaterThan10() == true
        {
            return 24
        }
        else
        {
            return 45
        }
    }
    var resolution_1080 : Int
    {
        if isChipsetGreaterThan10() == true
        {
            return 52
        }
        else
        {
            return 102
        }
    }
    var resolution_4K : Int
    {
        if isChipsetGreaterThan10() == true
        {
            return 205
        }
        else
        {
            return 415
        }
    }
    
}

struct FramePerSecond60
{
    var resolution_720 : Int
    {
        if isChipsetGreaterThan10() == true
        {
            return 47
        }
        else
        {
            return 87
        }
    }
    var resolution_1080 : Int
    {
        if isChipsetGreaterThan10() == true
        {
            return 104
        }
        else
        {
            return 200
        }
    }
    var resolution_4K : Int
    {
        if isChipsetGreaterThan10() == true
        {
            return 411
        }
        else
        {
            return 409//776
        }
    }
}


