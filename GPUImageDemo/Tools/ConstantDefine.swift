//
//  ConstantDefine.swift
//  FirstSwiftApp
//
//  Created by weijieMac on 2018/8/9.
//  Copyright © 2018年 Mac. All rights reserved.
//

import Foundation
import UIKit

/// 设备UUID
let deviceUUID = UIDevice.current.identifierForVendor?.uuidString

/// 是否是全面屏
let deviceIsMainScreenIPhone =  modelName == "iPhone X"  ||
                                modelName == "iPhone XR" ||
                                modelName == "iPhone XS" ||
                                modelName == "iPhone XS Max" ? true : false

/// 根据4.7寸屏与当前屏的宽比缩放px
///
/// - Parameter value: 4.7寸屏下宽的px
/// - Returns: 当前屏幕下宽的px
func realValue_W(value:CGFloat) -> CGFloat {
    return value*1.0/2/375*screenWidth
}

/// 根据4.7寸屏与当前屏的高比缩放px
///
/// - Parameter value: 4.7寸屏下高的px
/// - Returns: 当前屏幕下高的px
func realValue_H(value:CGFloat) -> CGFloat {
    return value*1.0/2/667*screenHeight
}

/*
 Frame相关
 */
let screenFrame = UIScreen.main.bounds

let screenSize = screenFrame.size

let screenWidth = screenSize.width

let screenHeight = screenSize.height

let screenCenterX = screenWidth*1.0/2

let screenCenterY = screenHeight*1.0/2

let screenCenter = CGPoint.init(x: screenCenterX, y: screenCenterY)

let naviHeight : CGFloat = phoneTop + 64

let tabbarHeight : CGFloat = deviceIsMainScreenIPhone ? 49 + 24 : 49

let phoneTop : CGFloat = deviceIsMainScreenIPhone ? 24 : 0

let phoneBottom : CGFloat = deviceIsMainScreenIPhone ? screenHeight - 24 : screenHeight


/*
 colors
 */
let whiteColor = UIColor.white

let blackColor = UIColor.black

let clearColor = UIColor.clear

/// rgb色值生成颜色，色值区间0~255，透明度区间0~1
///
/// - Parameters:
///   - red: 红色
///   - green: 绿色
///   - blue: 蓝色
///   - alpha: 透明度
/// - Returns: UIColor
func colorRGBA(red:CGFloat,green:CGFloat,blue:CGFloat,alpha:CGFloat) -> UIColor {
    return UIColor.init(red: red*1.0/255, green: green*1.0/255, blue: blue*1.0/255, alpha: alpha)
}


/// 十六进制色值字符串生成颜色
///
/// - Parameter color: 十六进制色值字符串
/// - Returns: UIColor
func colorStr(color:String) -> UIColor {
    var colorStr = color.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
    if colorStr.count < 6 {return clearColor}
    
    if colorStr.hasPrefix("0X") { colorStr = colorStr[2..<7]}
    if colorStr.hasPrefix("#")  { colorStr = colorStr[1..<7]}
    if colorStr.count != 6      {return clearColor}
    
    let redStr = colorStr[0..<2]
    
    let greenStr = colorStr[2..<4]
    
    let blueStr = colorStr[4..<6]

    return colorRGBA(red: CGFloat(redStr.hexStringToInt()), green: CGFloat(greenStr.hexStringToInt()), blue: CGFloat(blueStr.hexStringToInt()), alpha: 1)
    
}

func creatImage(withColor color:UIColor) -> UIImage {
    let frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(frame.size)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context!.fill(frame)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

/*
 沙盒路径
 */
let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first



/// 判断当前版本号是否大于等于参数值
///
/// - Parameter version: 版本号
/// - Returns: 结果
func laterIOSVersion(version : Double) -> Bool {
    return Double(UIDevice.current.systemVersion)! >= version
}

/// 设备型号
var modelName: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    switch identifier {
    case "iPod1,1":  return "iPod Touch 1"
    case "iPod2,1":  return "iPod Touch 2"
    case "iPod3,1":  return "iPod Touch 3"
    case "iPod4,1":  return "iPod Touch 4"
    case "iPod5,1":  return "iPod Touch (5 Gen)"
    case "iPod7,1":   return "iPod Touch 6"
        
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone 4"
    case "iPhone4,1":  return "iPhone 4s"
    case "iPhone5,1":  return "iPhone 5"
    case "iPhone5,2":  return "iPhone 5 (GSM+CDMA)"
    case "iPhone5,3":  return "iPhone 5c (GSM)"
    case "iPhone5,4":  return "iPhone 5c (GSM+CDMA)"
    case "iPhone6,1":  return "iPhone 5s (GSM)"
    case "iPhone6,2":  return "iPhone 5s (GSM+CDMA)"
    case "iPhone7,2":  return "iPhone 6"
    case "iPhone7,1":  return "iPhone 6 Plus"
    case "iPhone8,1":  return "iPhone 6s"
    case "iPhone8,2":  return "iPhone 6s Plus"
    case "iPhone8,4":  return "iPhone SE"
    case "iPhone9,1":  return "国行、日版、港行iPhone 7"
    case "iPhone9,2":  return "港行、国行iPhone 7 Plus"
    case "iPhone9,3":  return "美版、台版iPhone 7"
    case "iPhone9,4":  return "美版、台版iPhone 7 Plus"
    case "iPhone10,1","iPhone10,4":   return "iPhone 8"
    case "iPhone10,2","iPhone10,5":   return "iPhone 8 Plus"
    case "iPhone10,3","iPhone10,6":   return "iPhone X"
    case "iPhone11,8": return "iPhone XR"
    case "iPhone11,2": return "iPhone XS"
    case "iPhone11,4","iPhone11,6":   return "iPhone XS Max"
        
    case "iPad1,1":   return "iPad"
    case "iPad1,2":   return "iPad 3G"
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad 2"
    case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini"
    case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6":   return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3":   return "iPad Air"
    case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
    case "iPad5,1", "iPad5,2":  return "iPad Mini 4"
    case "iPad5,3", "iPad5,4":   return "iPad Air 2"
    case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
    case "iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
    case "AppleTV2,1":  return "Apple TV 2"
    case "AppleTV3,1","AppleTV3,2":  return "Apple TV 3"
    case "AppleTV5,3":   return "Apple TV 4"
    case "i386", "x86_64":   return "Simulator"
    default:  return identifier
    }
}

///当前vc
var currentVC : UIViewController {
    let vc = UIApplication.shared.keyWindow?.rootViewController

    if (vc?.isKind(of: type(of: UITabBarController()) as AnyClass))! {
        return (vc as! UITabBarController).selectedViewController!
    }
    
    if (vc?.isKind(of: type(of: UINavigationController()) as AnyClass))! {
        return (vc as! UINavigationController).visibleViewController!
    }
    if vc?.presentedViewController != nil {
        return vc!.presentedViewController!
    }
    
    return vc!
}



