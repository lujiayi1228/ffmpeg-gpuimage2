//
//  VideoEditor.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/29.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class VideoEditor: NSObject {

    enum VideoTransitionAnimationType {
        case FadeInAndOut
        case HorizontalMoveFromRight
    }
    
    enum EditorType {
        case movie
        case image
    }
    //视频载体
    private lazy var preview: GPUImageView = {
        let view = GPUImageView(frame: screenFrame)
        view.backgroundColor = clearColor
        firstPreview = view
        return view
    }()
    
    private var firstPreview : GPUImageView!
    
    private var secondPreview : GPUImageView!
    
    private var currentIndex : Int = 0
    //副view,用于模拟fade渐变动画
    private lazy var vicePreview : GPUImageView = {
        let view = GPUImageView(frame: screenFrame)
        secondPreview = view
        view.backgroundColor = clearColor
        view.alpha = 0
        return view
    }()
    
    //定时器,用来做动画
    private var displayLink : CADisplayLink!
    
    //精致时的时间控制器
    private var staticTimeFlag : Int = 0
    
    //过渡动画时的时间控制器
    private var dynamicTimeFlag : Int = 1
    
    //input
    private var input : GPUImageOutput!
    
    private var viceInput : GPUImagePicture!
    
    private var images : [UIImage] = []
    
    private var superView : UIView!
    
    var animationType : VideoTransitionAnimationType = .FadeInAndOut
    
    private var editorType : EditorType = .image
    
    //滤镜列表
    lazy var filterList: FilterCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 55, height: 55)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        let collection = FilterCollectionView(frame: CGRect(x: 0, y:screenHeight, width: screenWidth - 16, height: 55), collectionViewLayout: layout)
        collection.delegate = self
        collection.isHidden = true
        return collection
    }()
    
    //滤镜,默认原画
    private var filter : GPUImageFilter = GPUImageFilter()
    
    private var viceFilter : GPUImageFilter = GPUImageFilter()
    
    init(video url:URL, superView:UIView) {
        super.init()
        self.editorType = .movie
        self.superView = superView
        self.superView.addSubview(self.preview)
        self.superView.sendSubviewToBack(self.preview)
        input = GPUImageMovie(url: url)
        (input as! GPUImageMovie).shouldRepeat = true
        input!.addTarget(preview)
        self.superView.addSubview(filterList)
    }
    
    init(images:[UIImage], superView:UIView) {
        super.init()
        self.editorType = .image
        self.images = images
        self.superView = superView
        self.superView.addSubview(self.preview)
        self.superView.sendSubviewToBack(self.preview)
        self.superView.addSubview(self.vicePreview)
        self.superView.sendSubviewToBack(self.vicePreview)
        self.superView.addSubview(filterList)
        
        input = GPUImagePicture(image: images.first)
        input!.addTarget(filter)
        filter.addTarget(preview)
        
        viceInput = GPUImagePicture(image: images[1])
        viceInput.addTarget(viceFilter)
        viceFilter.addTarget(vicePreview)
        
        (input as! GPUImagePicture).processImage()
        viceInput.processImage()
    }
    
    //变更滤镜
    private func changeFilter(newFilter :GPUImageFilter) {
        filter = newFilter
        viceFilter = newFilter
        changeAllFilter()
    }
    
    private func changeAllFilter() {
        input!.removeAllTargets()
        filter.removeAllTargets()
        input!.addTarget(filter)
        filter.addTarget(preview)
        switch editorType {
        case .movie:
            break
        case .image:
            (input as! GPUImagePicture).processImage()
        }
        
        viceInput!.removeAllTargets()
        viceFilter.removeAllTargets()
        viceInput.addTarget(viceFilter)
        viceFilter.addTarget(vicePreview)
        viceInput.processImage()
    }
    
    private func startCustomAnimation() {
        currentIndex = 1
        if displayLink != nil {
            displayLink.invalidate()
            displayLink = nil
            staticTimeFlag = 0
            dynamicTimeFlag = 1
        }
        
        switch animationType {
        case .FadeInAndOut:
            preview.alpha = 1
            vicePreview.alpha = 0
            vicePreview.left = preview.left
            displayLink = CADisplayLink(target: self, selector: #selector(fadeAnimation))
            if #available(iOS 10.0, *) {
                displayLink.preferredFramesPerSecond = 30
            } else {
                displayLink.frameInterval = 2
            }
        case .HorizontalMoveFromRight:
            vicePreview.left = preview.right
            preview.alpha = 1
            vicePreview.alpha = 1
            displayLink = CADisplayLink(target: self, selector: #selector(horizontalMoveAnimation))
            if #available(iOS 10.0, *) {
                displayLink.preferredFramesPerSecond = 60
            } else {
                displayLink.frameInterval = 1
            }
            break
        }
        
        
        displayLink.add(to: RunLoop.current, forMode: .common)
    }
    
    //1秒30帧,过渡动画为24帧(0.8秒) 静止状态(2s) -> 渐变状态(0.8秒) -> 状态结束(1帧)，初始化计数器并切换图片 -> 静止状态
    @objc private func fadeAnimation() {
        if staticTimeFlag < 60 && dynamicTimeFlag == 1 { //静止状态
            staticTimeFlag += 1
            firstPreview = preview.alpha == 0 ? vicePreview : preview
            secondPreview = vicePreview.alpha == 0 ? vicePreview : preview
        }
        if staticTimeFlag == 60 && dynamicTimeFlag < 25 { //渐变状态
            firstPreview.alpha = 1 - CGFloat(dynamicTimeFlag)/24
            secondPreview.alpha = CGFloat(dynamicTimeFlag)/24
            dynamicTimeFlag += 1
        }
        if staticTimeFlag == 60 && dynamicTimeFlag == 24 {//渐变状态结束
            staticTimeFlag = 0
            dynamicTimeFlag = 1
            refreshImage()
        }
    }
    
    //1秒30帧,过渡动画为24帧(0.8秒) 静止状态(2s) -> 渐变状态(0.8秒) -> 状态结束(1帧)，初始化计数器并切换图片 -> 静止状态
    @objc private func horizontalMoveAnimation() {
        if staticTimeFlag < 120 && dynamicTimeFlag == 1 { //静止状态
            staticTimeFlag += 1
            firstPreview = preview.left == 0 ? preview : vicePreview
            secondPreview = vicePreview.left == 0 ? preview : vicePreview
        }
        if staticTimeFlag == 120 && dynamicTimeFlag < 49 { //渐变状态
            firstPreview.left = CGFloat(-dynamicTimeFlag)/48 * firstPreview.width
            secondPreview.left = CGFloat(48-dynamicTimeFlag)/48 * firstPreview.width
            dynamicTimeFlag += 1
        }
        if staticTimeFlag == 120 && dynamicTimeFlag == 49 {//渐变状态结束
            staticTimeFlag = 0
            dynamicTimeFlag = 1
            if preview.left < 0 {
                preview.left = preview.width
            }
            if vicePreview.left < 0 {
                vicePreview.left = preview.width
            }
            refreshImage()
        }
    }
    
    private func refreshImage() {
        currentIndex = (currentIndex + 1)%self.images.count
        if firstPreview == preview {
            input.removeAllTargets()
            filter.removeAllTargets()
            input = GPUImagePicture(image: self.images[currentIndex])
            input.addTarget(filter)
            filter.addTarget(preview)
            (input as! GPUImagePicture).processImage()
        }else if firstPreview == vicePreview {
            viceInput.removeAllTargets()
            viceFilter.removeAllTargets()
            viceInput = GPUImagePicture(image: self.images[currentIndex])
            viceInput.addTarget(viceFilter)
            viceFilter.addTarget(vicePreview)
            viceInput.processImage()
        }
    }
    
    deinit {
        
    }
    
    //MARK:open function
    /// 开始播放
    func startPlay() {
        switch editorType {
        case .movie:
            (input as! GPUImageMovie).startProcessing()
            break
        case .image:
            startCustomAnimation()
            break
        }
    }
    
    ///退出页面时，调用,不是暂停，是释放内存
    func stopPlay() {
        input.removeAllTargets()
        viceInput.removeAllTargets()
        filter.removeAllTargets()
        viceInput.removeAllTargets()
        preview.removeFromSuperview()
        vicePreview.removeFromSuperview()
        
        if displayLink != nil {
            displayLink.invalidate()
            displayLink = nil
        }
        
    }

}

extension VideoEditor : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeFilter(newFilter: MovieFilter.filter(tag: indexPath.row))
    }
}
