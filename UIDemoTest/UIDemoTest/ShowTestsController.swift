//
//  UIVIew.swift
//  UIDemoTest
//
//  Created by Conan on 28/12/15.
//  Copyright © 2015年 Conan. All rights reserved.
//

import UIKit

var log : (AnyObject...) -> () = {_ in }

private let defaultSliderHeight :CGFloat = 30
private let defaultLabelWidth :CGFloat = 120
private let defaultSpace: CGFloat = 10

class ConfigSlider {
    let label : UILabel
    let slider : UISlider
    let name : String
    
    init( n: Int, size : CGSize, max: Float, name: String, defaultValue: Float = 0) {
        let x = defaultSpace
        let y = defaultSpace + CGFloat(Float(defaultSliderHeight) * Float(n))
        let w = size.width - defaultSpace * 2
        
        var newFrame = CGRect(x: x, y: y, width: defaultLabelWidth, height: defaultSliderHeight)
        label = UILabel(frame: newFrame)
        label.text = name
        log("label-\(n) =\(newFrame)")
        
        newFrame = CGRect(x: x+defaultLabelWidth, y: y, width: w - defaultLabelWidth, height: defaultSliderHeight)
        slider = UISlider(frame: newFrame)
        slider.minimumValue = 0
        slider.maximumValue = Float(max)
        slider.setValue(defaultValue, animated: true)
        slider.tag=n
        log("slider-\(n) frame=\(newFrame)")
        
        self.name = name
    }
    
    var value : Float{
        get {
            label.text = name + ":\(Int(slider.value))"
            return slider.value
        }
        set(new){
            slider.setValue(new, animated: true)
            label.text = name + ":\(Int(slider.value))"
        }
    }
}


class ShowController : UIViewController {
    
    @IBOutlet weak var bar: UINavigationBar!
    @IBOutlet weak var show: UIView!
    @IBOutlet weak var logout: UITextView!
    @IBOutlet weak var btnlog: UIButton!
    
    var sliderConfigs : Array <ConfigSlider> = []
    var initDemo : (ShowController)->() = {_ in }
    var updateDemo : (ShowController,AnyObject?)->() = {_ in }
    var demo :AnyObject? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view, typically from a nib.
        log = self.mylog
        bar.topItem?.title = self.title
        btnlog.addTarget(self, action: "showOrHideLog", forControlEvents: .TouchUpInside)
        logout.editable = false
        logout.text = ""
        logout.hidden = true
        logout.layer.cornerRadius = 10.0
        self.view.bringSubviewToFront(logout)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        log("viewDidAppear: frame size=\(show.frame.size)")
        switch self.title! {
        case "普通UIView测试" :
            initDemo = initUIViewTest
            updateDemo = refreshUIViewTest
        case "获取信息" :
            initDemo = initInfoTest
            //updateDemo = refreshInfoTest
        case "图像处理" :
            initDemo = initImageTest
            updateDemo = refreshImageTest
        case "动画" :
            initDemo = initAnimationTest
            updateDemo = refreshAnimationTest
        default: break
        }
        initDemo(self)
    }
    

    func mylog (msg: AnyObject...){
        var st :String = ""
        msg.forEach{ st = st + "\($0)\t" }
        logout.text.appendContentsOf("\(NSDate()): " + st + "\n")
        print(st)
    }
    
    func showOrHideLog(){
        mylog("will "+(logout.hidden ? "show":"hide")+" the log info")
        logout.hidden = !logout.hidden
        btnlog.alpha = logout.hidden ? 0.2 : 1.0
    }
    
    func configChanged(sender: AnyObject?) {
        //log("configChanged, sender = \(sender?.name)")
        updateDemo(self,sender)
    }//End configChanged
    
    
    func savedImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutablePointer<Void>) {
        if error == nil {
            let alert = UIAlertController(title: "", message: "Success", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            print(error)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //log("view Layout will change!")
    }
    
    func orientChange(noti: NSNotification) {
        //var ntfDict: [NSObject : AnyObject] = noti.userInfo!
        //var orient: UIDeviceOrientation = UIDevice.currentDevice().orientation
        log("orientChange!")
        if self.title! == "获取信息" {
            guard demo != nil else { return }
            refreshInfoTest(self, sender: self)
        }
    }
}//End all in controller


