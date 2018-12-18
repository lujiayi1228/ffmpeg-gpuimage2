//
//  PreviewVC.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/17.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import AVKit
import GPUImage2

class PreviewVC: UIViewController {
    
    private lazy var player : AVPlayer = {
        let player = AVPlayer.init()
        player.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
        return player
    }()
    
    lazy var replayBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = clearColor
        btn.setTitle("重播", for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 50)
        btn.centerY = self.view.centerY
        btn.isHidden = true
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(replayAction), for: .touchUpInside)
        return btn
    }()
    
    var video : URL?
    
    init(video: URL) {
        super.init(nibName: nil, bundle: nil)
        self.video = video
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = blackColor
        self.view.addSubview(self.replayBtn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
        self.view.bringSubviewToFront(self.replayBtn)
    }
    
    private func playVideo() {
        let item = AVPlayerItem(url: self.video!)
        self.player.replaceCurrentItem(with: item)
        let layer = AVPlayerLayer(player: self.player)
        layer.frame = self.view.layer.bounds
        self.view.layer.addSublayer(layer)
        self.player.play()
    }
    
    @objc private func replayAction(){
        self.player.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1), completionHandler: {[weak self] (com) in
            if com == true {
                self!.player.play()
            }
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            let value = change?[NSKeyValueChangeKey.newKey] as? Int
            self.replayBtn.isHidden = value == 2
        }
    }
    
    deinit {
        self.player.removeObserver(self, forKeyPath: "timeControlStatus")
        self.player.pause()
    }
    
}
