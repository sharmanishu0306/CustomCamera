//
//  ViewController.swift
//  VideoRecordingPOC
//
//  Created by Nishu Sharma on 07/04/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .brown
        
        let mb = UIDevice.current.freeDiskSpaceInMB
        print("MB \(mb)")
        print(UIDevice.modelName)
        print(CheckCurrentDeviceSupport4KRecording())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setStatusBar(color: .brown)
    }
    
    @IBAction func actionPresentRecorder(_ sender : Any)
    {
        let controller = CameraViewController()
        controller.bufferDelegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }



}

extension ViewController : GetCMSampleBufferDelegate
{
    func BufferDelegates(buffer: CMSampleBuffer) {
//        print(buffer)
    }
    
    
}

