//
//  VideoEditor.swift
//  GPUImageDemo
//
//  Created by weijieMac on 2018/12/29.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class VideoEditor: NSObject {

    //视频载体
    lazy var preview: GPUImageView = {
        let view = GPUImageView(frame: screenFrame)
        return view
    }()
    
    //滤镜列表
    lazy var filterList: FilterCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 55, height: 55)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        let collection = FilterCollectionView(frame: CGRect(x: 0, y:screenHeight, width: screenWidth - 16, height: 55), collectionViewLayout: layout)
        collection.delegate = self
        return collection
    }()
    
    //input
    private var movie : GPUImageMovie?
    
    //滤镜,默认原画
    private var filter : GPUImageFilter = GPUImageFilter()
    
    init(video url:URL) {
        super.init()
        movie = GPUImageMovie(url: url)
        movie!.shouldRepeat = true
        movie!.addTarget(preview)
        movie!.startProcessing()
    }
    
    //变更滤镜
    private func changeFilter(newFilter :GPUImageFilter) {
        filter = newFilter
        changeAllFilter()
    }
    
    private func changeAllFilter() {
        movie!.removeAllTargets()
        filter.removeAllTargets()
        movie!.addTarget(filter)
        filter.addTarget(preview)
    }
}

extension VideoEditor : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeFilter(newFilter: MovieFilter.filter(tag: indexPath.row))
    }
}
