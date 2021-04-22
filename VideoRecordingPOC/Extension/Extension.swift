//
//  Extension.swift
//  VideoRecordingPOC
//
//  Created by Nishu Sharma on 11/04/21.
//

import Foundation
import AVFoundation
import UIKit

class Utilis
{
    class func deleteFileFromLocalDirectory()
    {
        let filemanager = FileManager.default
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/Videos"
        let documentsPath = dir
        if filemanager.fileExists(atPath: dir)
        {
            do
            {
                try filemanager.removeItem(atPath: documentsPath)
                print("File Removed SuceessFully")
                // cehck
                self.deleteFileFromLocalDirectory()
            }
            catch let error as NSError
            {
                print(error.debugDescription)
            }
        }
        else
        {
            print("File was deleted")
        }
    }
}
