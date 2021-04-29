//
//  Protocol&Enums.swift
//  VideoRecordingPOC
//
//  Created by Nishu Sharma on 29/04/21.
//

import Foundation
import AVFoundation



//MARK:- Protocols

protocol GetCMSampleBufferDelegate : class
{
    func BufferDelegates( buffer : CMSampleBuffer)
}

protocol VideoRecordingCompletedDelegate : class
{
    func VideoRecordingCompletedAt(url : URL)
}


// MARK:- Enums

enum MediaType
{
    case audio
    case video
}

enum FPSType
{
    case FPS30
    case FPS60
}

enum PixelType
{
    case Pixel_720
    case Pixel_1080
    case Pixel_4K
}


// MARK:- Classes

class ResolutionObj
{
    var width : Double = 1280
    var height : Double = 720
    var framerate : Double = 30
    init() {
        
    }
}

class TimeRemainingObj
{
    var hours : Int = 0
    var minute : Int = 0
    init() {}
}
