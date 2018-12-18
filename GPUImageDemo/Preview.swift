//
//  Preview.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/6.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Preview: UIView {

    private var items : [UIImageView] = []
    
    var screenImages : [UIImage] = []
    
    private var link: CADisplayLink?
    
    private var animationing : Bool = false
    
    var fps : CGFloat = 60.0
    
    var shotProgress : Int = 1
    
    var animationTag = 0
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        self.changeItemsCenter(center: center)
    }
    
    func changeItemsCenter(center: CGPoint) {
        if animationTag >= self.items.count {
            self.animationing = false
            self.link?.isPaused = true
            self.link?.invalidate()
            self.link = nil
            return
        }
        
        let imageV = self.items[animationTag]
        switch animationTag {
        case 0:
            let centerX = imageV.center.x + 1
            imageV.center.x = centerX
            break
        case 1:
            let centerY = imageV.center.y + 1
            imageV.center.y = centerY
            break
        case 2:
            let centerX = imageV.center.x - 1
            imageV.center.x = centerX
            break
        case 3:
            let centerY = imageV.center.y - 1
            imageV.center.y = centerY
            break
        default:
            break
        }
        
        if Int(imageV.center.x) == Int(center.x) || Int(imageV.center.y) == Int(center.y){
            animationTag += 1
        }
    }

    func startAnimation(images: [UIImage]) {
        guard !self.animationing else {
            return
        }
        self.animationing = true
        self.animationTag = 0
        for view in self.subviews {
            view.removeFromSuperview()
        }
        self.items.removeAll()
        
        var flag = 0
        for image in images {
            let imageV = UIImageView(image: image)
            imageV.backgroundColor = UIColor.cyan
            switch flag%4 {
            case 0:
                imageV.frame = CGRect(x: -100, y: 50, width: 100, height: 100)
                break
            case 1:
                imageV.frame = CGRect(x: 50, y: -100, width: 100, height: 100)
                break
            case 2:
                imageV.frame = CGRect(x: self.frame.width, y: 50, width: 100, height: 100)
                break
            case 3:
                imageV.frame = CGRect(x: 50, y: self.frame.height, width: 100, height: 100)
                break
            default:
                break
            }
            self.addSubview(imageV)
            self.items.append(imageV)
            flag += 1
        }
        
        self.link = CADisplayLink(target: self, selector: #selector(screenshots))
        self.link?.add(to: RunLoop.current, forMode: .default)
        self.link?.isPaused = false
    }
    
    @objc private func screenshots() {
        self.setNeedsDisplay()
        UIGraphicsBeginImageContext(self.bounds.size)
        let context = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.screenImages.append(image!)
    }
    
}
