//
//  HomeViewController.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/7.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import TZImagePickerController

class HomeViewController: UIViewController {

    
    @IBOutlet var buttons: [UIButton]!
    
    var items : [(UIButton,CGPoint,CGPoint)] = []
    
    lazy var progressView: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        label.centerY = self.view.height/2
        label.backgroundColor = clearColor
        label.textColor = UIColor.red
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createItems(names: ["图片","视频" ])
        self.view.addSubview(progressView)
    }
    
    @IBAction func clicked(_ sender: Any) {
        let button = (sender as! UIButton)
        switch button.tag {
        case 0:
            break
        case 1:
            break
        case 2:
        self.showAlert(sender: button)
            break
        case 3:
            break
        case 4:
            break
        default:
            break
        }
    }
    
    func showAlert(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let angle : CGFloat = sender.isSelected ? CGFloat.pi/4 : 0
        UIView.animate(withDuration: 0.3) {
            sender.transform = CGAffineTransform(rotationAngle: angle)
            for item in self.items {
                let center = sender.isSelected ? item.2 : item.1
                (item.0 as UIButton).center = center
                (item.0 as UIButton).transform = CGAffineTransform(rotationAngle: .pi * 2)
            }
        }
    }
    
    func createItems(names:[String]) {
        var tag = 0
        let centerY = self.buttons[2].top - 50
        let centerX = (screenWidth - 80)/CGFloat(names.count+2)
        
        for name in names {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = UIColor.blue
            btn.setTitle(name, for: .normal)
            btn.tag = tag
            btn.addTarget(self, action: #selector(itemClicked(sender:)), for: .touchUpInside)
            btn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
            btn.center = CGPoint(x: self.buttons[2].centerX, y: self.buttons[2].centerY + 45)
            btn.layer.cornerRadius = btn.width/2
            btn.layer.masksToBounds = true
            self.view.addSubview(btn)
            tag += 1
            self.items.append((btn,btn.center,CGPoint(x: centerX * CGFloat(tag + 1), y: centerY)))
        }
        self.view.bringSubviewToFront(self.buttons[2])
        self.buttons[2].layer.cornerRadius = self.buttons[2].width/2
        self.buttons[2].layer.masksToBounds = true
    }
    
    @objc func itemClicked(sender: UIButton) {
        self.clicked(self.buttons[2])
        switch sender.tag {
        case 0:
            self.presentAlbum(isImage: true)
            break
        case 1:
            let newVC = UINavigationController(rootViewController: RecordVC.init())
            self.present(newVC, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    private func presentAlbum (isImage:Bool){
        let imagePickerVC = TZImagePickerController(maxImagesCount: 9, delegate: self as TZImagePickerControllerDelegate)
        
        imagePickerVC?.allowPickingImage = isImage
        imagePickerVC?.allowPickingVideo = !isImage
        imagePickerVC?.sortAscendingByModificationDate = false
        imagePickerVC?.maxImagesCount = 15
        self.present(imagePickerVC!, animated: true, completion: nil)
    }
    
    private func recievedVideo(video: PHAsset, coverImage: UIImage) {
//        self.preview.layer.contents = coverImage.cgImage
//        PHImageManager.default().requestAVAsset(forVideo: video, options: nil) { [weak self] (asset, audio, array) in
//            self?.recievedMovie(asset: asset!)
//            self?.videoAsset = asset!
//            self?.setCoverImage(asset: asset!)
//        }
    }
    
    private func recievedImages(withImages images: [UIImage]) {
//        let newVC = PhotoEditVC.init(images: images)
//        self.present(UINavigationController(rootViewController: newVC), animated: true, completion: nil)
        let maker = VideoMaker()
        progressView.isHidden = false
        progressView.text = "制作中"
        maker.makeVideo(withImages: images, interval: 2, progress: {[weak self] (progress) in
            self!.progressView.text = "\(progress)"
        }) { (error, url) in
            if url != nil {
                let newVC = UINavigationController(rootViewController: VideoEditVC(videoURL: url!))
                self.present(newVC, animated: true, completion: nil)
            }
            self.progressView.isHidden = true
        }
    }
    
}

extension HomeViewController : TZImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.recievedImages(withImages: photos)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        self.recievedVideo(video: asset, coverImage: coverImage)
    }
}
