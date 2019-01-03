//
//  TestViewController.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/12.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    lazy var imageV: UIImageView = {
        let imageV = UIImageView (frame: screenFrame)
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    
    var images : [UIImage]?
    
    
    init(images:[UIImage]) {
        super.init(nibName: nil, bundle: nil)
        self.images = images
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.addSubview(self.imageV)
        configImage(images: self.images!)
    }
    
    func configImage(images:[UIImage]) {
        
        
        let frame = CGRect(x: 0, y: 0, width: 720, height: 1280)
        let newFrame1 = scaleImage(image: images.first!)
        let newFrame2 = scaleImage(image: images.last!)
        
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(blackColor.cgColor)
        
        UIRectFill(frame)
        images.first!.draw(in: newFrame1, blendMode: .normal, alpha: 0.9)
        images.last!.draw(in: newFrame2, blendMode: .normal, alpha: 0.1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
//        let imageData = newImage.pngData()
//        do {
//            try imageData?.write(to: URL(fileURLWithPath: file))
//        } catch let error as NSError {
//            print("error:\(error)")
//            finishHandle!(error,nil)
//            return
//        }
        self.imageV.image = newImage
        UIGraphicsEndImageContext()
    }
    
    private func scaleImage(image:UIImage) -> CGRect {
        var rect = CGRect()
        let asize = CGSize(width: 720, height: 1280)
        let oldsize = image.size
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        return rect
    }

}
