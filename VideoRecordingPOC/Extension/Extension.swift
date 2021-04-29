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
    
    static var videoDirectoryPath: String
    {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return dir + "/Videos"
    }
    
    class func deleteFileFromLocalDirectory()
    {
        
        if FileManager.default.fileExists(atPath: videoDirectoryPath)
        {
            do
            {
                try FileManager.default.removeItem(atPath: videoDirectoryPath)
                print("File Removed SuceessFully")
            }
            catch
            {
                print("fail to removeItem")
            }
        }
    }
}


 func CPUinfo() -> Dictionary<String, String> {
    #if targetEnvironment(simulator)
    let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
    #else
    
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8 , value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    #endif

     switch identifier {
//        iphone
        case "iPod5,1":                                 return ["A5":"800 MHz"]
        case "iPod7,1":                                 return ["A8":"1.4 GHz"]
        case "iPod9,1":                                 return ["A10":"1.63 GHz"]
//            iphone
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return ["A4":"800 MHz"]
        case "iPhone4,1":                               return ["A5":"800 MHz"]
        case "iPhone5,1", "iPhone5,2":                  return ["A6":"1.3 GHz"]
        case "iPhone5,3", "iPhone5,4":                  return ["A6":"1.3 GHz"]
        case "iPhone6,1", "iPhone6,2":                  return ["A7":"1.3 GHz"]
        case "iPhone7,2":                               return ["A8":"1.4 GHz"]
        case "iPhone7,1":                               return ["A8":"1.4 GHz"]
        case "iPhone8,1":                               return ["A9":"1.85 GHz"]
        case "iPhone8,2":                               return ["A9":"1.85 GHz"]
        case "iPhone9,1", "iPhone9,3":                  return ["A10":"2.34 GHz"]
        case "iPhone9,2", "iPhone9,4":                  return ["A10":"2.34 GHz"]
        case "iPhone8,4":                               return ["A9":"1.85 GHz"]
        case "iPhone10,1", "iPhone10,4":                return ["A11":"2.39 GHz"]
        case "iPhone10,2", "iPhone10,5":                return ["A11":"2.39 GHz"]
        case "iPhone10,3", "iPhone10,6":                return ["A11":"2.39 GHz"]
        case "iPhone11,2", "iPhone11,4",
             "iPhone11,6",  "iPhone11,8":               return ["A12":"2.5 GHz"]
        case "iPhone12,1","iPhone12,3"
             ,"iPhone12,5":                             return ["A13":"2650 GHz"]
        case "iPhone12,8":                              return ["A13":"2.65 GHz"]
        case "iPhone13,2","iPhone13,1","iPhone13,3":    return ["A14":"2.99 GHz"]
        case "iPhone13,4":                              return ["A14":"3.1 GHz"]
//            ipad
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return ["A5":"1.0 GHz"]
        case "iPad3,1", "iPad3,2", "iPad3,3":           return ["A5X":"1.0 GHz"]
        case "iPad3,4", "iPad3,5", "iPad3,6":           return ["A6X":"1.4 GHz"]
        case "iPad4,1", "iPad4,2", "iPad4,3":           return ["A7":"1.4 GHz"]
        case "iPad5,3", "iPad5,4":                      return ["A8X":"1.5 GHz"]
        case "iPad6,11", "iPad6,12":                    return ["A9":"1.85 GHz"]
        case "iPad2,5", "iPad2,6", "iPad2,7":           return ["A5":"1.0 GHz"]
        case "iPad4,4", "iPad4,5", "iPad4,6":           return ["A7":"1.3 GHz"]
        case "iPad4,7", "iPad4,8", "iPad4,9":           return ["A7":"1.3 GHz"]
        case "iPad5,1", "iPad5,2":                      return ["A8":"1.5 GHz"]
        case "iPad6,3", "iPad6,4":                      return ["A9X":"2.16 GHz"]
        case "iPad6,7", "iPad6,8":                      return ["A9X":"2.24 GHz"]
        case "iPad7,1", "iPad7,2",
             "iPad7,3", "iPad7,4":                      return ["A10X":"2.34 GHz"]
        case "iPad8,1", "iPad8,2",
             "iPad8,3", "iPad8,4":                      return ["A12X":"2.5 GHz"]
        case "iPad8,5", "iPad8,6",
             "iPad8,7", "iPad8,8",
             "iPad8,9", "iPad8,10",
             "iPad8,11", "iPad8,12":                    return ["A12Z":"2.5 GHz"]
            
        default:                                        return ["N/A":"N/A"]
        }
    }


func isChipsetGreaterThan10() -> Bool
{
    let objects = CPUinfo()
    print(objects)
    let str = "\(objects.keys.first ?? "...")"
    print(str.suffix(2))
    if str.count == 3
    {
        // go on Current device has A10+ chipset
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom
        {
        case .pad:
            return false
        case .phone:
            return true
        default:
            break
        }

       return true
    }
    else
    {
        // less tha A10 chipset
        return false
    }
}


func CheckCurrentDeviceSupport4KRecording() -> Bool
{
    let device = UIDevice.modelName
    
    if device == "iPhone 5s" || device == "iPhone 6" || device == "iPhone 6 Plus"
    {
        return false
    }
    else
    {
        return true
    }
    
}



extension UIButton
{
    func animateButton()
    {
        self.transform = .init(scaleX: 0.92, y: 0.92)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 1.0, options: .curveEaseOut) {
            self.transform = .identity
        } completion: { (check) in
            
        }
    }
}
 extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}


extension UIView
{
    func CircleView()
    {
        self.layer.cornerRadius = self.bounds.width / 2
        self.clipsToBounds = true
    }
}
