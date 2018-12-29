//
//  ViewController.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/11/22.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import AVFoundation
import TZImagePickerController
import CoreAudio
import GPUImage


class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var preview: Preview = {
        let vieww = Preview.init(frame: CGRect(x: 15.5, y: 66, width: 344, height: 360))
        return vieww
    }()
    
    var movie:GPUImageMovie!
    var filter:GPUImageFilter!
//    var speaker:SpeakerOutput!
    
    let imageView = UIImageView()
    
//    private lazy var imageView : RenderView = {
//        let vieww = RenderView(frame: self.preview.frame)
//        self.preview.isHidden = true
//        vieww.layer.backgroundColor = UIColor.clear.cgColor
//        vieww.layer.contentsGravity = .resizeAspect
//        return vieww
//    }()
    
    private var dataSource: [[String: String]] = {
        let arr = [["key":"YuanTu","title":"原图"],
                   ["key":"HuaiJiu","title":"怀旧"],
                   ["key":"DiPian","title":"底片"],
                   ["key":"HeiBai","title":"黑白"],
                   ["key":"FuDiao","title":"浮雕"],
                   ["key":"MengLong","title":"朦胧"],
                   ["key":"KaTong","title":"卡通"],
                   ["key":"TuQi","title":"凸起"],
                   ["key":"ShuiJin","title":"水晶"]]
        
        return arr
    }()
    
    private lazy var audioPlayer : AVPlayer = {
        let player = AVPlayer.init()
        return player
    }()
    
    private var videoAsset : AVAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
    }
    
    private func configView() {
        self.view.addSubview(self.preview)
        self.view.addSubview(self.imageView)
        collectionView.register(filterCell.self, forCellWithReuseIdentifier: "cell")
    }

    //合成视频
    @IBAction func makeVideo(_ sender: UIButton) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/"
        print("___________address:\(NSHomeDirectory())")
        DispatchQueue.global().async {[weak self] in
            var index = 0
            for image in self!.preview.screenImages {
                let file = path + String(format: "%05d.jpg", index)
                UIGraphicsBeginImageContext(image.size)
                let frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                image.draw(in: frame)
                let imageData = image.jpegData(compressionQuality: 1)
                do {
                    try imageData?.write(to: URL(fileURLWithPath: file))
                } catch let error as NSError {
                    print("error:\(error)")
                }
                index += 1
            }
            FFmpegManager.shared()?.makeVideoByImages(processBlock: { (progress) in
                print("当前进度:\(progress*100)%")
            }, completionBlock: { (error,videoUrl) in
                if error != nil {
                    print("error:\(String(describing: error))")
                }else {
                    print("转换完成!")
                }
            })
        }
    }
    
    //上传照片
    @IBAction func selectPhoto(_ sender: UIButton) {
        self.imageView.isHidden = true
        self.preview.isHidden = false
        let imagePickerVC = TZImagePickerController(maxImagesCount: 9, delegate: self as TZImagePickerControllerDelegate)
        
        imagePickerVC?.allowPickingImage = true
        imagePickerVC?.allowPickingVideo = false
        imagePickerVC?.sortAscendingByModificationDate = false
        self.present(imagePickerVC!, animated: true, completion: nil)
    }
    
    //预览播放
    @IBAction func playVideo(_ sender: UIButton) {
        //直接使用avasset初始化后，在imageView上无输出
        
//        let url = URL(string: "qwe.mp4", relativeTo: Bundle.main.resourceURL!)!

        let input = Bundle.main.path(forResource: "video", ofType: "mp4")
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + "video.mov"
        FFmpegManager.shared()?.conver(withInputPath: input, outputPath: path, processBlock: { (progress) in
            print("当前进度:\(progress*100)%")
        }, completionBlock: { (error,videoUrl) in
            if error != nil {
                print("error:\(String(describing: error))")
            }else {
                print("转换完成!")
            }
        })
    }
    
    //上传视频
    @IBAction func selectVideo(_ sender: UIButton) {
        self.imageView.isHidden = false
        self.preview.isHidden = true
        let imagePickerVC = TZImagePickerController(maxImagesCount: 9, delegate: self as TZImagePickerControllerDelegate)

        imagePickerVC?.allowPickingImage = false
        imagePickerVC?.sortAscendingByModificationDate = false
        self.present(imagePickerVC!, animated: true, completion: nil)
        
    }
    
    //美颜开关
    @IBAction func beautyAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    private func recievedImages(withImages images: [UIImage]) {
        self.preview.startAnimation(images: images)
    }
    
    private func recievedMovie(asset : AVAsset) {
//        do {
//            let url = (asset as! AVURLAsset).url
//            let audioDecodeSettings = [AVFormatIDKey:kAudioFormatLinearPCM]
//            movie = try MovieInput(url:url, playAtActualSpeed:true, loop:true, audioSettings:audioDecodeSettings)
//            movie.runBenchmark = true
//            speaker = SpeakerOutput()
//            movie.audioEncodingTarget = speaker
//            movie --> imageView
//            movie.start()
//            speaker.start()
//        } catch  {
//            print("errorrrrrr")
//        }
    }
    
    private func recievedVideo(video: PHAsset, coverImage: UIImage) {
        self.preview.layer.contents = coverImage.cgImage
        PHImageManager.default().requestAVAsset(forVideo: video, options: nil) { [weak self] (asset, audio, array) in
            self?.recievedMovie(asset: asset!)
            self?.videoAsset = asset!
            self?.setCoverImage(asset: asset!)
        }
    }
    
    private func setCoverImage(asset: AVAsset) {
        
        let assetImage = AVAssetImageGenerator(asset: asset)
        assetImage.appliesPreferredTrackTransform = true
        assetImage.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        do {
            let thumb = try assetImage.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil)
            DispatchQueue.main.async { [weak self] in
                self!.imageView.layer.contents = thumb
            }
        } catch { }
 
    }
    
    private func changeFilter(tag : Int) {
        guard movie != nil else {
            return
        }
        if filter != nil {
           filter.removeAllTargets()
        }
        movie.removeAllTargets()
        if tag == 0 {
//            movie.addTarget(imageView)
            return
        }
        filter = MovieFilter.filter(tag: tag)
        movie.addTarget(filter)
//        filter.addTarget(imageView)
    }
    
    @objc private func playerVideo() {

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource , TZImagePickerControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! filterCell
        cell.filterName = self.dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.changeFilter(tag: indexPath.row)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.recievedImages(withImages: photos)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        self.recievedVideo(video: asset, coverImage: coverImage)
    }
}

class filterCell: UICollectionViewCell {
    
    var filterName: [String: String]? {
        didSet {
            title.text = filterName?["title"] ?? ""
            img.image = UIImage(named: filterName?["key"] ?? "YuanTu")
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.frame = CGRect(x: 2.5, y: 0, width: 50, height: 55)
        title.frame = CGRect(x: 0, y: 55-15, width: 55, height: 15)
        
        contentView.addSubview(img)
        contentView.addSubview(title)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        return label
    }()
    
    lazy var img: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
}

class MovieFilter: NSObject {
    public class func filter(tag: Int) -> GPUImageFilter {
        
        switch tag {
        case 1:
            return GPUImageSepiaFilter()//怀旧
        case 2:
            return GPUImageColorInvertFilter()//底片
        case 3:
            return GPUImageSketchFilter()//黑白
        case 4:
            return GPUImageEmbossFilter()//浮雕
        case 5:
            return GPUImageHazeFilter()//朦胧
        case 6:
            return GPUImageToonFilter()//卡通
        case 7:
            return GPUImageBulgeDistortionFilter()//凸起
        case 8:
            return GPUImageGlassSphereFilter()//水晶
        default:
            return GPUImageFilter()//原片
        }
    }
}
