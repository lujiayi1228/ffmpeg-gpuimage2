//
//  PhotoEditVC.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/7.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import FSPagerView
import GPUImage

class PhotoEditVC: UIViewController {
    
    private var images : [UIImage] = []
    
    private var filteredImages : [UIImage] = []
    
    private var imageVs : [GPUImageView] = []
    
    private var filters  : [GPUImageFilter] = []
    
    private var currentFilterIndex = 0
    
    private lazy var allSetBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame =  CGRect(x: 300, y: self.viewPager.bottom , width: 100, height: 30)
        btn.right = screenWidth - 20
        btn.setTitle("全部设置", for: .normal)
        btn.setTitleColor(blackColor, for: .normal)
        btn.backgroundColor = colorRGBA(red: 220, green: 220, blue: 220, alpha: 1)
        btn.addTarget(self, action: #selector(allSetAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var viewPager: FSPagerView = {
        let viewPager = FSPagerView()
        viewPager.frame = CGRect(x: 8, y: 65, width: screenWidth - 16, height: 500)
        viewPager.dataSource = self as FSPagerViewDataSource
        viewPager.delegate = self as FSPagerViewDelegate
        viewPager.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        
        //设置页面之间的间隔距离
        viewPager.interitemSpacing = 20
        //设置可以无限翻页，默认值为false，false时从尾部向前滚动到头部再继续循环滚动，true时可以无限滚动
        viewPager.isInfinite = false
        
        viewPager.itemSize = CGSize(width: 280, height: 360)
        //设置转场的模式
        viewPager.transformer = FSPagerViewTransformer(type: .linear)
        return viewPager
    }()
    
    private lazy var collectionView: FilterCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 55, height: 55)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collection = FilterCollectionView(frame: CGRect(x: 8, y: screenHeight - 63, width: screenWidth - 16, height: 55), collectionViewLayout: layout)
        collection.delegate = self
        return collection
    }()
    
    init(images: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        self.images = images
        self.createFilter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
    }
    
    private func configView() {
        self.view.backgroundColor = whiteColor
        
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 20, y: 20, width: 40, height: 40)
        backBtn.setTitle("返回", for: .normal)
        backBtn.setTitleColor(blackColor, for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.view.addSubview(backBtn)
        
        let naviLine = CALayer()
        naviLine.frame = CGRect(x: 0, y: 64, width: screenWidth, height: 1)
        naviLine.backgroundColor = UIColor.gray.cgColor
        self.view.layer.addSublayer(naviLine)
        
        let finishBtn = UIButton(type: .custom)
        finishBtn.frame = backBtn.frame
        finishBtn.setTitleColor(blackColor, for: .normal)
        finishBtn.width = 70
        finishBtn.right = screenWidth - 20
        finishBtn.setTitle("下一步", for: .normal)
        finishBtn.addTarget(self, action: #selector(selectMusic), for: .touchUpInside)
        self.view.addSubview(finishBtn)
        
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.viewPager)
        self.view.addSubview(self.allSetBtn)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func createFilter() {
        for _ in self.images {
            let renderView = GPUImageView(frame: CGRect(x: 0, y: 0, width: 280, height: 360))
            renderView.contentMode = .scaleAspectFit
            self.imageVs.append(renderView)
            
            let filter = MovieFilter.filter(tag: 0)
            self.filters.append(filter)

        }
        self.filteredImages = self.images
        allSetAction()
    }
    
    @objc private func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func selectMusic() {
        let newVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
        newVC.images = self.filteredImages
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    @objc private func allSetAction() {
        for index in 0..<self.images.count {
//            guard self.viewPager.currentIndex != index else {continue}
            filterPic(picIndex: index)
        }
    }
    
    private func filterPic(picIndex:Int) {
        var filter = self.filters[picIndex]
        filter.removeAllTargets()
        
        filter = MovieFilter.filter(tag: currentFilterIndex)
        self.filters[picIndex] = filter
        
        let input = GPUImagePicture(image: self.images[picIndex])
        let renderView = self.imageVs[picIndex]
        
        input?.addTarget(filter)
        filter.addTarget(renderView)
        if let newImage = filter.image(byFilteringImage: self.images[picIndex]) {
            self.filteredImages[picIndex] = newImage
        }
        input?.processImage()
        
    }

}

extension PhotoEditVC : UICollectionViewDelegate, FSPagerViewDataSource, FSPagerViewDelegate{
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.images.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        self.imageVs[index].frame = cell.contentView.bounds
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.contentView.addSubview(self.imageVs[index])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        currentFilterIndex = indexPath.row
        let index = self.viewPager.currentIndex
        filterPic(picIndex: index)
    }
    
}


