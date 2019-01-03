//
//  VideoEditVC.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/27.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class VideoEditVC: UIViewController {
    
    //videoMaker
    private var videoEditor: VideoEditor?
    
    private var videoPath : URL?
    
    private var images : [UIImage] = []
    //进度条
//    private lazy var progressView: UIProgressView = {
//        let pro
//        return <#value#>
//    }()
    
    //关闭按钮
    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 8, y: 28, width: 29, height: 29)
        btn.backgroundColor = blackColor
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }()
    
    //设置按钮
    private lazy var settingBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 28, width: 32, height: 32)
        btn.right = screenWidth - 15
        btn.backgroundColor = colorRGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
        btn.setTitle("设", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.addTarget(self, action: #selector(settingAction), for: .touchUpInside)
        return btn
    }()
    
    //音量按钮
    private lazy var volumeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = settingBtn.frame
        btn.right = settingBtn.left - 20
        btn.backgroundColor = colorRGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
        btn.setTitle("量", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.addTarget(self, action: #selector(volumeAction), for: .touchUpInside)
        return btn
    }()
    
    //封面按钮
    private lazy var coverBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = settingBtn.frame
        btn.right = volumeBtn.left - 20
        btn.backgroundColor = colorRGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
        btn.setTitle("封", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.addTarget(self, action: #selector(coverAction), for: .touchUpInside)
        return btn
    }()
    
    //音乐按钮
    private lazy var musicBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = settingBtn.frame
        btn.right = coverBtn.left - 20
        btn.backgroundColor = colorRGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
        btn.setTitle("乐", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.addTarget(self, action: #selector(musicAction), for: .touchUpInside)
        return btn
    }()
    
    //滤镜按钮
    private lazy var filterBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = settingBtn.frame
        btn.right = musicBtn.left - 20
        btn.backgroundColor = colorRGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
        btn.setTitle("滤", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(whiteColor, for: .normal)
        btn.addTarget(self, action: #selector(filterAction(sender:)), for: .touchUpInside)
        return btn
    }()
    
    init(videoURL:URL) {
        super.init(nibName: nil, bundle: nil)
        self.videoPath = videoURL
    }
    
    init(images: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        self.images = images
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    private func configView() {
        self.view.backgroundColor = blackColor
        self.navigationController?.navigationBar.isHidden = true
        videoEditor = VideoEditor(images:self.images,superView:self.view)
        videoEditor!.filterList.center = CGPoint(x: screenWidth/2, y: settingBtn.bottom + 50)
        videoEditor!.animationType = .HorizontalMoveFromRight
        self.view.addSubview(closeBtn)
        self.view.addSubview(settingBtn)
        self.view.addSubview(volumeBtn)
        self.view.addSubview(coverBtn)
        self.view.addSubview(musicBtn)
        self.view.addSubview(filterBtn)
    }
    
    deinit {
        
    }
}

extension VideoEditVC {
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoEditor?.startPlay()
    }
    
    @objc private func closeAction() {
        self.navigationController?.dismiss(animated: true, completion: { [weak self] in
            self!.videoEditor?.stopPlay()
        })
    }
    
    @objc private func settingAction() {
        
    }
    
    @objc private func volumeAction() {
        
    }
    
    @objc private func coverAction() {
        
    }
    
    @objc private func musicAction() {
        
    }
    
    @objc private func filterAction(sender:UIButton) {
        videoEditor?.filterList.isHidden = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
}


