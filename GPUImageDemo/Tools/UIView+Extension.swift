//
//  UIView+Extension.swift
//  FirstSwiftApp
//
//  Created by weijieMac on 2018/8/10.
//  Copyright © 2018年 Mac. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    enum Direction {
        case fromLeftToRight
        case fromRightToLeft
        case fromTopToBottom
        case fromBottomToTop
    }
    
    var left : CGFloat {
        set {
            self.frame.origin.x = newValue
        }
        get {
          return self.frame.origin.x
        }
    }
    
    var top : CGFloat {
        set {
            self.frame.origin.y = newValue
        }
        get {
            return self.frame.origin.y
        }
    }

    var width : CGFloat {
        set {
            self.frame.size.width = newValue
        }
        get {
            return self.frame.size.width
        }
    }
    
    var height : CGFloat {
        set {
            self.frame.size.height = newValue
        }
        get {
            return self.frame.size.height
        }
    }
    
    var right : CGFloat {
        set {
            self.left = newValue - self.width
        }
        get {
            return self.left + self.width
        }
    }
    
    var bottom : CGFloat {
        set {
            self.top = newValue - self.height
        }
        get {
            return self.top + self.height
        }
    }
    
    var centerX : CGFloat {
        set {
            self.center.x = newValue
        }
        get {
            return self.center.x
        }
    }
    
    var centerY : CGFloat {
        set {
            self.center.y = newValue
        }
        get {
            return self.center.y
        }
    }
    
    func setShaderBGColor(direction: Direction, startPointColor: UIColor, endPointColor: UIColor) {
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.colors = [startPointColor.cgColor,endPointColor.cgColor]
        
        switch direction {
        case .fromLeftToRight:
            layer.startPoint = CGPoint(x: 0, y: 0);
            layer.endPoint = CGPoint(x: 1.0, y: 0);
        case .fromRightToLeft:
            layer.startPoint = CGPoint(x: 1.0, y: 0);
            layer.endPoint = CGPoint(x: 0, y: 0);
        case .fromTopToBottom:
            layer.startPoint = CGPoint(x: 0, y: 0);
            layer.endPoint = CGPoint(x: 0, y: 1.0);
        case .fromBottomToTop:
            layer.startPoint = CGPoint(x: 0, y: 1.0);
            layer.endPoint = CGPoint(x: 0, y: 0);
        }
        self.layer.addSublayer(layer)
    }
    
}

