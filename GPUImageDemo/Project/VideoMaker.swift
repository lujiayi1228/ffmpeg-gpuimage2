//
//  VideoMaker.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/27.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class VideoMaker: NSObject {
    
    private var progressHandle : ((Float)->())?
    
    private var finishHandle : ((Error?)->())?
    
    //视频载体
    lazy var preview: GPUImageView = {
        let fview = GPUImageView(frame: screenFrame)
        return fview
    }()
    
    //视频保存路径,合成视频后删除文件
    private let videoPath = documentPath! + "/ImagesToVideo"
    
    /// 图片合成视频
    ///
    /// - Parameters:
    ///   - images: 图片集合
    ///   - duration: 视频总时长(每张图片持续时间一样)
    ///   - progress: 合成进度
    ///   - finished: error = nil 完成
    func makeVideo(withImages images: [UIImage], duration:Float , progress:@escaping (Float)->(), finished: @escaping(Error?)->()) {
        progressHandle = progress
        finishHandle = finished
        moveImagesToSandBox(images: images,duration: duration)
    }
    
    //将图片保存进沙盒，相册导入的image没有路径，ffmpeg合成需要路径
    func moveImagesToSandBox(images:[UIImage],duration:Float) {
        createVideoFolder()
        for index in 0..<images.count {
            let image = images[index]
            let file = videoPath + String(format: "/%05d.png", index)
            let frame = CGRect(x: 0, y: 0, width: 720, height: 1280)
            let newFrame = scaleImage(image: image)
            UIGraphicsBeginImageContext(frame.size)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(blackColor.cgColor)
            UIRectFill(frame)
            image.draw(in: newFrame)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            let imageData = newImage.pngData()
            do {
                try imageData?.write(to: URL(fileURLWithPath: file))
            } catch let error as NSError {
                print("error:\(error)")
                finishHandle!(error)
                return
            }
            UIGraphicsEndImageContext()
        }
        
        let manager = FFmpegManager.shared()
        manager?.makeVideo(byImages: videoPath,imageCount:Int32(images.count), interval: duration/Float(images.count), processBlock: progressHandle, completionBlock: finishHandle)
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
    
    //创建文件夹，视频最终合成之后将会删除
    private func createVideoFolder() {
        let fileManager = FileManager.default
        var isDir : ObjCBool = ObjCBool(false)
        let isExist = fileManager.fileExists(atPath: videoPath, isDirectory: &isDir)
        if !(isDir.boolValue && isExist) {
            do {
                try fileManager.createDirectory(atPath: videoPath, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("recordvideo文件夹创建失败")
            }
        }
    }
    
}
