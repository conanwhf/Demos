//
//  TestGetInfo.swift
//  UIDemoTest
//
//  Created by Conan on 12/02/16.
//  Copyright © 2016年 Conan. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import NetworkExtension

private var staticInfo = ""
private var dyInfo = ""

/**
 Get SSID if WIFI connected
 
 - returns: SSID
 */
func getSSID() -> String {
    let interfaces = CNCopySupportedInterfaces()
    guard interfaces != nil else{ return "" }

    let if0: UnsafePointer<Void>? = CFArrayGetValueAtIndex(interfaces!, 0)
    guard if0 != nil else{ return "" }

    let interfaceName: CFStringRef = unsafeBitCast(if0!, CFStringRef.self)
    let dictionary = CNCopyCurrentNetworkInfo(interfaceName) as NSDictionary?
    guard dictionary != nil else{ return "" }

    return String(dictionary![String(kCNNetworkInfoKeySSID)]!)
}

/**
 System info
 
 - returns: Raw Data
 */
func getSystemInfo()-> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    var temp:Array<NSString>=[]
    temp.append(NSString(bytes: &systemInfo.sysname, length: 255, encoding: NSASCIIStringEncoding)!)
    temp.append(NSString(bytes: &systemInfo.nodename, length: 255, encoding: NSASCIIStringEncoding)!)
    temp.append(NSString(bytes: &systemInfo.release, length: 255, encoding: NSASCIIStringEncoding)!)
    temp.append(NSString(bytes: &systemInfo.version, length: 255, encoding: NSASCIIStringEncoding)!)
    temp.append(NSString(bytes: &systemInfo.machine, length: 255, encoding: NSASCIIStringEncoding)!)
    let info=temp.map{String(UTF8String: $0.UTF8String)!}
    let mechine = info.last!
    
    if mechine.hasPrefix("i386") || mechine.hasPrefix("x86"){
        return "设备型号：模拟器\n"
    }
    
    guard var range=mechine.rangeOfString(",") else{return "设备型号： 未知\n"}
    range.startIndex = range.startIndex.predecessor()
    var dev=mechine.substringToIndex(range.startIndex)
    let version=mechine.substringFromIndex(range.startIndex)
    
    print("dev=\(dev), version=\(version)")
    if dev=="iPhone" {//iPhone
        switch version {
            case "3,1", "3,2", "3,3":  dev += "4"
            case "4,1", "4,2", "4,3":   dev += "4s"
            case "5,1", "5,2":             dev += "5"
            case "5,3", "5,4":             dev += "5c"
            case "6,1", "6,2":             dev += "5s"
            case "7,2":                       dev += "6"
            case "7,1":                       dev += "6plus"
            case "8,1":                       dev += "6s"
            case "8,2":                    dev += "6Splus"
            default: break
        }
    }
    
    if dev=="iPad" {//iPad
        switch version {
            case "1,1":                     dev += "1"
            case "2,1", "2,2", "2,3","2,4":   dev += "2"
            case "2,5", "2,6", "2,7":   dev += "Mini"
            case "3,1", "3,2","3,3":    dev += "3"
            case "3,4", "3,4","3,6":     dev += "4"
            case "4,1", "4,2","4,3":      dev += "Air"
            case "4,4","4,5","4,6":        dev += "Mini2"
            case "4,7","4,8","4,9":       dev += "Mini3"
            case "5,1","5,2":                       dev += "Mini4"
            case "5,3","5,4":                    dev += "Air2"
            case "6,8":                    dev += "Pro"
            default: break
        }
    }

    if dev=="iPod" {//iPodTouch
        let v = Int(String(version[version.startIndex]))
        dev += (v>6 ? "Touch6" : "Touch\(v)")
    }
    
    return "设备型号： \(dev)\n"//sysname, nodename, release, version, machine
}


func getDeviceInfo()-> (info: String, state: String){
    var info:Array<String>=[]
    //let orientaionMode=["Unknown","Portrait","PortraitUpsideDown","LandscapeLeft","LandscapeRight","FaceUp","FaceDown"]
    let orientaionMode=["未知(Unknown)","竖屏(Portrait)","倒置竖屏(PortraitUpsideDown)","左横屏(LandscapeLeft)","右横屏(LandscapeRight)","向上平置(FaceUp)","向下翻转(FaceDown)"]
    //let batteryMode=["Unknown","Unplugged","Charging","Full"]
                                                    // on battery, discharging | plugged in, less than 100% |  plugged in, at 100%
    let batteryMode=["未知(Unknown)","未插电(Unplugged)","充电中(Charging)","已充满(Full)"]

    info.append(UIDevice.currentDevice().name)//测试机 ==0
    info.append("\(Int(UIDevice.currentDevice().batteryLevel*100))%")//0-1.0, -1 if unknow
    info.append(batteryMode[UIDevice.currentDevice().batteryState.rawValue])    //==2
    info.append(String(UIDevice.currentDevice().identifierForVendor))//Optional(<__NSConcreteUUID 0x15de8be0> 407C15C3-9323-411F-974C-2209B583798A) ==3
    info.append(UIDevice.currentDevice().localizedModel)//iPhone    ==4
    info.append(UIDevice.currentDevice().model)//iPhone ==5
    info.append(orientaionMode[UIDevice.currentDevice().orientation.rawValue])//   ==6
    info.append(UIDevice.currentDevice().systemName)//iPhone OS ==7
    info.append(UIDevice.currentDevice().systemVersion)//9.2    ==8
    info[3] = String(info[3].componentsSeparatedByString(" ").last!.characters.dropLast())
    
    let st1="这台 \(info[4]) 名叫 \(info[0]) \n操作系统 \(info[7]) 版本 \(info[8])\nUUID: \(info[3]) \n"
    let st2="电池状态: \(info[2]) ，电量 \(info[1]) \n持机状态: \(info[6]) \n"
    /*info.append(st)
    return info //name, batteryLevel, batteryState, ID, LocalizedModel, model, orientation, systemName, systemVersion
*/
    return (st1,st2)
}

/**
 Screen Info
 
 - returns:width:Int, height:Int, inch:Float, A info for description:String
 */
func getScreenInfo()->(width:Int, height:Int, inch:Float, info:String){
    var w:Int = Int(UIScreen.mainScreen().bounds.size.width)
    var h:Int = Int(UIScreen.mainScreen().bounds.size.height)
    let scale=UIScreen.mainScreen().scale
    var inch:Float = 0.0
    /*
    if w>h {
        let temp = w;  w = h;   h = temp
    }*/
    switch max(w,h) {
        case 480: inch = 3.5
        case 568: inch = 4.0
        case 667: inch = (scale == 3.0) ? 5.5 : 4.7
        case 736: inch = 5.5
        default: break
    }
    w=w*Int(scale)
    h=h*Int(scale)
    let st="屏幕大小 \(inch)英寸， 像素 \(w)*\(h)\n"
    return (w, h, inch, st)
}


func initInfoTest(ctl: ShowController){
    let main = ctl.show
    let frame = CGRect(x: 20, y: 20, width: main.frame.width-40, height: main.frame.height-40)
    let infoText=UITextView(frame: frame)
    
    //静态信息
    if staticInfo.isEmpty{
        staticInfo.appendContentsOf("\t\t\t系统&设备信息\n")
        staticInfo.appendContentsOf(getSystemInfo())
        staticInfo.appendContentsOf(getDeviceInfo().info)
        //运营商，日期，APP信息
    }
    
    //动态信息
    dyInfo.appendContentsOf("\t\t\t状态信息\n")
    dyInfo.appendContentsOf(getScreenInfo().info)
    dyInfo.appendContentsOf(getDeviceInfo().state)
    var ssid = getSSID()
    if ssid.isEmpty {   ssid="WIFI状态： 未连接\n"  }
        else { ssid = "WIFI状态： \(ssid) 已连接\n"  }
    dyInfo.appendContentsOf(ssid)
    
    
    infoText.text = staticInfo + "\n\n"+dyInfo
    infoText.userInteractionEnabled = false
    main.addSubview(infoText)
    ctl.demo = infoText as AnyObject
}

func refreshInfoTest(ctl: ShowController, sender: AnyObject?) {
    let infoText = ctl.demo as! UITextView

    //动态信息更新
    dyInfo="\t\t\t状态信息\n"
    dyInfo.appendContentsOf(getScreenInfo().info)
    dyInfo.appendContentsOf(getDeviceInfo().state)
    var ssid = getSSID()
    if ssid=="" {   ssid="WIFI状态： 未连接\n"  }
    else { ssid = "WIFI状态： \(ssid) 已连接\n"  }
    dyInfo.appendContentsOf(ssid)
    
    infoText.text = staticInfo + "\n\n"+dyInfo
}