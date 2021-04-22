

import UIKit
import Foundation
import AVFoundation
import AVKit


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


protocol VideoRecordingCompletedDelegate : class
{
    func VideoRecordingCompletedAt(url : URL)
}

class AssetWriter
{
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private let fileName: String
    
    weak var delegate : VideoRecordingCompletedDelegate?
    
    let writeQueue = DispatchQueue(label: "writeQueue")
    var resObj = ResolutionObj()
    
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    private var videoDirectoryPath: String {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return dir + "/Videos"
    }
    
    private var filePath: String {
        return videoDirectoryPath + "/\(fileName)"
    }
    
    private func setupWriter(buffer: CMSampleBuffer)
    {
        if FileManager.default.fileExists(atPath: videoDirectoryPath) {
            do {
                try FileManager.default.removeItem(atPath: videoDirectoryPath)
            } catch {
                print("fail to removeItem")
            }
        }
        do {
            try FileManager.default.createDirectory(atPath: videoDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("fail to createDirectory")
        }
        
        self.assetWriter = try? AVAssetWriter(outputURL: URL(fileURLWithPath: filePath), fileType: AVFileType.mov)
        
        let writerOutputSettings = [
            AVVideoCodecKey: AVVideoCodecType.hevc,
            AVVideoWidthKey: resObj.width,
            AVVideoHeightKey: resObj.height,
            AVVideoCompressionPropertiesKey : [ AVVideoExpectedSourceFrameRateKey: resObj.framerate]
            ] as [String : Any]
        
        print("Video Setting \(writerOutputSettings)")
        
        self.videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: writerOutputSettings)
        self.videoInput?.transform = CGAffineTransform(rotationAngle: self.videoOrientation())
        self.videoInput?.expectsMediaDataInRealTime = true
        
        guard let format = CMSampleBufferGetFormatDescription(buffer),
            let stream = CMAudioFormatDescriptionGetStreamBasicDescription(format) else {
                print("fail to setup audioInput")
                return
        }
        
        let audioOutputSettings = [
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey : stream.pointee.mChannelsPerFrame,
            AVSampleRateKey : stream.pointee.mSampleRate,
            AVEncoderBitRateKey : 64000
            ] as [String : Any]
        
        self.audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        self.audioInput?.expectsMediaDataInRealTime = true
        
        if let videoInput = self.videoInput, (self.assetWriter?.canAdd(videoInput))! {
            self.assetWriter?.add(videoInput)
        }
        
        if  let audioInput = self.audioInput, (self.assetWriter?.canAdd(audioInput))! {
            self.assetWriter?.add(audioInput)
        }
    }
    
    
    private func videoOrientation() -> CGFloat
    {
        var text = ""
        var value = CGFloat()
        switch UIDevice.current.orientation
        {
        case .portrait:
            text="Portrait"
            value = .pi/2
        case .portraitUpsideDown:
            text="PortraitUpsideDown"
            value = -.pi/2
        case .landscapeLeft:
            text="LandscapeLeft"
            value = .pi/4
        case .landscapeRight:
            text="LandscapeRight"
            value = -.pi
        default:
            value = .pi/2
            
            
        }
        print(text)
        return value
    }
    
    public func write(buffer: CMSampleBuffer, bufferType: MediaType)
    {
        
        writeQueue.sync {
            if self.assetWriter == nil {
                if bufferType == .audio {
                    self.setupWriter(buffer: buffer)
                }
            }
            
            if self.assetWriter == nil {
                return
            }
            
            if self.assetWriter?.status == .unknown {
                print("Start writing")
                let startTime = CMSampleBufferGetPresentationTimeStamp(buffer)
                self.assetWriter?.startWriting()
                self.assetWriter?.startSession(atSourceTime: startTime)
                print("Writing at path \(String(describing: self.assetWriter?.outputURL))")
            }
            if self.assetWriter?.status == .failed {
                print("assetWriter status: failed error: \(String(describing: self.assetWriter?.error))")
                return
            }
            
            let size = self.sizePerMB(url: assetWriter?.outputURL)
            print("Size in MB \(size)")
            print("Remaining Size in MB \(UIDevice.current.freeDiskSpaceInGB)")
            
            if CMSampleBufferDataIsReady(buffer) == true {
                if bufferType == .video {
                    if let videoInput = self.videoInput, videoInput.isReadyForMoreMediaData {
                        videoInput.append(buffer)
                    }
                } else if bufferType == .audio {
                    if let audioInput = self.audioInput, audioInput.isReadyForMoreMediaData {
                        audioInput.append(buffer)
                    }
                }
            }
        }
    }
    
    
    private func sizePerMB(url: URL?) -> Double
    {
        guard let filePath = url?.path else
        {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber
            {
                return size.doubleValue / 1000000.0
            }
        }
        catch
        {
            print("Error: \(error)")
        }
        return 0.0
    }
    
    
    public func finishWriting()
    {
        writeQueue.sync
        {
            self.assetWriter?.finishWriting(completionHandler:
                                                {
                print("finishWriting at \(self.filePath)")
                    DispatchQueue.main.async
                    { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.VideoRecordingCompletedAt(url:  URL(fileURLWithPath: self.filePath))
                    }
            })
        }
    }
}
