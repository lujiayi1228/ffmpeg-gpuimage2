//
//  MusicViewController.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/10.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import AVKit

class MusicViewController: UIViewController {
    
    var images : [UIImage] = [] {
        didSet {
            self.preView.image = images.first
        }
    }

    lazy var finishBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = self.backBtn.frame
        btn.right = screenWidth - self.backBtn.left
        btn.setTitle("合成", for: .normal)
        btn.setTitle("预览", for: .selected)
        btn.setTitleColor(blackColor, for: .normal)
//        btn.isSelected = true
        btn.addTarget(self, action: #selector(makeAcrion), for: .touchUpInside)
        return btn
    }()
    
    var isMaking = false
    
    let timeSpacing : CGFloat = 0.465
    
    var lastTime : CGFloat = 0
    
    var playIndex = 0
    
    var musicType = 0
    
    var observer : Any?
    
    let path = documentPath! + "/"
    
    var preViewPath = ""
    
    private var currentMusic: Int = 0
    
    lazy var preView: UIImageView = {
        let pre = UIImageView(frame: CGRect(x: 11, y: 100, width: 350, height: 400))
        pre.backgroundColor = blackColor
        pre.contentMode = .scaleAspectFit
        return pre
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("<", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        btn.frame = CGRect(x: 12, y: 30, width: 40, height: 40)
        btn.setTitleColor(blackColor, for: .normal)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var progress: UILabel = {
        let pro = UILabel(frame: CGRect(x: 0, y: self.backBtn.bottom, width: screenWidth, height: 48))
        pro.textColor = UIColor.red
        pro.textAlignment = .center
        return pro
    }()
    
    lazy var textV: UITextView = {
        let tv = UITextView(frame: CGRect(x: 0, y: self.preView.bottom, width: screenWidth, height: self.musicButton.top - self.preView.bottom))
        tv.backgroundColor = colorRGBA(red: 220, green: 220, blue: 220, alpha: 1)
        tv.textColor = blackColor
        let music = (self.player.currentItem?.asset as! AVURLAsset).url.absoluteString
        let pic = path + "\("%05d.jpg")"
        let movie = path + "2.mp4"
        //ffmpeg -y -i %@ -i %@ -vcodec mpeg4 %@
        let str = "-filter_complex \"color=c=black:r=60:size=1280x800:d=7.0[black][0:v]format=pix_fmts=yuva420p,zoompan=d=25*4:s=1280x800,fade=t=out:st=3.0:d=1.0:alpha=1,setpts=PTS-STARTPTS[v0];[1:v]format=pix_fmts=yuva420p,zoompan=d=25*4:s=1280x800,fade=t=in:st=0:d=1.0:alpha=1,setpts=PTS-STARTPTS+3.0/TB[v1];[black][v0]overlay[ov0];[ov0][v1]overlay=format=yuv420\""
        tv.text = "ffmpeg -r 10 -y -i \(pic) -i \(music) -vcodec mpeg4 \(movie)"
        tv.isEditable = true
        return tv
    }()
    
    @IBOutlet weak var musicButton: UIButton!
    let bundlePath = Bundle.main.path(forResource: "music", ofType: "bundle")
    
    lazy var player: AVPlayer = {
        let str = String(utf8String: (self.dataSource[0].last)!)!
        let item = AVPlayerItem(url: URL(fileURLWithPath: str))
        let player = AVPlayer.init(playerItem: item)
        self.observer = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1000), queue: DispatchQueue.main) {[weak self] (time) in
            let timee = CGFloat(CMTimeGetSeconds(time))
            guard self != nil else {return}
            if self?.musicType == 0 {
                if timee < 1.509 {return}//1.509是起点,每次到间隔时间就切换（因为精度不能达到0.001秒，故用区间判断）
                if (1.509..<1.978).contains(timee) && self?.lastTime == 0{
                    self?.changeImage(time: timee)
                }else if (self!.timeSpacing..<self!.timeSpacing*2).contains(timee - self!.lastTime){//时间间隔到2倍时间间隔区间内包含时间点，就切换图片
                    self?.changeImage(time: timee)
                }
            }else {
                if (2.4..<4.8).contains(timee - self!.lastTime) {//每1.2秒匀速换图
                    self?.changeImage(time: timee)
                }
            }
        }
        return player
    }()
    
    lazy var dataSource = [["Beautiful Now",self.bundlePath! + "/beautiful_cult.mp3"],["Flight of the silverbird",self.bundlePath! + "/flight of the silverbird_cult.mp3"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = whiteColor
        self.view.addSubview(self.preView)
        self.view.addSubview(self.backBtn)
        self.view.addSubview(self.finishBtn)
        self.view.addSubview(self.progress)
//        self.view.addSubview(self.textV)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.player.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.pause()
        self.player.currentItem?.cancelPendingSeeks()
        self.player.currentItem?.asset.cancelLoading()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func selectMusic(_ sender: UIButton) {
        guard !isMaking else {
            return
        }
        lastTime = 0
        playIndex = 0
        musicType = sender.tag
        self.player.pause()
        let str = String(utf8String: (self.dataSource[sender.tag].last)!)!
        let item = AVPlayerItem(url: URL(fileURLWithPath: str))
        self.player.replaceCurrentItem(with: item)
        self.player.play()
    }
    
    @objc private func backAction(){
        guard !isMaking else {
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    private func changeImage(time:CGFloat) {
        print("\(time)")
        lastTime = time
        playIndex += 1
        self.preView.image = self.images[playIndex % self.images.count]
    }
    
    @objc private func makeAcrion() {
        guard !isMaking else {
            return
        }
        if self.finishBtn.isSelected {
            //TODO:跳转预览视频
            let newVC = PreviewVC.init(video: URL(fileURLWithPath: self.preViewPath))
            self.navigationController?.pushViewController(newVC, animated: true)
        }else {
            isMaking = true
            self.progress.text = "制作中"
            DispatchQueue.global().async {[weak self] in
                switch self?.musicType {
                case 0:
                    self?.saveVariableSpeedImages()
                    break
                case 1:
                    self?.saveUniformSpeedImages()
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func saveVariableSpeedImages() {
        var index = 0
        var tag = 0
        for image in self.images {
            if index == 0 {
                for num in 0...29 {
                    tag = num
                    makeImage(image: image, tag: num)
                }
            }else {
                for num in tag+1...tag+9 {
                    tag = num
                    makeImage(image: image, tag: num)
                }
            }
            index += 1
            print("___________imageSize:\(image.size)")
        }
        makeVideo()
    }
    
    private func saveUniformSpeedImages() {
        var tag = 0
        for image in self.images {
            makeImage(image: image, tag: tag)
            tag += 1
        }
    }
    
    private func makeImage(image:UIImage,tag:Int) {
        let file = path + String(format: "%05d.jpg", tag)
        UIGraphicsBeginImageContext(image.size)
        blackColor.setFill()
        let frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.draw(in: frame, blendMode: .destinationIn, alpha: 1)
//        image.
        let imageData = image.jpegData(compressionQuality: 1)
        do {
            try imageData?.write(to: URL(fileURLWithPath: file))
            
        } catch let error as NSError {
            print("error:\(error)")
        }
        UIGraphicsEndImageContext()
    }
    
    private func makeVideo() {
        
//        FFmpegManager.shared()?.makeVideo(withCommand: textV.text, processBlock: { [weak self] (progress) in
//            DispatchQueue.main.async {
//                self?.progress.text = String(format: "制作中:%d%", progress*100)
//            }
//        }, completionBlock: { [weak self] (error) in
//                if error == nil {
//                    DispatchQueue.main.async {
//                        self?.progress.text = "制作完成"
//                        self?.finishBtn.isSelected = true
//                        self?.isMaking = false
//                    }
//                }else {
//                    print("error:\(error!)")
//
//                }
//        })
        
        FFmpegManager.shared()?.makeVideoByImages(withMusic: (self.player.currentItem?.asset as! AVURLAsset).url.absoluteString, processBlock: { [weak self] (progress) in
            DispatchQueue.main.async {
                self?.progress.text = String(format: "制作中:%d%", progress*100)
            }
        }, completionBlock: { [weak self] (error) in
            if error == nil {
                    let url = URL(fileURLWithPath: (self?.path)! + "1.mp4")
                    if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
                        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(self?.saveFinish(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                    }else {
                        print("因为视频分辨率的问题，保存到相册失败，但是视频已经存在")
                        self?.preViewPath = url.path
                        DispatchQueue.main.async {
                            self?.progress.text = "制作完成"
                            self?.finishBtn.isSelected = true
                            self?.isMaking = false
                        }
                }
            }else {
                print("error:\(error!)")
            }
        })
    }
    
    @objc private func saveFinish(videoPath:String, didFinishSavingWithError error: NSError, contextInfo info: AnyObject) {
        DispatchQueue.global().async { [weak self] in
            if error.code == 0 {
                self?.preViewPath = videoPath
                DispatchQueue.main.async {
                    self?.progress.text = "制作完成"
                    self?.finishBtn.isSelected = true
                    self?.isMaking = false
                }
            }
        }
    }
    
    deinit {
        self.player.removeTimeObserver(self.observer!)
    }
}

