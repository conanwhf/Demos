//
//  TestUIView.swift
//  UIDemoTest
//
//  Created by Conan on 29/12/15.
//  Copyright © 2015年 Conan. All rights reserved.
//

import UIKit

private let defaultSize :(Float,Float) = (width: 300.0, height: 400.0)

func initUIViewTest(ctl: ShowController){
    let mainSize = ctl.show.frame.size
    let main = ctl.show

    log("initUIViewTest")
    ctl.sliderConfigs.append(ConfigSlider(n: 0, size: mainSize, max: Float(mainSize.width), name: "宽", defaultValue:defaultSize.0))
    ctl.sliderConfigs.append(ConfigSlider(n: 1, size: mainSize, max: Float(mainSize.height), name: "高", defaultValue:defaultSize.1))
    ctl.sliderConfigs.append(ConfigSlider(n: 2, size: mainSize, max: 255, name: "颜色R"))
    ctl.sliderConfigs.append(ConfigSlider(n: 3, size: mainSize, max: 255, name: "颜色G"))
    ctl.sliderConfigs.append(ConfigSlider(n: 4, size: mainSize, max: 255, name: "颜色B"))
    ctl.sliderConfigs.append(ConfigSlider(n: 5, size: mainSize, max: 255, name: "Alpha", defaultValue:200.0))
    ctl.sliderConfigs.append(ConfigSlider(n: 6, size: mainSize, max: max(Float(mainSize.width), Float(mainSize.height)), name: "圆角"))
    ctl.sliderConfigs.append(ConfigSlider(n: 7, size: mainSize, max: 360, name: "旋转"))

    ctl.sliderConfigs.forEach({
        main.addSubview($0.slider)
        main.addSubview($0.label)
        $0.slider.addTarget(ctl, action: Selector("configChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    })
    
    let x = (Float(mainSize.width) - defaultSize.0)/2
    let y = (Float(mainSize.height) - defaultSize.1)/2
    let back = UIView(frame: CGRect(x: Int(x), y: Int(y), width: Int(defaultSize.0), height: Int(defaultSize.1)))
    ctl.demo = back as AnyObject
    //back.backgroundColor = UIColor.blackColor()
    back.userInteractionEnabled = false
    main.addSubview(back)
    ctl.show.bringSubviewToFront(back)
}//End Init


func refreshUIViewTest(ctl: ShowController) {
    let back = ctl.demo as! UIView
    let conf = ctl.sliderConfigs.map{$0.value}

    //log("refreshUIViewTest, conf=\(conf)")
    back.setNeedsLayout()
    back.backgroundColor = UIColor(colorLiteralRed: conf[2]/255.0, green: conf[3]/255.0, blue: conf[4]/255.0, alpha: conf[5]/255.0)
    back.layer.cornerRadius = CGFloat(conf[6])
    
    if (conf.count>7) {//Way 1，使用transform，可旋转
        let sx = CGFloat(conf[0] / defaultSize.0)
        let sy = CGFloat(conf[1] / defaultSize.1)
        let transf = CGAffineTransformMakeRotation(  CGFloat(Double(conf[7]) * M_PI  / 180.0))
        back.transform = CGAffineTransformScale(transf, sx, sy)
    }
    else{ //Way 2 ,修改Frame以调整大小和位置，但无法旋转
        let x = (Float(ctl.show.frame.width) - conf[0] )/2
        let y = (Float(ctl.show.frame.height) - conf[1] )/2
        back.frame.size = CGSize(width: CGFloat(conf[0]), height: CGFloat(conf[1]))
        back.frame.origin = CGPoint(x: Int(x), y: Int(y))
    }
    back.layoutIfNeeded()
    log("after change, back=\(back)")
}//End updateDemo
