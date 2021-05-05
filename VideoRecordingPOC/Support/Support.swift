//
//  Support.swift
//  VideoRecordingPOC
//
//  Created by Nishu Sharma on 05/05/21.
//

import Foundation
import AVKit


class CheckResolutionAndFrameSupport
{
    
    static func isSupport4KOn60Fps(input : AVCaptureDeviceInput?) -> Bool
    {
        var is4kSupportOn60FPS = false
        if let input = input
        {
            var maxFps: Double = 0
            for vFormat in input.device.formats
            {
                let ranges      = vFormat.videoSupportedFrameRateRanges
                let frameRates  = ranges[0]
                if frameRates.maxFrameRate >= maxFps && frameRates.maxFrameRate <= 60.0
                {
                    maxFps = frameRates.maxFrameRate
                    let dim = vFormat.formatDescription.dimensions
                    // 4K format dimension
                    if dim.width == 3840 && dim.height == 2160
                    {
                        is4kSupportOn60FPS = true
                    }
                }
            }
            
        }
        return is4kSupportOn60FPS
    }
    
    static func isSupport1080On60Fps(input : AVCaptureDeviceInput?) -> Bool
    {
        var is1080SupportOn60FPS = false
        if let input = input
        {
            var maxFps: Double = 0
            for vFormat in input.device.formats
            {
                let ranges      = vFormat.videoSupportedFrameRateRanges
                let frameRates  = ranges[0]
                if frameRates.maxFrameRate >= maxFps && frameRates.maxFrameRate <= 60.0
                {
                    maxFps = frameRates.maxFrameRate
                    let dim = vFormat.formatDescription.dimensions
                    // 1080 format dimension
                    if dim.width == 1920 && dim.height == 1080
                    {
                        is1080SupportOn60FPS = true
                    }
                }
            }
            
        }
        return is1080SupportOn60FPS
    }
    
    
    
    
}
