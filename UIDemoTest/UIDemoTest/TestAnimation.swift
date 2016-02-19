//
//  animation.swift
//  UIDemoTest
//
//  Created by Conan on 17/02/16.
//  Copyright © 2016年 Conan. All rights reserved.
//

import UIKit
import QuartzCore

private let magicButtonTag=0x3344
private var animationState = 0

struct AnimationObject {
    var name:String = ""
    var doit : (ShowController, Bool)->() = {_ in}
    //var end : (ShowController)->() = {_ in}
    func stop(ctl:ShowController){
        let main = ctl.show
        for i in main.subviews{
            if i.tag != magicButtonTag{ i.removeFromSuperview()}
        }
    }
}
private var animations:Array<AnimationObject>=[]
private var timerHandler: ()->() =  { _ in }

//粒子雪花特效
private func snowView(ctl:ShowController, add:Bool){
    class SnowView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let emitter = layer as! CAEmitterLayer
            emitter.emitterPosition = CGPoint(x: bounds.size.width / 2, y: 0)
            emitter.emitterSize = bounds.size
            emitter.emitterShape = kCAEmitterLayerRectangle
            
            let emitterCell = CAEmitterCell()
            emitterCell.contents = UIImage(named: "demo_small.png")!.CGImage
            emitterCell.birthRate = 200
            emitterCell.lifetime = 3.5
            emitterCell.color = UIColor.whiteColor().CGColor
            emitterCell.redRange = 0.0
            emitterCell.blueRange = 0.1
            emitterCell.greenRange = 0.0
            emitterCell.velocity = 10
            emitterCell.velocityRange = 350
            emitterCell.emissionRange = CGFloat(M_PI_2)
            emitterCell.emissionLongitude = CGFloat(-M_PI)
            emitterCell.yAcceleration = 70
            emitterCell.xAcceleration = 0
            emitterCell.scale = 0.33
            emitterCell.scaleRange = 1.25
            emitterCell.scaleSpeed = -0.25
            emitterCell.alphaRange = 0.5
            emitterCell.alphaSpeed = -0.15
            
            emitter.emitterCells = [emitterCell]
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override class func layerClass() -> AnyClass {
            return CAEmitterLayer.self
        }
        
    }
    
    let main = ctl.show
    if add {//添加动画
        let test = SnowView(frame: main.frame)
        main.addSubview(test)
    }
}

//环形进度条
private func cycleProcess(ctl:ShowController, add:Bool){
    class LoopProgressView: UIView {
        var ViewWidth:CGFloat=0
        let ProgressWidth:CGFloat = 2.5 //环形进度条的圆环宽度
        var Radius :CGFloat=0
        var process=123  //0-1000
        var label:UILabel?=nil
        var progressTimer:NSTimer?
        let arcLayer = CAShapeLayer.init()
        weak var ctl:ShowController?=nil
        
        init(frame: CGRect, ctrl : ShowController ) {
            super.init(frame: frame)
            
            self.backgroundColor = UIColor.clearColor()
            ViewWidth = frame.size.width                        //环形进度条的视图宽度
            Radius = ViewWidth / 2 - ProgressWidth      //环形进度条的半径
            ctl=ctrl
            
            label = UILabel(frame: CGRectMake(0, 0, Radius + 10, 20))
            label!.textAlignment = .Center
            label!.center = CGPoint(x: frame.width/2, y: frame.height/2)
            label!.font = UIFont.boldSystemFontOfSize(15.0)
            label!.text = "0%"
            self.addSubview(label!)
            
            arcLayer.fillColor = UIColor.clearColor().CGColor
            arcLayer.strokeColor = UIColor(red: 227.0 / 255.0, green: 91.0 / 255.0, blue: 90.0 / 255.0, alpha: 0.7).CGColor
            arcLayer.lineWidth = ProgressWidth
            arcLayer.backgroundColor = UIColor.blueColor().CGColor
            self.layer.addSublayer(arcLayer)

        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func drawRect(rect: CGRect) {
            let progressContext: CGContextRef = UIGraphicsGetCurrentContext()!
            CGContextSetLineWidth(progressContext, ProgressWidth)
            CGContextSetRGBStrokeColor(progressContext, 209.0 / 255.0, 209.0 / 255.0, 209.0 / 255.0, 1)
            let xCenter: CGFloat = rect.size.width * 0.5
            let yCenter: CGFloat = rect.size.height * 0.5
            //绘制环形进度条底框
            CGContextAddArc(progressContext, xCenter, yCenter, Radius, 0,CGFloat(2.0 * M_PI), 0)
            CGContextDrawPath(progressContext, .Stroke)
            //绘制环形进度环
            let angle: CGFloat = CGFloat(Double(process) * M_PI / 500.0)  //进度条的完成角度, 0-1000转换成角度
            //print("process=\(process), angle=\(angle)")
            let path: UIBezierPath = UIBezierPath()
            path.addArcWithCenter(CGPointMake(xCenter, yCenter), radius: Radius, startAngle: 0, endAngle: angle, clockwise: true)
            arcLayer.path = path.CGPath
            dispatch_async(dispatch_get_global_queue(0, 0), {() -> Void in
                self.drawLineAnimation(self.arcLayer)
            })
            if (progressTimer == nil) && (process != -1){
                progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: ctl!, selector: "timerDone", userInfo: nil, repeats: true)
            }
        }
        func update() {
            process += Int(arc4random() % UInt32(10))//随机调整进度
            if process>1000 {process=1000}
            label?.text = String(format: "%.1f%%", Double(process)/10.0)
            setNeedsDisplay()
            if process >= 1000 { stopTimer() }
        }
        
        //定义动画过程
        func drawLineAnimation(layer: CALayer) {
            let bas: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            bas.duration = 1
            bas.fromValue = Int(0)
            bas.toValue = Int(1)
            layer.addAnimation(bas, forKey: "key")
        }
        
        func stopTimer(){
            progressTimer?.invalidate()
            progressTimer = nil
            process = -1
        }
        
        deinit{
            log("cycleProcess release")
            label=nil
        }
    }
    
    var test:LoopProgressView? = nil
    if add {//添加动画
        let frame = CGRect(x: 10, y: 10, width: ctl.show.frame.width-20, height: ctl.show.frame.width-20)
        test=LoopProgressView(frame: frame, ctrl: ctl)
        timerHandler = test!.update
        ctl.show.addSubview(test!)
    }
    else{//其他特殊清理动作
        test?.stopTimer()
        test=nil
    }
}

//基本实现方法
private func baseAnimation(ctl:ShowController, add:Bool){
    let main = ctl.show
    if add {//添加动画
        let view=UIImageView()
        view.image=UIImage(named: "demo.jpg")
        main.addSubview(view)
        
        view.layer.position = CGPointMake(100, 100)
        view.layer.bounds = CGRectMake(0, 0, 100, 100)
        view.backgroundColor = UIColor.blueColor()

        // 创建一个CABasicAnimation类型的动画对象并对CALayer的position属性执行动画
        let anim: CABasicAnimation = CABasicAnimation(keyPath: "position")
        // 动画持续1.5s
        anim.duration = 5
        // position属性值从(50, 80)渐变到(300, 350)
        anim.fromValue = NSValue(CGPoint: CGPointMake(50, 80))
        anim.toValue = NSValue(CGPoint: CGPointMake(300, 350))
        // 设置动画的代理
        anim.delegate = ctl
        // 保持动画执行后的状态
        anim.removedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        // 添加动画对象到myView的图层上
        view.layer.addAnimation(anim, forKey: "translate")
    }
    else{//其他特殊清理动作
   }
}

//抖动效果
private func shakeAnimation(ctl:ShowController, add:Bool) {
    let main = ctl.show
    if add {//添加动画
        let frame = CGRect(x: 25, y: 25, width: main.frame.width-50, height: main.frame.width-50)
        let view=UIImageView(frame: frame)
        view.image=UIImage(named: "demo.jpg")
        view.layer.masksToBounds = true;
        view.layer.cornerRadius = view.frame.height/2
        main.addSubview(view)
        
        // 获取当前View的位置
        let position: CGPoint = view.layer.position
        // 移动的两个终点位置
        let x: CGPoint = CGPointMake(position.x + 10, position.y)
        let y: CGPoint = CGPointMake(position.x - 10, position.y)
        // 设置动画
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        // 设置运动形式
        animation.timingFunction = CAMediaTimingFunction(name: "default")
        // 设置开始位置
        animation.fromValue = NSValue(CGPoint: x)
        // 设置结束位置
        animation.toValue = NSValue(CGPoint: y)
        // 设置自动反转
        animation.autoreverses = true
        // 设置时间
        animation.duration = 0.1
        // 设置次数
        animation.repeatCount = 5
        // 添加上动画
        view.layer.addAnimation(animation, forKey: nil)
        
    }
    else{//其他特殊清理动作
        
    }
   }

/*图片数组轮播*/
private func imageArray(ctl:ShowController, add:Bool){
    let main = ctl.show
    if add {//添加动画
        let imgView = UIImageView(frame:CGRectMake(50, 10, 200.0,  200.0))
        //（1）图片数组（animationImages. animationImages里面一定要装的是UIImage 不能是图片的名称字符串
        imgView.animationImages = []
        for i in 0...7 {
            imgView.animationImages?.append(UIImage(named: "\(i).tiff")!)
        }
        //（2）一轮动画时间的持续时间(animationDuration)
        imgView.animationDuration = 1.0;
        //（3）动画重复次数（animationRepeatCount，0的意思是这个动画一直进行不会停下来 其他数字表示重复动画的次数
        imgView.animationRepeatCount = 0;
        //在以上（1）～（3）都设置好的前提下，开始动画
        main.addSubview(imgView)
        imgView.startAnimating()
    }
    else{//其他特殊清理动作
        
    }
}

/*通过超类UIView的方法一： Animatrions() */
private func scaleUIView(ctl:ShowController, add:Bool){
    let main = ctl.show
    if add {//添加动画
        let view = UIImageView(frame:CGRectMake(50, 50, 100.0,  100.0))
        view.image=UIImage(named: "demo.jpg")
        main.addSubview(view)
        
        //(开始动画）
        UIView.beginAnimations(nil, context: nil)
        //动画持续时间
        UIView.setAnimationDuration(5.0)
        //［注意］动画必须放在开始（ beginAnimations）和提交（commitAnimations）中间
        //不允许单独直接修改结构体frame中的任何一个元素，通过创建一个rect结构体来作为中介改变其中的值
        var rect:CGRect = view.frame
        //设定view的最终frame
        rect.size=CGSize(width: 500, height: 500)
        view.frame = rect
        //提交动画
        UIView.commitAnimations()
    }
    else{//其他特殊清理动作
    }
}

/*通过超类UIView的方法二： animateWithDuration() */
private func rotateUIView(ctl:ShowController, add:Bool){
    let main = ctl.show
    if add {//添加动画
        let view = UIImageView(frame:CGRectMake(50, 50, 100.0,  100.0))
        view.image=UIImage(named: "demo.jpg")
        main.addSubview(view)
        let view2 = UIView(frame: CGRect(x: 100, y: 300, width: 100, height: 100))
        view2.backgroundColor=UIColor.blackColor()
        main.addSubview(view2)
        
        //利用仿色变换旋转UI
        UIView.animateWithDuration(5, animations: {() -> Void in
            view.transform = CGAffineTransformRotate(view.transform, CGFloat(M_PI))
            view2.backgroundColor=UIColor.yellowColor()
        })
    }
    else{//其他特殊清理动作
    }
}

/*通过超类UIView的方法三： animateWithDuration()+ */
private func moveUIView(ctl:ShowController, add:Bool){
    let main = ctl.show
    if add {//添加动画
        let view = UIImageView(frame:CGRectMake(50, 0, 150.0,  150.0))
        view.image=UIImage(named: "demo.jpg")
        main.addSubview(view)
        
        UIView.animateWithDuration(5.0, delay: 0.5, usingSpringWithDamping: 0.15, initialSpringVelocity: 2.5, options: .CurveEaseInOut, animations: {() -> Void in
            // code...
            var point: CGPoint = view.center
            point.y += 250
            view.center = point
            }, completion: {(finished: Bool) -> Void in
                // 动画完成后执行
                view.alpha = 0.5
        })
    }
    else{//其他特殊清理动作
    }
}

//通过超类UIView的方法四：关键帧（彩虹变化）
private func rainbow(ctl:ShowController, add:Bool){
    let main = ctl.show
    if add {//添加动画
        let view = UIView(frame: CGRect(x: 30, y: 20, width: 200, height: 200))
        main.addSubview(view)
        let keyFrameBlock = {() -> Void in
            // 创建颜色数组
            var arrayColors = [UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.redColor(), UIColor.blackColor()]
            let colorCount = Double(arrayColors.count)
            // 循环添加关键帧
            for var i = 0; i < Int(colorCount); i++ {
                UIView.addKeyframeWithRelativeStartTime( Double(i) / colorCount, relativeDuration: 1.0 / colorCount, animations: {() -> Void in
                    view.backgroundColor = arrayColors[i]})
            }
        }
        UIView.animateKeyframesWithDuration(4.0, delay: 1.0, options: [.CalculationModeCubic, .CalculationModeLinear], animations: keyFrameBlock, completion: {(finished: Bool) -> Void in
            //TODO: 动画完成后执行
        })
    }
    else{//其他特殊清理动作
    }
}

func initAnimationTest(ctl: ShowController){
    let main = ctl.show
    let btn_w:CGFloat = 180
    let btn_h:CGFloat = 40
    let frame = CGRect(x: (main.frame.width-btn_w)/2, y: (main.frame.height-btn_h)/2, width: btn_w, height: btn_h)
    let btn=UIButton(frame: frame)
    
    //初始化动画
    animations.append(AnimationObject(name: "点击开始", doit: {_ in}))
    animations.append(AnimationObject(name: "图片轮播", doit: imageArray))
    animations.append(AnimationObject(name: "UIView超类(缩放)", doit: scaleUIView))
    animations.append(AnimationObject(name: "UIView超类(旋转)", doit: rotateUIView))
    animations.append(AnimationObject(name: "UIView超类(移动)", doit: moveUIView))
    animations.append(AnimationObject(name: "UIView超类(关键帧)", doit: rainbow))
    animations.append(AnimationObject(name: "基本动画实现模板", doit: baseAnimation))
    animations.append(AnimationObject(name: "抖(晃)动效果", doit: shakeAnimation))
    animations.append(AnimationObject(name: "粒子雪花特效", doit: snowView))
    animations.append(AnimationObject(name: "环形进度条", doit: cycleProcess))
    
    //按钮设置
    btn.setTitle(animations.first?.name, forState: .Normal)
    btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    btn.backgroundColor=UIColor.blueColor()
    btn.layer.cornerRadius = 10.0
    btn.layer.masksToBounds = true;
    btn.addTarget(ctl, action: Selector("configChanged:"), forControlEvents: UIControlEvents.TouchUpInside)
    btn.tag=magicButtonTag
    main.addSubview(btn)
}

func refreshAnimationTest(ctl: ShowController, sender: AnyObject?) {
    
    if (sender != nil){
        let main = ctl.show
        let btn=sender as! UIButton
        
        if animationState != 0 {//非初始状态
            animations[animationState].doit(ctl, false)
            animations[animationState].stop(ctl)
        }
        animationState = (animationState+1) % animations.count
        btn.setTitle(animations[animationState].name, forState: .Normal)
        animations[animationState].doit(ctl, true)
        main.bringSubviewToFront(btn)
    }
    else {//动画timer
        timerHandler()
    }
}