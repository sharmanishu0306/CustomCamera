//
//  CameraViewController.swift
//  RectCapture
//
//  Created by Nishu Sharma on 31/03/21.
//  Copyright © 2021 NSScreencast. All rights reserved.
//


import UIKit
import AVFoundation
import AssetsLibrary
import AVKit


protocol GetCMSampleBufferDelegate : class
{
    func BufferDelegates( buffer : CMSampleBuffer)
}




class CameraViewController: UIViewController {
    
    
    //MARK:- Variables
    
    // For Session
    private var _captureSession: AVCaptureSession?
    
    // Audio/Video Output
    private var _videoOutput: AVCaptureVideoDataOutput?
    private var _audioOutput : AVCaptureAudioDataOutput?
  
    
    
    var assetWriter:AssetWriter?
    var isStartCapturing = false
    var timer = Timer()
    var timeCounter = 0
    
    var videoDevice : AVCaptureDevice?
    weak var bufferDelegate : GetCMSampleBufferDelegate?
    var _videoInput : AVCaptureDeviceInput?
    var isHDCapturing = true
    
    var _frame = 60
    var _value = 1
    
    
    var pixelTypeObj : PixelType = .Pixel_720
    var fpsTypeObj : FPSType = .FPS30
    var TimeObj = TimeRemainingObj()
    
    
    //MARK:- Outlet
    
    @IBOutlet weak var viewOuter : UIView!
    @IBOutlet weak var viewInner : UIView!
    @IBOutlet weak var cameraContainerView : UIView!
    @IBOutlet weak var lblTimer : UILabel!
    @IBOutlet weak var btnCancel : UIButton!
    @IBOutlet weak var btnFlash : UIButton!
    @IBOutlet weak var btnVideoResolution : UIButton!
    @IBOutlet weak var viewTop : UIView!
    @IBOutlet weak var viewBottom : UIView!
    @IBOutlet weak var btnFPS : UIButton!
    @IBOutlet weak var btnPause : UIButton!
    @IBOutlet weak var lblDiskRemainingInTime : UILabel!
    
    //MARK:- IBAction
    
    
    @IBAction func actionPauseRecording(_ sender : Any)
    {
        if btnPause.isSelected == false
        {
            self.isStartCapturing = false
        }
        else
        {
            self.isStartCapturing = true
        }
        btnPause.isSelected = !btnPause.isSelected
        
        
    }
    
    @IBAction func actionChangeFPS(_ sender : UIButton)
    {
        
        let FPStitle = sender.titleLabel?.text ?? "30"
        var setFPS  = 30.0
        
        if FPStitle == "30"
        {
            setFPS = 60.0
            self.fpsTypeObj = .FPS60
        }
        else
        if FPStitle == "60"
        {
            setFPS = 30.0
            self.fpsTypeObj = .FPS30
        }
                        
        
        _frame = Int(setFPS)
        DispatchQueue.main.async
        { [weak self] in
            guard let self = self else { return }
            
            if let input = self._videoInput
            {
                var finalFormat : AVCaptureDevice.Format!
                var maxFps: Double = 0
                for vFormat in input.device.formats
                {
                    let ranges      = vFormat.videoSupportedFrameRateRanges
                    let frameRates  = ranges[0]
                    if frameRates.maxFrameRate >= maxFps && frameRates.maxFrameRate <= setFPS
                    {
                        maxFps = frameRates.maxFrameRate
                        if #available(iOS 13.0, *)
                        {
                            let dim = vFormat.formatDescription.dimensions
                            
                            if self.pixelTypeObj == .Pixel_720 //self._captureSession?.sessionPreset == .hd1280x720
                            {
                                if dim.width == 1280 && dim.height == 720
                                {
                                    finalFormat = vFormat
                                    self.pixelTypeObj = .Pixel_720
                                    let resolutionObj = ResolutionObj()
                                    resolutionObj.width = Double(dim.width)
                                    resolutionObj.height = Double(dim.height)
                                    resolutionObj.framerate = setFPS
                                    self.assetWriter?.resObj = resolutionObj
                                }
                            }
                            else
                            if self.pixelTypeObj == .Pixel_1080//self._captureSession?.sessionPreset == .some(.hd1920x1080)
                            {
                                if dim.width == 1920 && dim.height == 1080
                                {
                                    finalFormat = vFormat
                                    self.pixelTypeObj = .Pixel_1080
                                    let resolutionObj = ResolutionObj()
                                    resolutionObj.width = Double(dim.width)
                                    resolutionObj.height = Double(dim.height)
                                    resolutionObj.framerate = setFPS
                                    self.assetWriter?.resObj = resolutionObj
                                }
                            }
                            else
                            if self.pixelTypeObj == .Pixel_4K//self._captureSession?.sessionPreset == .some(.hd4K3840x2160)
                            {
                                if dim.width == 3840 && dim.height == 2160
                                {
                                    finalFormat = vFormat
                                    self.pixelTypeObj = .Pixel_4K
                                    let resolutionObj = ResolutionObj()
                                    resolutionObj.width = Double(dim.width)
                                    resolutionObj.height = Double(dim.height)
                                    resolutionObj.framerate = setFPS
                                    self.assetWriter?.resObj = resolutionObj
                                }
                            }
                            
                        }
                        else
                        {
                            
                        }
                        
                        
                    }
                }
                
                print(String(maxFps) + " fps")
                if let formate = finalFormat
                {
                    do
                {
                    let camera = input.device
                    try camera.lockForConfiguration()
                    camera.activeFormat = formate
                    camera.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(maxFps))
                    camera.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(maxFps))
                    camera.unlockForConfiguration()
                }
                    catch(let err)
                    {
                        print("error \(err.localizedDescription)")
                        let controller = UIAlertController(title: "Video Recording", message: err.localizedDescription, preferredStyle: .alert)
                        let okbtn = UIAlertAction(title: "OK", style: .default) { (_ ) in }
                        controller.addAction(okbtn)
                        self.present(controller, animated: true, completion: nil)
                    }
                }
                
            }
            
            // convert from double to Int so we can set btn title
            
            if let fpsString = Int(setFPS) as? Int
            {
                self.btnFPS.setTitle("\(fpsString)", for: .normal)
            }
            self.CalcualateDaysAndHour()
            
            
        }
    }
    
    @IBAction func actionVideoResolution(_ sender : UIButton)
    {
        
        DispatchQueue.main.async
        { [weak self] in
            guard let self = self else { return }
            
            let resolutionObj = ResolutionObj()
            if self.pixelTypeObj == .Pixel_720
            {
                if self._captureSession?.canSetSessionPreset(.hd1920x1080) == true
                {
                    self._captureSession?.sessionPreset = .hd1920x1080
                    self.pixelTypeObj = .Pixel_1080
                    resolutionObj.width = 1920
                    resolutionObj.height = 1080
                }
                else
                {
                    self._captureSession?.sessionPreset = .hd1280x720
                    self.pixelTypeObj = .Pixel_720
                    resolutionObj.width = 1280
                    resolutionObj.height = 720
                }
                
            }
            else
            if self.pixelTypeObj == .Pixel_1080
            {
                self.pixelTypeObj = .Pixel_4K
                if self._captureSession?.canSetSessionPreset(.hd4K3840x2160) == true
                {
                    self._captureSession?.sessionPreset = .hd4K3840x2160
                    resolutionObj.width = 3840
                    resolutionObj.height = 2160
                }
                else
                {
                    self._captureSession?.sessionPreset = .hd1920x1080
                    resolutionObj.width = 1920
                    resolutionObj.height = 1080
                }
            }
            else
            {
                self.pixelTypeObj = .Pixel_720
                self._captureSession?.sessionPreset = .hd1280x720
                resolutionObj.width = 1280
                resolutionObj.height = 720
                
            }
            
            let fps = self.fpsTypeObj == .FPS30 ? 30 : 60
            resolutionObj.framerate = Double(fps)
            self.assetWriter?.resObj = resolutionObj
            
            if fps == 60
            {
                self.fpsTypeObj = .FPS30
                self.actionChangeFPS(self.btnFPS)
            }
           
            var str = ""
            switch self.pixelTypeObj
            {
            case .Pixel_720:
                str = "720P"
                break
            case .Pixel_1080:
                str = "1080P"
                break
            case .Pixel_4K:
                str = "4K"
                break
            }
            
            self.btnVideoResolution.setTitle(str, for: .normal)
            self.CalcualateDaysAndHour()
        }
        
        
    }
    
    
    @IBAction func actionFlashOnOff(_ sender : Any)
    {
        DispatchQueue.main.async
        { [weak self] in
            guard let self = self else { return }
            
            guard let button = sender as? UIButton else{ return }
            button.isSelected = !button.isSelected
            self.toggleFlash()
        }
        
        
    }
    
    @IBAction func actionCancel(_ sender : Any)
    {
        timeCounter = 0
        timer.invalidate()
        self.isStartCapturing = false
        self._captureSession?.stopRunning()
        self._captureSession = nil
        self.assetWriter?.delegate = nil
        self.assetWriter = nil
        self.bufferDelegate = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func actionCapture(_ sender : UIButton)
    {
        if sender.isSelected == false
        {
            if UIDevice.current.freeDiskSpaceInMB <= 200
            {
                
                let controller = UIAlertController(title: "Video Recording", message: "Your storage is almost full.", preferredStyle: .alert)
                let okbtn = UIAlertAction(title: "Dismiss", style: .default) { [weak self](_ ) in
                    guard let self = self else { return }
                    self.actionCancel(self)
                }
                controller.addAction(okbtn)
                self.present(controller, animated: true, completion: nil)
            }
            else
            {
                
                self.HideTopButtons()
                self.isStartCapturing = true
                self.CheckAndUpdateTimeByTenSecond()
                let duration  = 1
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(duration), target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
                
            }
        }
        else
        {
            self.lblTimer.text = "00:00:00"
            timeCounter = 0
            timer.invalidate()
            self.isStartCapturing = false
            self._captureSession?.stopRunning()
            self.assetWriter?.finishWriting()
        }
        
        sender.isSelected = !sender.isSelected
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewOuter.backgroundColor = .white
        self.viewOuter.layer.cornerRadius = viewOuter.layer.frame.size.width / 2
        self.viewOuter.clipsToBounds = true
        
        self.viewInner.backgroundColor = .white
        self.viewInner.layer.cornerRadius = viewInner.layer.frame.size.width / 2
        self.viewInner.clipsToBounds = true
        
        self.viewInner.backgroundColor = .red

        self.lblTimer.text = "00:00:00"
        self.lblTimer.backgroundColor = .red
        self.lblTimer.textColor = .white
        self.lblTimer.layer.cornerRadius = 6.0
        self.lblTimer.clipsToBounds = true
        
        
        self.btnFlash.setImage(UIImage(named: "FlashOff"), for: .normal)
        self.btnFlash.setImage(UIImage(named: "FlashOn"), for: .selected)
        
        let bgcolor = UIColor.black.withAlphaComponent(0.45)
        self.viewTop.backgroundColor = bgcolor
        self.viewBottom.backgroundColor = bgcolor
        
    }
    
    
    @objc func timerAction()
    {
        var times = ""
        self.timeCounter += 1
        if self.timeCounter > 59
        {
           
            let sec = self.timeCounter % 60
            let min = self.timeCounter / 60
            
            if min < 10
            {
                if sec < 10
                {
                    times = "00:0\(min):0\(sec)"
                }
                else
                {
                    times = "00:0\(min):\(sec)"
                }
            }
            else
            {
                if sec < 10
                {
                    times = "00:\(min):0\(sec)"
                }
                else
                {
                    times = "00:\(min):\(sec)"
                }
            }
            
            if self.TimeObj.hours == 0
            {
                if min == self.TimeObj.minute
                {
                    self.lblTimer.text = "00:00:00"
                    timeCounter = 0
                    timer.invalidate()
                    self.isStartCapturing = false
                    self._captureSession?.stopRunning()
                    self.assetWriter?.finishWriting()
                    self.lblDiskRemainingInTime.text = ""
                }
            }
            
            
        }
        else
        {
            if timeCounter < 10
            {
                times = "00:00:0\(timeCounter)"
            }
            else
            {
                times = "00:00:\(self.timeCounter)"
            }
            
        }
        
        self.lblTimer.text = times
        print("Counter \(timeCounter)")
        
        
    }
    
    
    private func HideTopButtons()
    {
        UIView.animate(withDuration: 0.35) { [weak self] in
            guard let self = self else { return }
            self.btnVideoResolution.transform = .init(translationX: self.btnVideoResolution.frame.origin.x + 50, y: 0)
            self.btnVideoResolution.isHidden = true
        } completion: { (check) in
            UIView.animate(withDuration: 0.30) { [weak self] in
                guard let self = self else { return }
                self.btnFPS.transform = .init(translationX: self.btnFPS.frame.origin.x + 50, y: 0)
                self.btnFPS.isHidden = true
            } completion: { [weak self](check) in
                guard let self = self else { return }
                self.btnFPS.transform = .identity
                self.btnVideoResolution.transform = .identity
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                if granted
                {
                    DispatchQueue.main.async
                    { [weak self] in  guard let self = self else { return }
                        self._setupCaptureSession()
                    }
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            DispatchQueue.main.async
            { [weak self] in  guard let self = self else { return }
                self._setupCaptureSession()
            }
        @unknown default: break
            
        }
    }

    private func _setupCaptureSession()
    {
        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720
        session.usesApplicationAudioSession = true

        
        // audio
        guard let audioDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified),
            let audioinput = try? AVCaptureDeviceInput(device: audioDevice),
            session.canAddInput(audioinput)
        else
        {
            
            let controller = UIAlertController(title: "Video Recording", message: "Unable to add audio device.", preferredStyle: .alert)
            let okbtn = UIAlertAction(title: "Dismiss", style: .default) { [weak self](_ ) in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }
            controller.addAction(okbtn)
            self.present(controller, animated: true, completion: nil)
            
            return
            
        }

        session.beginConfiguration()
        session.addInput(audioinput)
        session.commitConfiguration()

        let audiooutput = AVCaptureAudioDataOutput()
        guard session.canAddOutput(audiooutput) else { return }

        
        audiooutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.yusuke024.audio"))
        session.beginConfiguration()
        session.addOutput(audiooutput)
        session.commitConfiguration()
        
        
        
        // video
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else
        {
            let controller = UIAlertController(title: "Video Recording", message: "Unable to add video device.", preferredStyle: .alert)
            let okbtn = UIAlertAction(title: "Dismiss", style: .default) {[weak self] (_ ) in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }
            controller.addAction(okbtn)
            self.present(controller, animated: true, completion: nil)
            return
            
        }

    
        session.beginConfiguration()
        session.addInput(input)
        session.commitConfiguration()
        self._videoInput = input
        

        let output = AVCaptureVideoDataOutput()
        guard session.canAddOutput(output) else { return }
        
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.yusuke024.video"))
        session.beginConfiguration()
        session.addOutput(output)
        session.commitConfiguration()
        
        if let videoDataOutputConnection = output.connection(with: .video), videoDataOutputConnection.isVideoStabilizationSupported {
            videoDataOutputConnection.preferredVideoStabilizationMode = .standard
        }

        DispatchQueue.main.async
        {
            [weak self] in
            guard let self = self else { return }
            let previewView = _PreviewView()
            previewView.tag = 2233
            previewView.videoPreviewLayer.session = session
            previewView.frame = self.cameraContainerView.bounds
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
            previewView.videoPreviewLayer.position = CGPoint(x:self.cameraContainerView.bounds.midX, y:self.cameraContainerView.bounds.midY)
            if let views = self.cameraContainerView.viewWithTag(2233)
            {
                views.removeFromSuperview()
            }
            self.cameraContainerView.insertSubview(previewView, at: 0)
            
        }

        let outputFileName = NSUUID().uuidString + ".mp4"
        assetWriter = AssetWriter(fileName: outputFileName)
        assetWriter!.delegate = self
        assetWriter!.RemoveFolder()
        session.startRunning()
        _videoOutput = output
        _audioOutput = audiooutput
        _captureSession = session
        self.btnFPS.isHidden = false
        self.btnVideoResolution.isHidden = false
        self.isHDCapturing = true
        self.btnFPS.setTitle("30", for: .normal)
        self.btnVideoResolution.setTitle("720P", for: .normal)
        
        let obj = ResolutionObj()
        obj.framerate = 30
        obj.height = 720
        obj.width = 1080
        self.assetWriter?.resObj = obj
        self.pixelTypeObj = .Pixel_720
        self.fpsTypeObj = .FPS30
        self.CalcualateDaysAndHour()
            
    }
    
    
    func toggleFlash()
    {
        if let device = AVCaptureDevice.default(for: .video)
        {
            if (device.hasTorch)
            {
                do {
                    try device.lockForConfiguration()
                    if (device.torchMode == AVCaptureDevice.TorchMode.on)
                    {
                        device.torchMode = AVCaptureDevice.TorchMode.off
                    }
                    else
                    {
                        do
                        {
                            try device.setTorchModeOn(level: 1.0)
                        }
                        catch
                        {
                            print(error)
                        }
                    }
                    device.unlockForConfiguration()
                }
                catch
                {
                    print(error)
                }
            }
        }

    }
    
    
    func CalcualateDaysAndHour()
    {
        let TempTimeObj = TimeRemainingObj()
        
        if pixelTypeObj == .Pixel_720
        {
            
            if fpsTypeObj == .FPS30
            {
                let oneMinValue = FramePerSecond30().resolution_720
                var initialValue = oneMinValue
                var mins = 0
                while initialValue < UIDevice.current.freeDiskSpaceInMB
                {
                    initialValue += oneMinValue
                    mins += 1
                }
                
                let inHour = mins / 60
                let inMin = mins % 60
                
                TempTimeObj.hours = inHour
                TempTimeObj.minute = inMin
                
                if inHour > 0
                {
                    self.lblDiskRemainingInTime.text = "\(inHour) Hours\n\(inMin) Minutes"
                }
                else
                {
                    self.lblDiskRemainingInTime.text = "\(inMin) Minutes Left"
                }
                
            }
            else
            {
                let oneMinValue = FramePerSecond60().resolution_720
                var initialValue = oneMinValue
                var mins = 0
                while  initialValue < UIDevice.current.freeDiskSpaceInMB
                {
                    initialValue += oneMinValue
                    mins += 1
                }
                
                let inHour = mins / 60
                let inMin = mins % 60
                
                TempTimeObj.hours = inHour
                TempTimeObj.minute = inMin
                
                if inHour > 0
                {
                    self.lblDiskRemainingInTime.text = "\(inHour) Hours\n\(inMin) Minutes"
                }
                else
                {
                    self.lblDiskRemainingInTime.text = "\(inMin) Minutes Left"
                }
            }
            
        }
        else
        if pixelTypeObj == .Pixel_1080
        {
            if fpsTypeObj == .FPS30
            {
                let oneMinValue = FramePerSecond30().resolution_1080
                var initialValue = oneMinValue
                var mins = 0
                while  initialValue < UIDevice.current.freeDiskSpaceInMB
                {
                    initialValue += oneMinValue
                    mins += 1
                }
                
                let inHour = mins / 60
                let inMin = mins % 60
                
                TempTimeObj.hours = inHour
                TempTimeObj.minute = inMin
                
                if inHour > 0
                {
                    self.lblDiskRemainingInTime.text = "\(inHour) Hours\n\(inMin) Minutes"
                }
                else
                {
                    self.lblDiskRemainingInTime.text = "\(inMin) Minutes Left"
                }
            }
            else
            {
                let oneMinValue = FramePerSecond60().resolution_1080
                var initialValue = oneMinValue
                var mins = 0
                while  initialValue < UIDevice.current.freeDiskSpaceInMB
                {
                    initialValue += oneMinValue
                    mins += 1
                }
                
                let inHour = mins / 60
                let inMin = mins % 60
                
                TempTimeObj.hours = inHour
                TempTimeObj.minute = inMin
                
                if inHour > 0
                {
                    self.lblDiskRemainingInTime.text = "\(inHour) Hours\n\(inMin) Minutes"
                }
                else
                {
                    self.lblDiskRemainingInTime.text = "\(inMin) Minutes Left"
                }
            }
        }
        else
        if pixelTypeObj == .Pixel_4K
        {
            if fpsTypeObj == .FPS30
            {
                let oneMinValue = FramePerSecond30().resolution_4K
                var initialValue = oneMinValue
                var mins = 0
                while  initialValue < UIDevice.current.freeDiskSpaceInMB
                {
                    initialValue += oneMinValue
                    mins += 1
                }
                
                let inHour = mins / 60
                let inMin = mins % 60
                
                TempTimeObj.hours = inHour
                TempTimeObj.minute = inMin
                
                if inHour > 0
                {
                    self.lblDiskRemainingInTime.text = "\(inHour) Hours\n\(inMin) Minutes"
                }
                else
                {
                    self.lblDiskRemainingInTime.text = "\(inMin) Minutes Left"
                }
            }
            else
            {
                let oneMinValue = FramePerSecond60().resolution_4K
                var initialValue = oneMinValue
                var mins = 0
                while  initialValue < UIDevice.current.freeDiskSpaceInMB
                {
                    initialValue += oneMinValue
                    mins += 1
                }
                
                let inHour = mins / 60
                let inMin = mins % 60
                
                TempTimeObj.hours = inHour
                TempTimeObj.minute = inMin
                
                if inHour > 0
                {
                    self.lblDiskRemainingInTime.text = "\(inHour) Hours\n\(inMin) Minutes"
                }
                else
                {
                    self.lblDiskRemainingInTime.text = "\(inMin) Minutes Left"
                }
            }
        }
        
        if self.isStartCapturing == false
        {
            self.TimeObj = TempTimeObj
        }
        
    }
    
    func CheckAndUpdateTimeByTenSecond()
    {
        DispatchQueue.main.async
        { [weak self] in
            guard let self = self else { return }
            self.CalcualateDaysAndHour()
            
            // update remaining time after 10 sec
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0)
            { [weak self] in
                guard let self = self else { return }
                if self.isStartCapturing == true
                {
                    if self.TimeObj.hours == 0 && self.TimeObj.minute == 1
                    {
                        return
                    }
                    self.CheckAndUpdateTimeByTenSecond()
                }
                
            }
        }
    }
    
    
    deinit
    {
        print("Camera ViewController is released and no any memory leak found")
    }
    
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
//        print(_videoInput?.device.activeFormat)
        
        if self.isStartCapturing == true
        {
            if #available(iOS 13.0, *)
            {
                self.bufferDelegate?.BufferDelegates(buffer: sampleBuffer)
                let description = CMSampleBufferGetFormatDescription(sampleBuffer)!
                if description.mediaType == .video
                {
                    let bufferType =  MediaType.video
                    self.assetWriter!.write(buffer: sampleBuffer, bufferType: bufferType)
                    
                }
                else
                {
                    let bufferType = MediaType.audio
                    self.assetWriter!.write(buffer: sampleBuffer, bufferType: bufferType)
                }
            }
            else
            {
            
            }
            
        }
    
    }
}

private class _PreviewView: UIView
{
    override class var layerClass: AnyClass
    {
        return AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer
    {
        return layer as! AVCaptureVideoPreviewLayer
    }
}


extension CameraViewController : VideoRecordingCompletedDelegate
{
    func VideoRecordingCompletedAt(url: URL)
    {
        
//        DispatchQueue.main.async
//        {
//            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//            self.present(activity, animated: true, completion: nil)
//        }
//
//
//        return
        let alertController = UIAlertController(title: "Your video saved successfully.", message: nil, preferredStyle: .alert)
        
        
        let defaultAction = UIAlertAction(title: "Preview", style: .default) { _ in ()
            
            DispatchQueue.main.async
            {
                self.isStartCapturing = false
                
                let con = AVPlayerViewController()
                con.player = AVPlayer(url: url)
                con.showsPlaybackControls = true
                con.delegate = self
                if let topVC = UIApplication.getTopViewController()
                {
                    topVC.present(con, animated: true)
                    {
                        con.player?.play()
                    }
                }
                
            }
            
        }
        alertController.addAction(defaultAction)
        if let topVC = UIApplication.getTopViewController()
        {
            DispatchQueue.main.async
            {
                topVC.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
}

extension CameraViewController : AVPlayerViewControllerDelegate
{
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        self.actionCancel(self)
//        self.dismiss(animated: false, completion: nil)
    }
}
