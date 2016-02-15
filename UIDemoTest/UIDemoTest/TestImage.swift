//
//  TestImage.swift
//  UIDemoTest
//
//  Created by Conan on 12/02/16.
//  Copyright © 2016年 Conan. All rights reserved.
//

import UIKit
import CoreImage

private let defaultSize :(Float,Float) = (width: 600.0, height: 800.0)
private var btnState=[0, 1, 0, 0]
private let btnString=[["灰度图","2级灰度","16级灰度","128级灰度","256级灰度"],["ScaleToFill","AscpectFit","AspectFill","Redraw","Center","Top","Bottom","Left","Right","TopLeft","TopRight","BottomLeft","BottomRight"],
    ["保存"], ["复原"]]
private var filter:Array<CIFilter>=[]
private let configDefault:Array<Float>=[50.0,25.0,50.0,50.0]

func initImageTest(ctl: ShowController){
    let mainSize = ctl.show.frame.size
    let main = ctl.show
    
    log("initUIViewTest")
    ctl.sliderConfigs.append(ConfigSlider(n: 0, size: mainSize, max: 100, name: "亮度", defaultValue:configDefault[0]))
    ctl.sliderConfigs.append(ConfigSlider(n: 1, size: mainSize, max: 100, name: "对比度", defaultValue:configDefault[1]))
    ctl.sliderConfigs.append(ConfigSlider(n: 2, size: mainSize, max: 100, name: "饱和度", defaultValue:configDefault[2]))
    ctl.sliderConfigs.append(ConfigSlider(n: 3, size: mainSize, max: 100, name: "色温", defaultValue:configDefault[3]))
    
    ctl.sliderConfigs.forEach({
        main.addSubview($0.slider)
        main.addSubview($0.label)
        $0.slider.addTarget(ctl, action: Selector("configChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    })
    
    var x = 0
    var y = ctl.sliderConfigs.last!.slider.frame.maxY
    var btn:Array<UIButton>=[]
    for (i,j) in btnState.enumerate() {
        btn.append(UIButton(frame: CGRect(x: Int(x+i*95), y: Int(y), width: 90, height: 20)))
        btn[i].setTitle(btnString[i][j], forState: .Normal)
        btn[i].setTitleColor(UIColor.blueColor(), forState: .Normal)
        btn[i].backgroundColor=UIColor.lightGrayColor()
        btn[i].addTarget(ctl, action: Selector("configChanged:"), forControlEvents: UIControlEvents.TouchUpInside)
        btn[i].tag=i
        main.addSubview(btn[i])
    }
   
    x = 20
    y += 30
    let img=UIImageView(frame:CGRect(x: Int(x), y: Int(y), width: Int(mainSize.width)-x*2, height: Int(mainSize.height-y)))
    ctl.demo = img as AnyObject
    img.image=UIImage(named: "demo.jpg")
    img.userInteractionEnabled = false
    img.contentMode = .ScaleAspectFit
    img.layer.borderColor = UIColor.redColor().CGColor
    main.addSubview(img)
    ctl.show.bringSubviewToFront(img)

    //初始化滤镜组
    //let src=CIImage(image: img.image!)
    filter.append(CIFilter(name: "CIColorControls")!)//亮度，对比度，饱和度
    filter.last?.setValue(CIImage(image: img.image!), forKey: kCIInputImageKey)
    filter.append(CIFilter(name: "CITemperatureAndTint")!)//色温
}

func refreshImageTest(ctl: ShowController, sender: AnyObject?) {
    let img = ctl.demo as! UIImageView
    if sender is UIButton{
        let btn=sender as! UIButton
        log("Button \(btn) press, tag=\(btn.tag)")
        //按钮标题切换
        let index = sender!.tag
        btnState[index] = (btnState[index]+1) % btnString[index].count
        btn.setTitle(btnString[index][btnState[index]], forState: .Normal)
        switch index{
            case 0://灰度
                break
            case 1://位置
                img.contentMode = UIViewContentMode(rawValue: btnState[index])!
                if img.contentMode != .ScaleAspectFit{
                    img.alpha=0.5
                    img.layer.borderWidth = 2
                }
                else {
                    img.alpha=1.0
                    img.layer.borderWidth = 0
                }
            case 2: //保存
                break
            case 3: //复原
                for i in ctl.sliderConfigs { i.value=50 }
            default: break
        }
    }
    else {
        //let conf = ctl.sliderConfigs.map{$0.value}
        let arg = sender as! UISlider
        log("slider \(arg) changed")
        switch arg.tag{
        case 0://亮度   -1---1
            filter[0].setValue(arg.value/50.0-1.0, forKey: "inputBrightness")
        case 1: //  对比度   0---4
            filter[0].setValue(arg.value/25.0, forKey: "inputContrast")
        case 2://  饱和度  0---2
            filter[0].setValue(arg.value/50.0, forKey: "inputSaturation")
        case 3://  色温  1000-10000, 0-1000
            print(filter[1].attributes)
            filter[1].setValue(CIVector(x: CGFloat(arg.value*80+2000.0), y: CGFloat(arg.value)), forKey: "inputNeutral")
        default:break
        }
        // 得到过滤后的图片
        let outputImage: CIImage = filter[0].outputImage!
        filter[1].setValue(outputImage, forKey: kCIInputImageKey)
        img.image = UIImage(CIImage: filter[1].outputImage!)
    }
    
    
}