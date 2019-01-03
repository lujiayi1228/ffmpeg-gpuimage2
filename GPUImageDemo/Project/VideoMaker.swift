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
    
    private var finishHandle : ((Error?,URL?)->())?
    
    private let imageFrame = CGRect(x: 0, y: 0, width: 720, height: 1280)
    
    //视频保存路径,合成视频后删除文件
    private let videoPath = documentPath! + "/ImagesToVideo"
    
    //将照片处理成720*1280，并保存
    private var images : [UIImage] = []
    
    //存储输出的多个video//方法3
    private var outputPaths : [String] = []
    
    /// 图片合成视频
    ///
    /// - Parameters:
    ///   - images: 图片集合
    ///   - duration: 视频总时长(每张图片持续时间一样)
    ///   - progress: 合成进度
    ///   - finished: error = nil 完成
    func makeVideo(withImages images: [UIImage], interval:Float , progress:@escaping (Float)->(), finished: @escaping(Error?,URL?)->()) {
        progressHandle = progress
        finishHandle = finished
        print("__________________开始制作视频")
        createVideoFolder()
//        moveImagesToSandBox(images: images,interval: interval)
//        makeImagesForVideo(images: images, interval: interval)
        
    }
    
    //将图片保存进沙盒，相册导入的image没有路径，ffmpeg合成需要路径
    private func moveImagesToSandBox(images:[UIImage],interval:Float) {
        for index in 0..<images.count {
            let image = images[index]
            let file = videoPath + String(format: "/%05d.png", index)
            let frame = CGRect(x: 0, y: 0, width: 720, height: 1280)
            let newFrame = scaleImage(image: image)
            UIGraphicsBeginImageContext(frame.size)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(blackColor.cgColor)
            
            UIRectFill(frame)
            image.draw(in: newFrame, blendMode: .normal, alpha: 1.0)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            let imageData = newImage.pngData()
            do {
                try imageData?.write(to: URL(fileURLWithPath: file))
            } catch let error as NSError {
                print("error:\(error)")
                finishHandle!(error,nil)
                return
            }
            UIGraphicsEndImageContext()
        }
        
        let manager = FFmpegManager.shared()
        manager?.makeVideo(byImages: videoPath,imageCount:Int32(images.count), interval: interval, processBlock: progressHandle, completionBlock: finishHandle)
    }
    
    //将图片缩放到720*1280统一格式
    private func makeImagesForVideo(images:[UIImage],interval:Float) {
        print("\(Date())______________frame生成开始")
        for image in images {
            let newFrame = scaleImage(image: image)
            UIGraphicsBeginImageContext(imageFrame.size)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(blackColor.cgColor)
            
            UIRectFill(imageFrame)
            image.draw(in: newFrame, blendMode: .normal, alpha: 1.0)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            self.images.append(newImage)
            UIGraphicsEndImageContext()
        }
        makeFramesForVideo(interval: interval)
        let manager = FFmpegManager.shared()
        manager?.makeVideo(byImages: videoPath,imageCount:Int32(images.count), interval: interval, processBlock: progressHandle, completionBlock: finishHandle)
    }
    
    //MARK:方法1，创建视频的每一帧(因为通过ffmpeg的filter_complex blend制作的包含过场动画的video会很慢)，所以手动创建每一帧然后合成视频,暂定一秒20帧（帧越少，图片越少）
    private func makeFramesForVideo(interval:Float) {
        var flag = 0//编号,用于为每一帧命名
        var imageIndex = 0
        //每张图制作20帧 * interval
        let count = Int(20*interval)
        
        for image in self.images {//取图片
            for _ in 0..<count {//制作图片
                let imageData = image.pngData()
                let file = videoPath + String(format: "/%05d.png", flag)
                do {
                    try imageData?.write(to: URL(fileURLWithPath: file))
                } catch let error as NSError {
                    print("error:\(error)")
                    finishHandle!(error,nil)
                    return
                }
                flag += 1
            }
            
            guard imageIndex < self.images.count - 1 else {continue}
            let nextImage = self.images[imageIndex + 1]
            //两张图制作15帧（0.75秒）的过场动画
            flag = makeAnimationBetweenFrames(firstImage: image, secondImage: nextImage, flag: flag);
            guard flag > 0 else {return}
            imageIndex += 1
        }
        print("\(Date())______________frame生成完成")
    }
    
    //制作渐变动画（通过改变frame还可以制作位移动画）
    private func makeAnimationBetweenFrames(firstImage:UIImage,secondImage:UIImage,flag:Int) -> Int {
        var tag = flag
        for index in 1..<15 {
            let file = videoPath + String(format: "/%05d.png", tag)
            UIGraphicsBeginImageContext(imageFrame.size)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(clearColor.cgColor)
            UIRectFill(imageFrame)
            firstImage.draw(in: imageFrame, blendMode: .normal, alpha: CGFloat(15-index)/15.0)
            secondImage.draw(in: imageFrame, blendMode: .normal, alpha: CGFloat(index)/15.0)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            let imageData = newImage.pngData()
            do {
                try imageData?.write(to: URL(fileURLWithPath: file))
            } catch let error as NSError {
                print("error:\(error)")
                finishHandle!(error,nil)
                return -1
            }
            UIGraphicsEndImageContext()
            tag += 1
        }
        
        return tag
    }
    
    //图片按比例同一缩放至720*1280，方便之后合成视频
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
    //MARK: 方法2，现将图片保存到沙盒，然后异步执行 单张图片转成视频和制作过度帧并转换成视频，最终合并视频,但是这样会占用大量cpu，也不合适。。。
    //为传入的图片数组的每个元素转换各自的视频
    private func makeImagesForSingleVideo(images:[UIImage],interval:Float) {
        var index = 0
        var paths : [String] = []
        for image in images {
            let file = videoPath + String(format: "/%d.png", index)
            paths.append(file)
            let newFrame = scaleImage(image: image)
            UIGraphicsBeginImageContext(imageFrame.size)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(blackColor.cgColor)
            
            UIRectFill(imageFrame)
            image.draw(in: newFrame, blendMode: .normal, alpha: 1.0)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            let imageData = newImage.pngData()
            self.images.append(newImage)//用于制作过度帧
            do {
                try imageData?.write(to: URL(fileURLWithPath: file))
            } catch let error as NSError {
                print("error:\(error)")
                finishHandle!(error,nil)
                return
            }
            UIGraphicsEndImageContext()
            index += 1
        }
        
        let group = DispatchGroup()
        DispatchQueue.global().async(group: group, qos: .default, flags: []) { [weak self] in
            self!.makeSingleVideo(paths: paths, duration: interval)
        }
        DispatchQueue.global().async(group: group, qos: .default, flags: []) {
            //TODO:制作过度视频
        }
        group.notify(queue: DispatchQueue.global()) {
            //TODO:合并视频
        }
        
    }
    
    private func makeSingleVideo(paths:[String] ,duration:Float) {
        let manager = FFmpegManager.shared()
        var index = 0
        for path in paths {
            let output = videoPath + String(format: "/%d.mp4", index)
            self.outputPaths.append(output)
            manager?.makeVideo(byImage: path, videoName: output, duration: duration, processBlock: self.progressHandle, completionBlock: self.finishHandle)
            index += 1
        }
    }
    
    //MARK:方法3，选择图片后直接呈现在gpuimageview上，手动实现动画，最后合成
    private func setUpImages(){
        
    }
}
